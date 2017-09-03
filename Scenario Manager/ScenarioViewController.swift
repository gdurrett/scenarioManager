//
//  ScenarioTableViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/18/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit
import CloudKit

// Implement search bar stuff via extension
extension ScenarioViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
class ScenarioViewController: UIViewController, UISearchBarDelegate, ScenarioPickerViewControllerDelegate {
    

    @IBOutlet weak var scenarioTableView: UITableView!
    
    @IBAction func scenarioFilterAction(_ sender: Any) {
        switch scenarioFilterOutlet.selectedSegmentIndex {
        case 0:
            //self.navigationItem.title = ("\(scenarioFilterOutlet.titleForSegment(at: 0)!) Scenarios")
            self.navigationItem.title = "All Scenarios"
        case 1:
            //self.navigationItem.title = ("\(scenarioFilterOutlet.titleForSegment(at: 1)!) Scenarios")
            self.navigationItem.title = "Available Scenarios"
        case 2:
            //self.navigationItem.title = ("\(scenarioFilterOutlet.titleForSegment(at: 2)!) Scenarios")
            self.navigationItem.title = "Completed Scenarios"
        default:
            break
        }
        if searchController.isActive && searchController.searchBar.text != "" {
            filterContentForSearchText(searchText: searchController.searchBar.text!)
        }
        scenarioTableView.reloadData()
    }
    @IBOutlet weak var scenarioFilterOutlet: UISegmentedControl!
    var viewModel: ScenarioViewModelFromModel? {
        didSet {
            fillUI()
        }
    }
    var myCompletedTitle: String?
    var myLockedTitle: String?
    var bgColor: UIColor?
    var pickerData = [String]()
    var pickedScenario: Scenario?
    var scenario: Scenario!
    var imageForMainCell: UIImage!
    var mainTextColor = UIColor(hue: 30/360, saturation: 45/100, brightness: 25/100, alpha: 1.0)
    
    var allScenarios: [Scenario]!
    var availableScenarios: [Scenario]!
    var completedScenarios: [Scenario]!
    
    var filteredScenarios = [Scenario]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scenarioTableView?.dataSource = self
        scenarioTableView?.delegate = self
        
        // Set up UI
        styleUI()
        fillUI()

