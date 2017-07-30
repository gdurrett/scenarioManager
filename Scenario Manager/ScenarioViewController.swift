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

class ScenarioViewController: UITableViewController, ScenarioPickerViewControllerDelegate {

    @IBOutlet weak var scenarioFilterOutlet: UISegmentedControl!
    
    @IBAction func scenarioFilterAction(_ sender: Any) {
        tableView.reloadData()
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
    }
    
    var dataModel: DataModel!
    var myCompletedTitle: String?
    var bgColor: UIColor?
    var pickerData = [String]()
    var chosenScenario: Scenario?
    var scenario: Scenario!
    let completedBGColor = UIColor(hue: 9/360, saturation: 59/100, brightness: 100/100, alpha: 1.0)
    let availableBGColor = UIColor(hue: 48/360, saturation: 100/100, brightness: 100/100, alpha: 1.0)
    let unavailableBGColor = UIColor(hue: 99/360, saturation: 2/100, brightness: 75/100, alpha: 1.0)
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        switch(scenarioFilterOutlet.selectedSegmentIndex) {
        case 0:
            returnValue = dataModel.allScenarios.count
        case 1:
            returnValue = dataModel.completedScenarios.count
        case 2:
            returnValue = dataModel.availableScenarios.count
        default:
            break
        }
        return returnValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        
        switch(scenarioFilterOutlet.selectedSegmentIndex) {
        case 0:
            scenario = dataModel.allScenarios[indexPath.row]
        case 1:
            scenario = dataModel.completedScenarios[indexPath.row]
        case 2:
            scenario = dataModel.availableScenarios[indexPath.row]
        default:
            break
        }
        configureTitle(for: cell, with: scenario)
        cell.backgroundColor = configureBGColor(for: cell, with: scenario)
        configureRewardText(for: cell, with: scenario.rewards)
        configureAchievesText(for: cell, with: dataModel.getAchieves(for: scenario))
        
        return cell
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // Set up swipe functionality
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        switch(scenarioFilterOutlet.selectedSegmentIndex) {
        case 0:
            scenario = dataModel.allScenarios[editActionsForRowAt.row]
        case 1:
            scenario = dataModel.completedScenarios[editActionsForRowAt.row]
        case 2:
            scenario = dataModel.availableScenarios[editActionsForRowAt.row]
        default:
            break
        }
        if scenario.completed {
            myCompletedTitle = "Uncompleted"
            bgColor = .red
        } else if scenario.isUnlocked && scenario.requirementsMet  {
            myCompletedTitle = "Completed"
            bgColor = UIColor(displayP3Red: 0.3, green: 0.9, blue: 0.3, alpha: 0.8)
        } else {
            myCompletedTitle = "Unavailable"
            bgColor = .gray
        }
        let swipeToggleComplete = UITableViewRowAction(style: .normal, title: myCompletedTitle) { action, index in
            if self.scenario.completed {
                if self.dataModel.areAnyUnlocksCompleted(scenario: self.scenario) {
                    if self.dataModel.didAnotherCompletedScenarioUnlockMe(scenario: self.scenario) {
                        //Okay to mark uncompleted, but don't trigger lock
                        self.scenario.completed = false
                        self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                        tableView.reloadData()
                    } else {
                        //NOT okay to mark uncompleted
                        self.showSelectionAlert()
                    }
                } else if !self.dataModel.areAnyUnlocksCompleted(scenario: self.scenario) {
                    print("None of my unlocks completed!")
                    if self.dataModel.didAnotherCompletedScenarioUnlockMe(scenario: self.scenario) {
                        //Okay to mark uncompleted, but don't trigger lock of uncompleted lock
                        self.scenario.completed = false
                        self.dataModel.updateAvailableScenarios(scenario: self.scenario, isCompleted: false)
                        tableView.reloadData()
                    } else {
                        //Okay to mark uncompleted AND trigger lock
                        print("Do I ever get here?")
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
        }
        swipeToggleComplete.backgroundColor = bgColor
        return [swipeToggleComplete]
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
        //Make sure to draw from proper dataModel filter for our indexPath based on segment selection
        switch(scenarioFilterOutlet.selectedSegmentIndex) {
        case 0:
            scenario = dataModel.availableScenarios[indexPath.row]
        case 1:
            scenario = dataModel.completedScenarios[indexPath.row]
        case 2:
            scenario = dataModel.allScenarios[indexPath.row]
        default:
            break
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
    func configureTitle(for cell: UITableViewCell, with scenario: Scenario) {
        let label = cell.viewWithTag(1000) as! UILabel
        label.text = "\(scenario.number)) " + scenario.title
    }
    func configureBGColor(for cell: UITableViewCell, with scenario: Scenario) -> UIColor {
        if scenario.completed { // If completed, set color to salmon
            return completedBGColor
        } else if scenario.isUnlocked && scenario.requirementsMet { // If available, set color to bright yellow
            return availableBGColor
        } else { // If unavailable, set color to gray
            return unavailableBGColor
        }
    }
    func configureRewardText(for cell: UITableViewCell, with rewards: [String]) {
        let label = cell.viewWithTag(1100) as! UILabel
        // Use extension to Sequence as defined before this class declaration
            label.text = ("Rewards: \(rewards.minimalDescription)")
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
    func showSelectionAlert() {
        let alertView = UIAlertController(
            title: "Cannot set to Uncompleted!",
            message: nil,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        
        alertView.addAction(action)
        present(alertView, animated: true, completion: { _ in
        })
    }
    // Implement delegate methods for ScenarioDetailViewController
    func scenarioDetailViewControllerDidCancel(_ controller: ScenarioDetailViewController) {
        dismiss(animated: true, completion: nil)
    }

    func scenarioDetailViewController(_ controller: ScenarioDetailViewController, didFinishEditing scenario: Scenario) {
        dismiss(animated: true, completion: nil)
    }
    
    // Implement delegate methods for ScenarioPickerViewController
    func scenarioPickerViewControllerDidCancel(_ controller: ScenarioPickerViewController) {
        controller.scenario.completed = false
        dataModel.updateAvailableScenarios(scenario: controller.scenario, isCompleted: false)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func scenarioPickerViewController(_ controller: ScenarioPickerViewController, didFinishPicking scenario: Scenario) {
        if let chosenScenario = controller.chosenScenario?.components(separatedBy: " - ") {
            scenario.unlocks = ["ONEOF", "\(chosenScenario[0])"]
        }
        dataModel.updateAvailableScenarios(scenario: scenario, isCompleted: true)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}

