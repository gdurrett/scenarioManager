//
//  ViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 6/28/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

// Test out an extension
extension Sequence {
    var minimalDescription: String {
        return map { "\($0)" }.joined(separator: ", ")
    }
}
// Implement search bar stuff via extension
extension ScenarioViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

class ScenarioViewController: UITableViewController, ScenarioPickerViewControllerDelegate {


    @IBOutlet weak var scenarioFilterOutlet: UISegmentedControl!
    
    @IBAction func scenarioFilterAction(_ sender: Any) {
//        tableView.reloadData()
        switch scenarioFilterOutlet.selectedSegmentIndex {
        case 0:
            self.navigationItem.title = ("\(scenarioFilterOutlet.titleForSegment(at: 0)!) Scenarios")
        case 1:
            self.navigationItem.title = ("\(scenarioFilterOutlet.titleForSegment(at: 1)!) Scenarios")
        case 2:
            self.navigationItem.title = ("\(scenarioFilterOutlet.titleForSegment(at: 2)!) Scenarios")
        default:
            break
        }
        tableView.reloadData()
    }
    
    var dataModel: DataModel!
    var myCompletedTitle: String?
    var myLockedTitle: String?
    var bgColor: UIColor?
    var pickerData = [String]()
    var pickedScenario: Scenario?
    var scenario: Scenario!
    
    var filteredScenarios = [Scenario]()
    let searchController = UISearchController(searchResultsController: nil)
    