        // Change titles on segmented controller
        setSegmentTitles()
        setupSearch()
        viewModel?.updateAvailableScenarios()
        scenarioTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        //Try notification for tapped rows in ScenarioDetailViewController
        NotificationCenter.default.addObserver(self, selector: #selector(segueToDetailViewController), name: NSNotification.Name(rawValue: "segueToDetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(segueToScenarioPickerViewController), name: NSNotification.Name(rawValue: "segueToPicker"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSelectionAlertViaNotify), name: NSNotification.Name(rawValue: "showSelectionAlert"), object: nil)
        
    }
    // Fix deallocation bug when returning here from detailView
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSegmentTitles()
        self.scenarioTableView.reloadData()
    }
    
    // Set up swipe functionality
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            scenario = filteredScenarios[editActionsForRowAt.row]
        } else {
            switch(scenarioFilterOutlet.selectedSegmentIndex) {
            case 0:
                scenario = allScenarios[editActionsForRowAt.row]
            case 1:
                scenario = availableScenarios[editActionsForRowAt.row]
            case 2:
                scenario = completedScenarios[editActionsForRowAt.row]
            default:
                break
            }
        }
        
        configureSwipeButton(for: scenario)
        
        let swipeToggleLocked = UITableViewRowAction(style: .normal, title: self.myLockedTitle) { action, index in
            if self.myLockedTitle == "Unlock" {
                self.scenario.isUnlocked = true
                self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                self.setSegmentTitles()
                tableView.reloadData()
            } else if self.myLockedTitle == "Lock" {
                self.scenario.isUnlocked = false
                self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                self.setSegmentTitles()
                tableView.reloadData()
            }
        }
        let swipeToggleComplete = UITableViewRowAction(style: .normal, title: self.myCompletedTitle) { action, index in
            if self.myCompletedTitle == "Unavailable" {
                self.showSelectionAlert(status: "disallowCompletion")
                tableView.reloadRows(at: [index], with: .right)
            } else {
                if self.scenario.isCompleted {
                    if (self.viewModel?.areAnyUnlocksCompleted(scenario: self.scenario))! {
                        if (self.viewModel?.didAnotherCompletedScenarioUnlockMe(scenario: self.scenario))! {
                            //Okay to mark uncompleted, but don't trigger lock
                            self.scenario.isCompleted = false
                            self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            self.setSegmentTitles()
                            tableView.reloadData()
                        } else {
                            //NOT okay to mark uncompleted
                            self.showSelectionAlert(status: "")
                            //Test slide back
                            tableView.reloadRows(at: [index], with: .right)
                        }
                    } else if !(self.viewModel?.areAnyUnlocksCompleted(scenario: self.scenario))! {
                        if (self.viewModel?.didAnotherCompletedScenarioUnlockMe(scenario: self.scenario))! {
                            //Okay to mark uncompleted, but don't trigger lock of uncompleted lock
                            self.scenario.isCompleted = false
                            self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            self.setSegmentTitles()
                            tableView.reloadData()
                        } else {
                            //Okay to mark uncompleted AND trigger lock
                            self.scenario.isCompleted = false
                            self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            self.setSegmentTitles()
                            tableView.reloadData()
                        }
                    }
                } else {
                    self.scenario.isCompleted = true
                    if self.scenario.unlocks[0] == "ONEOF" {
                        self.performSegue(withIdentifier: "ShowScenarioPicker", sender: self.scenario)
                    } else {
                        self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: true)
                        self.setSegmentTitles()
                        
                        tableView.reloadData()
                    }
                }

            } // Can't complete
        }
        swipeToggleComplete.backgroundColor = bgColor
        swipeToggleLocked.backgroundColor = UIColor.darkGray
        if myLockedTitle == "Unlock" {
            return [swipeToggleLocked]
        } else if myLockedTitle == "NoShow" {
            return [swipeToggleComplete]
        } else {
            return [swipeToggleLocked, swipeToggleComplete]
        }
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowScenarioDetail" {
            //searchController.isActive = false
            let destinationVC = segue.destination as! ScenarioDetailViewController
            let viewModel = ScenarioDetailViewModel(withScenario: (self.viewModel?.selectedScenario!)!)
            destinationVC.viewModel = viewModel
        } else if segue.identifier == "ShowScenarioPicker" {
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! ScenarioPickerViewController
            destinationVC.delegate = self
            destinationVC.scenario = sender as! Scenario
            destinationVC.additionalTitles = viewModel!.getAdditionalTitles(for: destinationVC.scenario)
        }
    }
    
    // Perform segue (Show Scenario Detail when cell is tapped)
    func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" {
            scenario = filteredScenarios[indexPath.row]
        } else {
            //            scenario = dataModel.allScenarios[indexPath.row]
            //        }
            //Make sure to draw from proper filter for our indexPath based on segment selection
            switch(scenarioFilterOutlet.selectedSegmentIndex) {
            case 0:
                scenario = allScenarios[indexPath.row]
            case 1:
                scenario = availableScenarios[indexPath.row]
            case 2:
                scenario = completedScenarios[indexPath.row]
            default:
                break
            }
        }
        viewModel?.selectedScenario = scenario
        performSegue(withIdentifier: "ShowScenarioDetail", sender: scenario)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    // Helper methods
    func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Scenario"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    func configureRowIcon(for tableViewCell: ScenarioMainCell, with scenario: Scenario) {
        if scenario.isCompleted == true {
            tableViewCell.scenarioRowIcon.image = #imageLiteral(resourceName: "scenarioCompletedIcon")
        } else if scenario.requirementsMet == true && scenario.isUnlocked == true {
            tableViewCell.scenarioRowIcon.image = nil
        } else {
            tableViewCell.scenarioRowIcon.image = #imageLiteral(resourceName: "scenarioLockedIcon")
        }
        
    }
    func configureSwipeButton(for scenario: Scenario) {
        if scenario.isCompleted {
            bgColor = UIColor(hue: 213/360, saturation: 0/100, brightness: 64/100, alpha: 1.0)
            myCompletedTitle = "Set Uncompleted"
        } else if scenario.isUnlocked && scenario.requirementsMet  {
            bgColor = UIColor(hue: 213/360, saturation: 0/100, brightness: 64/100, alpha: 1.0)
            myCompletedTitle = "Set Completed"
        } else {
            bgColor = UIColor(hue: 213/360, saturation: 0/100, brightness: 64/100, alpha: 1.0)
            myCompletedTitle = "Unavailable"
        }
        if scenario.isManuallyUnlockable && scenario.isUnlocked && !scenario.isCompleted {
            myLockedTitle = "Lock"
        } else if scenario.isManuallyUnlockable && !scenario.isCompleted {
            myLockedTitle = "Unlock"
        } else {
            myLockedTitle = "NoShow"
        }
    }
    func configureTitle(for cell: UITableViewCell, with scenario: Scenario) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = "\(scenario.number)) " + scenario.title
        label.sizeToFit()
    }
    func configureRewardText(for cell: UITableViewCell, with rewards: [String]) {
        let label = cell.viewWithTag(1200) as! UILabel
        // Use extension to Sequence as defined before this class declaration
        label.text = ("Rewards: \(rewards.minimalDescription)")
        label.sizeToFit()
    }
    func configureUnlockedByText(for cell: UITableViewCell, with unlockedBys: [String]) {
        let label = cell.viewWithTag(1500) as! UILabel
        label.text = ("Unlocked By: \(unlockedBys.minimalDescription)")
    }
    func configureGoalText(for cell: UITableViewCell, with text: String) {
        let goalLabel = cell.viewWithTag(1100) as! UILabel
        var lines = [String]()
        text.enumerateLines { line, _ in lines.append(line) }
        goalLabel.text = (lines[0])
        goalLabel.sizeToFit()
    }
    func setImageFromURL(imageUrl url: NSURL) -> UIImage {
        var image = UIImage()
        if let data = NSData(contentsOf: url as URL) {
            image = UIImage(data: data as Data)!
        }
        return image
    }
    func setSegmentTitles() {
        let segmentTitleAttributes = setTextAttributes(fontName: "Nyala", fontSize: 20.0, textColor: mainTextColor)
        scenarioFilterOutlet.setTitle("All (\(allScenarios.count))", forSegmentAt: 0)
        scenarioFilterOutlet.setTitle("Available (\(availableScenarios.count))", forSegmentAt: 1)
        scenarioFilterOutlet.setTitle("Completed (\(completedScenarios.count))", forSegmentAt: 2)
        scenarioFilterOutlet.setTitleTextAttributes(segmentTitleAttributes, for: .normal)
        scenarioFilterOutlet.backgroundColor = UIColor(hue: 40/360, saturation: 6/100, brightness: 100/100, alpha: 1.0)
        scenarioTableView.reloadData()
    }
    func setTextAttributes(fontName: String, fontSize: CGFloat, textColor: UIColor) -> [ String : Any ] {
        let fontStyle = UIFont(name: fontName, size: fontSize)
        let fontColor = textColor
        return [ NSFontAttributeName : fontStyle! , NSForegroundColorAttributeName : fontColor ]
    }
    func showSelectionAlert(status: String) {
        var alertTitle = String()
        if status == "disallowCompletion" {
            alertTitle = "Cannot set to Completed!"
        } else {
            alertTitle = "Cannot set to Uncompleted!"
        }
        let alertView = UIAlertController(
            title: alertTitle,
            message: nil,
            preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = UIColor.black
        alertView.addAction(action)
        present(alertView, animated: true, completion: { _ in
        })
    }
    // Search helper functions
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        var scenarioSubset = [Scenario]()
        switch(scenarioFilterOutlet.selectedSegmentIndex) {
        case 0:
            scenarioSubset = allScenarios
        case 1:
            scenarioSubset = availableScenarios
        case 2:
            scenarioSubset = completedScenarios
        default:
            break
        }
        filteredScenarios = scenarioSubset.filter { scenario in return scenario.title.lowercased().contains(searchText.lowercased()) || scenario.achieves.minimalDescription.lowercased().contains(searchText.lowercased()) || scenario.rewards.minimalDescription.lowercased().contains(searchText.lowercased()) || scenario.locationString.lowercased().contains(searchText.lowercased())}
        scenarioTableView.reloadData()
    }
    fileprivate func styleUI() {
        self.scenarioTableView.estimatedRowHeight = 100
        self.scenarioTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = mainTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hue: 40/360, saturation: 6/100, brightness: 100/100, alpha: 1.0)
        self.navigationItem.title = "All Scenarios"
        self.navigationController?.navigationBar.titleTextAttributes = setTextAttributes(fontName: "Nyala", fontSize: 26.0, textColor: mainTextColor)
    }
    fileprivate func fillUI() {
        if !isViewLoaded {
            return
        }
        
        guard let viewModel = viewModel else {
            return
        }
        
        // We definitely have the setup done now
        self.allScenarios = viewModel.allScenarios
        // Call our Dynamic bindAndFire method when these are gotten
        viewModel.availableScenarios.bindAndFire { [unowned self] in self.availableScenarios = $0 }
        viewModel.completedScenarios.bindAndFire { [unowned self] in self.completedScenarios = $0 }
    }
    fileprivate func setupSearch() {
        //Set up searchController stuff

        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.gray
        searchController.searchBar.placeholder = "Search Scenarios, Rewards, Achievements"
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.showsCancelButton = false
        definesPresentationContext = true
        scenarioTableView.tableHeaderView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false

    }
    internal func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Got to searchBarCancelButtonClicked")
        if filteredScenarios.count != 0 || searchController.searchBar.text == "" {
            scenarioTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    // Implement delegate methods for ScenarioPickerViewController
    func scenarioPickerViewControllerDidCancel(_ controller: ScenarioPickerViewController) {
        controller.scenario.isCompleted = false
        viewModel?.updateAvailableScenarios(scenario: controller.scenario, isCompleted: false)
        scenarioTableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func scenarioPickerViewController(_ controller: ScenarioPickerViewController, didFinishPicking scenario: Scenario) {
        if let pickedScenario = controller.pickedScenario?.components(separatedBy: " - ") {
            scenario.unlocks = ["ONEOF", "\(pickedScenario[0])"]
        }
        viewModel?.updateAvailableScenarios(scenario: scenario, isCompleted: true)
        self.setSegmentTitles()
        scenarioTableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func segueToDetailViewController(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            let scenarioTapped = dict["Scenario"] as! Scenario
            viewModel?.selectedScenario = scenarioTapped
            self.performSegue(withIdentifier: "ShowScenarioDetail", sender: scenarioTapped)
        }
    }
    func segueToScenarioPickerViewController(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            let scenarioTapped = dict["Scenario"] as! Scenario
            viewModel?.selectedScenario = scenarioTapped
            self.performSegue(withIdentifier: "ShowScenarioPicker", sender: scenarioTapped)
        }
    }
    func showSelectionAlertViaNotify(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            let status = dict["status"] as! String
            if status == "disallowCompletion" {
                title = "Cannot set to Completed!"
            } else {
                title = "Cannot set to Uncompleted!"
            }
            let alertView = UIAlertController(
                title: title,
                message: nil,
                preferredStyle: .actionSheet)
            
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alertView.addAction(action)
            present(alertView, animated: true, completion: { _ in
            })
        }
    }
}
// Test out an extension
extension Sequence {
    var minimalDescription: String {
        return map { "\($0)" }.joined(separator: ", ")
    }
}
// MARK: ScenarioTableView datasource and delegate methods

