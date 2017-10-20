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
class ScenarioViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var scenarioTableView: UITableView!
    
    @IBAction func scenarioFilterAction(_ sender: Any) {
        switch scenarioFilterOutlet.selectedSegmentIndex {
        case 0:
            self.navigationItem.title = "\(selectedCampaign!.title) Scenarios"
        case 1:
            self.navigationItem.title = "\(selectedCampaign!.title) Scenarios"
        case 2:
            self.navigationItem.title = "\(selectedCampaign!.title) Scenarios"
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
    var pickerData = [String]()
    var didPick = false
    var pickCount = 0
    var pickedScenario: [String]?
    var myInputView = UIView()
    let scenarioPicker = UIPickerView()
    let dummyTextField = UITextField()
    var filteredScenarios = [Scenario]()
    var scenario: Scenario!
    var imageForMainCell: UIImage!
    
    var allScenarios: [Scenario]!
    var availableScenarios: [Scenario]!
    var completedScenarios: [Scenario]!
    
    var selectedCampaign: Campaign?
    
    let searchController = UISearchController(searchResultsController: nil)
    let colorDefinitions = ColorDefinitions()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scenarioTableView?.dataSource = self
        scenarioTableView?.delegate = self
        viewModel?.updateLoadedCampaign()
        viewModel?.updateAvailableScenarios()
        // Set up UI
        fillUI()
        styleUI()

        // Change titles on segmented controller
        setSegmentTitles()
        setupSearch()
        scenarioTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        
        //Try notification for tapped rows in ScenarioDetailViewController
        NotificationCenter.default.addObserver(self, selector: #selector(segueToDetailViewController), name: NSNotification.Name(rawValue: "segueToDetail"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentScenarioPickerViewController), name: NSNotification.Name(rawValue: "segueToPicker"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSelectionAlertViaNotify), name: NSNotification.Name(rawValue: "showSelectionAlert"), object: nil)
        
    }
    // Fix deallocation bug when returning here from detailView
    deinit {
        self.searchController.view.removeFromSuperview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ("\(self.selectedCampaign!.title) Scenarios")
        viewModel?.updateLoadedCampaign()
        viewModel?.updateAvailableScenarios()
        self.setSegmentTitles()
        self.scenarioTableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
                self.viewModel?.campaign.value.isUnlocked[Int(self.scenario.number)! - 1] = true
                self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                self.setSegmentTitles()
                tableView.reloadData()
            } else if self.myLockedTitle == "Lock" {
                self.scenario.isUnlocked = false
                self.viewModel?.campaign.value.isUnlocked[Int(self.scenario.number)! - 1] = false
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
                        for unlock in self.scenario.unlocks {
                            if unlock == "ONEOF" { continue }
                            let scenarioToUpdate = self.viewModel?.getScenario(scenarioNumber: unlock)!
                            if (self.viewModel?.didAnotherCompletedScenarioUnlockMe(unlockToCheck: scenarioToUpdate!, sendingScenario: self.scenario))! {
                                //Okay to mark uncompleted, but don't trigger lock
                                self.scenario.isCompleted = false
                                self.viewModel?.campaign.value.isCompleted[Int(self.scenario.number)! - 1] = false
                                self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                                self.setSegmentTitles()
                                tableView.reloadData()
                                
                            } else {
                                //NOT okay to mark uncompleted
                                self.showSelectionAlert(status: "")
                                tableView.reloadRows(at: [index], with: .right)
                                //Test bail out first time we disallow uncompletion
                                break
                            }
                        }
                    } else if !(self.viewModel?.areAnyUnlocksCompleted(scenario: self.scenario))! {
                        for unlock in self.scenario.unlocks {
                            if unlock == "ONEOF" { continue }
                            let scenarioToUpdate = self.viewModel?.getScenario(scenarioNumber: unlock)
                            if (scenarioToUpdate != nil && (self.viewModel?.didAnotherCompletedScenarioUnlockMe(unlockToCheck: scenarioToUpdate!, sendingScenario: self.scenario))!) {
                                //Okay to mark uncompleted, but don't trigger lock of uncompleted lock
                                self.scenario.isCompleted = false
                                self.viewModel?.campaign.value.isCompleted[Int(self.scenario.number)! - 1] = false
                                self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                                self.setSegmentTitles()
                                tableView.reloadData()
                            } else {
                                //Okay to mark uncompleted AND trigger lock
                                self.scenario.isCompleted = false
                                self.viewModel?.campaign.value.isCompleted[Int(self.scenario.number)! - 1] = false
                                self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                                self.setSegmentTitles()
                                tableView.reloadData()
                            }
                        }
                    }
                } else {
                    if self.scenario.unlocks[0] == "ONEOF" {
                        //self.performSegue(withIdentifier: "ShowScenarioPicker", sender: self.scenario)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "segueToPicker"), object: nil, userInfo: ["Scenario": self.scenario])
                    } else {
                        self.scenario.isCompleted = true // Test in here
                        self.viewModel?.campaign.value.isCompleted[Int(self.scenario.number)! - 1] = true // Test in here
                        self.viewModel?.updateAvailableScenarios(scenario: self.scenario, isCompleted: true)
                        self.setSegmentTitles()
                        tableView.reloadData()
                    }
                }

            } // Can't complete
        }
        swipeToggleComplete.backgroundColor = colorDefinitions.scenarioSwipeBGColor
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
            let destinationVC = segue.destination as! ScenarioDetailViewController
            let viewModel = ScenarioDetailViewModel(withScenario: (self.viewModel?.selectedScenario!)!)
            destinationVC.viewModel = viewModel
        }
    }
    
    // Perform segue (Show Scenario Detail when cell is tapped)
    func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" {
            scenario = filteredScenarios[indexPath.row]
        } else {
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
        return 90.0
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
            myCompletedTitle = "Set Uncompleted"
        } else if scenario.isUnlocked && scenario.requirementsMet  {
            myCompletedTitle = "Set Completed"
        } else {
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
        scenarioFilterOutlet.setTitle("All (\(allScenarios.count))", forSegmentAt: 0)
        scenarioFilterOutlet.setTitle("Available (\(availableScenarios.count))", forSegmentAt: 1)
        scenarioFilterOutlet.setTitle("Completed (\(completedScenarios.count))", forSegmentAt: 2)
        scenarioFilterOutlet.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Nyala", size: 20.0)!, NSAttributedStringKey.foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        scenarioFilterOutlet.backgroundColor = colorDefinitions.scenarioSegmentedControlBGColor
        self.navigationItem.title = "\(selectedCampaign!.title) Scenarios"
        scenarioTableView.reloadData()
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
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
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
    fileprivate func setupSearch() {
        //Set up searchController stuff
        
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = colorDefinitions.scenarioTableViewSearchBarBarTintColor
        searchController.searchBar.placeholder = "Search Scenarios, Rewards, Achievements"
        searchController.searchBar.tintColor = colorDefinitions.detailTableViewHeaderTintColor
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
        if filteredScenarios.count != 0 || searchController.searchBar.text == "" {
            scenarioTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    // Called in styleUI()
    func setTextFieldTintColor(to color: UIColor, for view: UIView) {
        if view is UITextField {
            view.tintColor = color
        }
        for subview in view.subviews {
            setTextFieldTintColor(to: color, for: subview)
        }
    }
    // viewDidLoad helper functions
    fileprivate func styleUI() {
        self.scenarioTableView.estimatedRowHeight = 90
        self.scenarioTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        
        // See if we can set search field's cursor to a darker color than the Cancel button
        self.setTextFieldTintColor(to: colorDefinitions.scenarioTitleFontColor, for: searchController.searchBar)
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
        self.selectedCampaign = viewModel.campaign.value
        // Call our Dynamic bindAndFire method when these are gotten
        viewModel.availableScenarios.bindAndFire { [unowned self] in self.availableScenarios = $0 }
        viewModel.completedScenarios.bindAndFire { [unowned self] in self.completedScenarios = $0 }
        viewModel.campaign.bindAndFire { [unowned self] in self.selectedCampaign = $0 }
    }
    // Implement delegate methods for ScenarioPickerViewController
    @objc func scenarioPickerViewControllerDidCancel(sender: UIBarButtonItem) {
        self.scenario.isCompleted = false
        viewModel!.selectedScenario!.isCompleted = false
        viewModel?.updateAvailableScenarios(scenario: scenario, isCompleted: false)
        dummyTextField.removeFromSuperview()
        myInputView.removeFromSuperview()
        scenarioPicker.removeFromSuperview()
        self.pickerData.removeAll()
        scenarioTableView.reloadData()
    }
    
    @objc func scenarioPickerViewControllerDidTapDone(sender: UIButton) {
        if !didPick {
            scenarioPicker.selectRow(0, inComponent: 0, animated: true)
            let row = scenarioPicker.selectedRow(inComponent: 0)
            pickedScenario = pickerData[row].components(separatedBy: " - ")
            print("Think I picked this in tapDone: \(pickedScenario!)")
            scenario.unlocks = ["ONEOF", "\(pickedScenario![0])"]
        }
        print("Bypassing didnt' pick?")
        self.scenario.isCompleted = true // Test in here
        self.viewModel?.campaign.value.isCompleted[Int(self.scenario.number)! - 1] = true // Test in here
        viewModel?.updateAvailableScenarios(scenario: scenario, isCompleted: true)
        self.setSegmentTitles()
        myInputView.removeFromSuperview()
        scenarioPicker.removeFromSuperview()
        scenarioTableView.reloadData()
        self.pickerData.removeAll()
    }
    
    @objc func segueToDetailViewController(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            let scenarioTapped = dict["Scenario"] as! Scenario
            viewModel?.selectedScenario = scenarioTapped
            self.performSegue(withIdentifier: "ShowScenarioDetail", sender: scenarioTapped)
        }
    }
    @objc func presentScenarioPickerViewController(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            let scenarioTapped = dict["Scenario"] as! Scenario
            viewModel?.selectedScenario = scenarioTapped
            setUpScenarioPicker(for: scenarioTapped)
        }
    }
    @objc func showSelectionAlertViaNotify(_ notification: NSNotification) {
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
            present(alertView, animated: true, completion: nil)
        }
    }
    func setUpScenarioPicker(for scenario: Scenario) {
        scenarioPicker.layer.cornerRadius = 10
        scenarioPicker.layer.masksToBounds = true
        scenarioPicker.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        scenarioPicker.showsSelectionIndicator = true
        scenarioPicker.delegate = self
        scenarioPicker.dataSource = self
        
        // Try to set up toolbar
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.layer.cornerRadius = 10
        toolBar.layer.masksToBounds = true
        toolBar.tintColor = colorDefinitions.scenarioTitleFontColor
        toolBar.barTintColor = colorDefinitions.scenarioSwipeFontColor
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(scenarioPickerViewControllerDidTapDone(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(scenarioPickerViewControllerDidCancel(sender:)))
        doneButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        cancelButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        var number = String()
        var myTitle = String()
        var additionalTitles = self.viewModel!.getAdditionalTitles(for: scenario)
        for i in 0..<additionalTitles.count {
            number = additionalTitles[i].0
            myTitle = number + " - " + additionalTitles[i].1
            
            pickerData.append(myTitle)
            scenarioPicker.reloadAllComponents()
        }
        // Make sure to reset didPick!
        self.didPick = false
        scenarioPicker.addSubview(toolBar)
        myInputView = UIView.init(frame: CGRect(x: 20, y: 310, width: self.view.frame.width - 40, height: scenarioPicker.frame.size.height + 44))
        scenarioPicker.frame = CGRect(x: 0, y: 0, width: myInputView.frame.width, height: 200)
        myInputView.addSubview(scenarioPicker)
        myInputView.addSubview(toolBar)
        dummyTextField.inputView = myInputView
        dummyTextField.isHidden = true
        self.view.addSubview(dummyTextField)
        self.view.addSubview(myInputView)
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
    func showProgressHUD() {
        //
    }
    func hideProgressHUD() {
        //
    }
    func darkenViewBGColor() {
        //
    }
    func restoreViewBGColor() {
        //
    }
}

// MARK: PickerView Delegate Methods
extension ScenarioViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    // Get picker selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Need to fix multiple scrolls of picker...
        didPick = true
        pickedScenario = [""]
        scenario.unlocks = ["ONEOF", "15", "17", "20"] // Try reset
        pickedScenario = pickerData[row].components(separatedBy: " - ")
        print("Think I picked: \(pickedScenario!)")
        scenario.unlocks = ["ONEOF", "\(pickedScenario![0])"]
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView{
        var label = view as! UILabel!
        if label == nil {
            label = UILabel()
        }
        
        label?.font = UIFont(name: "Nyala", size: 24)!
        label?.text =  pickerData[row]
        label?.textAlignment = .center
        return label!
        
    }
}