    // See if we can set proper segment title for All segment tab

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        if searchController.isActive && searchController.searchBar.text != "" {
            returnValue = filteredScenarios.count
        } else {
            //            returnValue = dataModel.allScenarios.count
            //        }
            switch(scenarioFilterOutlet.selectedSegmentIndex) {
            case 0:
                returnValue = dataModel.allScenarios.count
            case 1:
                returnValue = dataModel.availableScenarios.count
            case 2:
                returnValue = dataModel.completedScenarios.count
            default:
                break
            }
        }
        return returnValue
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ScenarioMainCell {
        let cell = makeCell(for: tableView)
        if searchController.isActive && searchController.searchBar.text != "" {
            scenario = filteredScenarios[indexPath.row]
        } else {
            //            scenario = dataModel.allScenarios[indexPath.row]
            //        }
            //scenario = dataModel.allScenarios[indexPath.row]
            switch(scenarioFilterOutlet.selectedSegmentIndex) {
            case 0:
                scenario = dataModel.allScenarios[indexPath.row]
            case 1:
                scenario = dataModel.availableScenarios[indexPath.row]
            case 2:
                scenario = dataModel.completedScenarios[indexPath.row]
            default:
                break
            }
        }
        configureTitle(for: cell, with: scenario)
        cell.backgroundColor = configureBGColor(for: cell, with: scenario)
        configureRewardText(for: cell, with: scenario.rewards)
        configureAchievesText(for: cell, with: dataModel.getAchieves(for: scenario))
        configureRowIcon(for: cell as! ScenarioMainCell, with: scenario)
        return cell as! ScenarioMainCell
        
    }
// May use in the future to disallow row selection!
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        let scenario = dataModel.allScenarios[indexPath.row]
//        if (scenario.isUnlocked && scenario.requirementsMet) || scenario.completed {
//            return indexPath
//        } else {
//            return nil
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.barTintColor = DataModel.sharedInstance.availableBGColor
        //Try notification for tapped rows in ScenarioDetailViewController
        NotificationCenter.default.addObserver(self, selector: #selector(segueToDetailViewController), name: NSNotification.Name(rawValue: "segue"), object: nil)
        
        //Set up searchController stuff
        searchController.searchBar.barTintColor = dataModel.availableBGColor
        searchController.searchBar.placeholder = "Search Scenarios, Rewards, Achievements"
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.searchBarStyle = .minimal
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // Set up swipe functionality
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        if searchController.isActive && searchController.searchBar.text != "" {
            scenario = filteredScenarios[editActionsForRowAt.row]
        } else {
            //            scenario = dataModel.allScenarios[editActionsForRowAt.row]
            //        }
            switch(scenarioFilterOutlet.selectedSegmentIndex) {
            case 0:
                scenario = dataModel.allScenarios[editActionsForRowAt.row]
            case 1:
                scenario = dataModel.availableScenarios[editActionsForRowAt.row]
            case 2:
                scenario = dataModel.completedScenarios[editActionsForRowAt.row]
            default:
                break
            }
        }
        //bgColor = UIColor(hue: 213/360, saturation: 0/100, brightness: 64/100, alpha: 1.0)
        if scenario.completed {
            bgColor = dataModel.availableBGColor
            
            myCompletedTitle = "Uncompleted"
        } else if scenario.isUnlocked && scenario.requirementsMet  {
            bgColor = dataModel.completedBGColor
            myCompletedTitle = "Completed"
        } else {
            bgColor = UIColor(hue: 213/360, saturation: 0/100, brightness: 64/100, alpha: 1.0)
            myCompletedTitle = "Unavailable"
        }
        if scenario.isManuallyUnlockable && scenario.isUnlocked && !scenario.completed {
            myLockedTitle = "Lock"
        } else if scenario.isManuallyUnlockable && !scenario.completed {
            myLockedTitle = "Unlock"
        } else {
            myLockedTitle = "NoShow"
        }
        let swipeToggleLocked = UITableViewRowAction(style: .normal, title: self.myLockedTitle) { action, index in
        if self.myLockedTitle == "Unlock" {
            self.scenario.isUnlocked = true
            self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
            tableView.reloadData()
        } else if self.myLockedTitle == "Lock" {
            self.scenario.isUnlocked = false
            self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
            tableView.reloadData()
            }
        }
        let swipeToggleComplete = UITableViewRowAction(style: .normal, title: self.myCompletedTitle) { action, index in
            if self.myCompletedTitle == "Unavailable" {
                self.showSelectionAlert(status: "disallowCompletion")
            } else {
                if self.scenario.completed {
                    if self.dataModel.areAnyUnlocksCompleted(scenario: self.scenario) {
                        if self.dataModel.didAnotherCompletedScenarioUnlockMe(scenario: self.scenario) {
                            //Okay to mark uncompleted, but don't trigger lock
                            self.scenario.completed = false
                            self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            tableView.reloadData()
                        } else {
                            //NOT okay to mark uncompleted
                            self.showSelectionAlert(status: "")
                        }
                    } else if !self.dataModel.areAnyUnlocksCompleted(scenario: self.scenario) {
                        if self.dataModel.didAnotherCompletedScenarioUnlockMe(scenario: self.scenario) {
                            //Okay to mark uncompleted, but don't trigger lock of uncompleted lock
                            self.scenario.completed = false
                            self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            tableView.reloadData()
                        } else {
                            //Okay to mark uncompleted AND trigger lock
                            self.scenario.completed = false
                            self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                            tableView.reloadData()
                        }
                    }
                } else {
                    self.scenario.completed = true
                    if self.scenario.unlocks[0] == "ONEOF" {
                        self.performSegue(withIdentifier: "ShowScenarioPicker", sender: self.scenario)
                    } else {
                        self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: true)
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
            //let destinationVC = segue.destination as! UITableViewController
        } else if segue.identifier == "ShowScenarioPicker" {
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.topViewController as! ScenarioPickerViewController
            destinationVC.delegate = self
            destinationVC.scenario = sender as! Scenario
            destinationVC.additionalTitles = getAdditionalTitles(for: destinationVC.scenario)
        }
    }
    
    // Perform segue (Show Scenario Detail when cell is tapped)
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" {
            scenario = filteredScenarios[indexPath.row]
        } else {
            //            scenario = dataModel.allScenarios[indexPath.row]
            //        }
            //Make sure to draw from proper dataModel filter for our indexPath based on segment selection
            switch(scenarioFilterOutlet.selectedSegmentIndex) {
            case 0:
                scenario = dataModel.allScenarios[indexPath.row]
            case 1:
                scenario = dataModel.availableScenarios[indexPath.row]
            case 2:
                scenario = dataModel.completedScenarios[indexPath.row]
            default:
                break
            }
        }
        dataModel.selectedScenario = scenario
        performSegue(withIdentifier: "ShowScenarioDetail", sender: scenario)
        tableView.deselectRow(at: indexPath, animated: true)
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
    func configureRowIcon(for tableView: ScenarioMainCell, with scenario: Scenario) {
        if scenario.completed == true {
            tableView.scenarioRowIcon.image = #imageLiteral(resourceName: "scenarioCompletedIcon")
        } else if scenario.requirementsMet == true && scenario.isUnlocked == true {
            //tableView.scenarioRowIcon.image = #imageLiteral(resourceName: "scenarioAvailableIcon")
        } else {
            tableView.scenarioRowIcon.image = #imageLiteral(resourceName: "scenarioLockedIcon")
        }
        
    }
    func configureTitle(for cell: UITableViewCell, with scenario: Scenario) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = "\(scenario.number)) " + scenario.title
        label.sizeToFit()
    }
    func configureBGColor(for cell: UITableViewCell, with scenario: Scenario) -> UIColor {
        if scenario.completed { // If completed
            return DataModel.sharedInstance.completedBGColor
        } else if scenario.isUnlocked && scenario.requirementsMet { // If available, set color to bright yellow
            return DataModel.sharedInstance.availableBGColor
        } else { // If unavailable, set color to gray
            return DataModel.sharedInstance.unavailableBGColor
        }
    }
    func configureRewardText(for cell: UITableViewCell, with rewards: [String]) {
        let label = cell.viewWithTag(1100) as! UILabel
        // Use extension to Sequence as defined before this class declaration
        label.text = ("Rewards: \(rewards.minimalDescription)")
        label.sizeToFit()
    }
    func configureUnlockedByText(for cell: UITableViewCell, with unlockedBys: [String]) {
        let label = cell.viewWithTag(1500) as! UILabel
        label.text = ("Unlocked By: \(unlockedBys.minimalDescription)")
    }
    func configureAchievesText(for cell: UITableViewCell, with achieves: [String]) {
        let label = cell.viewWithTag(1200) as! UILabel
        label.text = ("Achieves: \(achieves.minimalDescription)")
    }
    func getAdditionalTitles(for scenario: Scenario) -> [(number: String, title: String)] {
        var additionalTitles = [(_:String, _:String)]()
        for scen in scenario.unlocks {
            if scen != "None" && scen != "ONEOF" {
                let lookup = Int(scen)!-1
                additionalTitles.append((name:dataModel.allScenarios[lookup].number, title:dataModel.allScenarios[lookup].title))
            }
        }
        return additionalTitles
    }
    func setPickerData(for scenario: Scenario) {
        pickerData = []
        let additionalTitles = getAdditionalTitles(for: scenario)
        var number = String()
        var myTitle = String()
        for i in 0..<additionalTitles.count {
            number = additionalTitles[i].0
            myTitle = number + " - " + additionalTitles[i].1
            pickerData.append(myTitle)
        }
    }
    func showSelectionAlert(status: String) {
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
        navigationItem.title = "All Scenarios"
    }
    // Search helper functions
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        var scenarioSubset = [Scenario]()
        switch(scenarioFilterOutlet.selectedSegmentIndex) {
        case 0:
            scenarioSubset = dataModel.allScenarios
        case 1:
            scenarioSubset = dataModel.availableScenarios
        case 2:
            scenarioSubset = dataModel.completedScenarios
        default:
            break
        }
        filteredScenarios = scenarioSubset.filter { scenario in return scenario.title.lowercased().contains(searchText.lowercased()) || scenario.achieves.minimalDescription.lowercased().contains(searchText.lowercased()) || scenario.rewards.minimalDescription.lowercased().contains(searchText.lowercased())}
        tableView.reloadData()
    }
    
    // Implement delegate methods for ScenarioPickerViewController
    func scenarioPickerViewControllerDidCancel(_ controller: ScenarioPickerViewController) {
        controller.scenario.completed = false
        dataModel.updateAvailableScenarios(scenario: controller.scenario, isCompleted: false)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func scenarioPickerViewController(_ controller: ScenarioPickerViewController, didFinishPicking scenario: Scenario) {
        if let pickedScenario = controller.pickedScenario?.components(separatedBy: " - ") {
            scenario.unlocks = ["ONEOF", "\(pickedScenario[0])"]
        }
        dataModel.updateAvailableScenarios(scenario: scenario, isCompleted: true)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func segueToDetailViewController(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            let scenarioTapped = dict["Scenario"] as! Scenario
            dataModel.selectedScenario = scenarioTapped
            self.performSegue(withIdentifier: "ShowScenarioDetail", sender: scenarioTapped)
        }
    }

}