extension ScenarioViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        if searchController.isActive && searchController.searchBar.text != "" {
            returnValue = filteredScenarios.count
        } else {
            //            returnValue = dataModel.allScenarios.count
            //        }
            switch(scenarioFilterOutlet.selectedSegmentIndex) {
            case 0:
                returnValue = allScenarios.count
            case 1:
                returnValue = availableScenarios.count
            case 2:
                returnValue = completedScenarios.count
            default:
                break
            }
        }
        return returnValue
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        if searchController.isActive && searchController.searchBar.text != "" {
            scenario = filteredScenarios[indexPath.row]
        } else {
            switch(scenarioFilterOutlet.selectedSegmentIndex) {
            case 0:
                scenario = allScenarios[indexPath.row]
            case 1:
                scenario = availableScenarios[indexPath.row]
            case 2:
                scenario = completedScenarios[indexPath.row]
            default:
                break
            }
        }
        configureTitle(for: cell, with: scenario)
        configureGoalText(for: cell, with: scenario.summary)
        configureRowIcon(for: ((cell as? ScenarioMainCell)!), with: scenario)
        
        cell.backgroundView = UIImageView(image: UIImage(named: scenario.mainCellBGImage))
        cell.backgroundView?.alpha = 0.25
        cell.selectedBackgroundView = UIImageView(image: UIImage(named: scenario.mainCellBGImage))
        cell.selectedBackgroundView?.alpha = 0.65
        
        return cell as! ScenarioMainCell
        
    }
}

// MARK: DataModelDelegate
// MARK: - DataModelDelegate
extension ScenarioViewController: DataModelDelegate {
    func errorUpdating(error: CKError, type: myCKErrorType) {
        let message: String
        if error.code == CKError.notAuthenticated {
            message = "Unable to save state to iCloud. Please enable iCloud for the CampaignManager app in iCloud settings."
        } else {
            message = error.localizedDescription
        }
        let alertController = UIAlertController(title: nil,
                                                message: message,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}
