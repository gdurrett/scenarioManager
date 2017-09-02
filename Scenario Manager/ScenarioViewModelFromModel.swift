//
//  ScenarioViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

protocol ScenarioViewModelDelegate: class {
    func presentiCloudConnectionAlert()
}

class ScenarioViewModelFromModel: NSObject, ScenarioViewControllerViewModel {
    
    let dataModel: DataModel
    weak var delegate: ScenarioViewModelDelegate?
    
    var allScenarios: [Scenario]
    let availableScenarios: Dynamic<[Scenario]>
    let completedScenarios: Dynamic<[Scenario]>
    var selectedScenario: Scenario?
    var myAchieves = [String]()
    var scenarioMgrViewBGString = String()
    
    // MARK: Init
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        
        self.allScenarios = dataModel.allScenarios
        self.availableScenarios = Dynamic(dataModel.availableScenarios)
        self.completedScenarios = Dynamic(dataModel.completedScenarios)
        
    }
    // MARK: Helper functions
    func updateAvailableScenarios(scenario: Scenario, isCompleted: Bool) {

        toggleUnlocks(for: scenario, to: isCompleted)
        let completed = allScenarios.filter { $0.isCompleted == true }
        myAchieves = completed.filter { $0.achieves != ["None"] }.flatMap { $0.achieves }
        
        setAchievements(atches: scenario.achieves, toggle: isCompleted)
        // Special case for when we've achieved Drake's Command and Drake's Treasure
        if dataModel.achievements["The Drake's Command"] == true && dataModel.achievements["The Drake's Treasure"] == true {
            dataModel.achievements["The Drake Aided"] = true
        } else {
            dataModel.achievements["The Drake Aided"] = false
        }
        setRequirementsMet()
        
        //Need to re-get after update. Using Dynamic vars!
        self.availableScenarios.value = dataModel.availableScenarios
        self.completedScenarios.value = dataModel.completedScenarios
        dataModel.saveScenariosLocally()
        
    }
    // Test refresh after download of scenario and achievement status. Try calling from viewDidLoad() in scenarioViewController
    func updateAvailableScenarios() {
        self.availableScenarios.value = dataModel.availableScenarios
        self.completedScenarios.value = dataModel.completedScenarios
        dataModel.saveScenariosLocally()
    }
    func setAchievements(atches: [String], toggle: Bool) {
        var remove = false
        for ach in atches {
            if ach == "REMOVE" {
                remove = true
                continue
            }
            if toggle {
                if remove {
                    dataModel.achievements[ach]! = false
                    remove = false
                } else {
                    if !(ach == "None") {
                        dataModel.achievements[ach]! = true
                    }
                }
            } else {
                if remove {
                    dataModel.achievements[ach]! = true
                    remove = false
                } else {
                    if !(ach == "None") && !(myAchieves.contains(ach)){
                        dataModel.achievements[ach]! = false
                    }
                }
            }
        }
    }
    func setRequirementsMet() {
        for scenario in allScenarios {
            let orPresent = scenario.requirements["OR"] == true
            var tempRequirementsArray = scenario.requirements
            tempRequirementsArray.removeValue(forKey: "OR")
            for (ach, bool) in tempRequirementsArray {
                if orPresent {
                    if dataModel.achievements[ach]! == bool {
                        scenario.requirementsMet = true
                        break
                    }
                } else if dataModel.achievements[ach]! != bool && !scenario.isCompleted {
                    scenario.requirementsMet = false
                    break
                } else {
                    scenario.requirementsMet = true
                }
            }
        }
    }
    func toggleUnlocks(for scenario: Scenario, to: Bool) {
        // Don't toggle false if we're already unlocked by a completed scenario
        if to == false && !didAnotherCompletedScenarioUnlockMe(scenario: scenario) {
            //If we're locking a scenario with "ONEOF", we need to restore default unlocks
            if scenario.unlocks.contains("ONEOF") {
                scenario.unlocks = dataModel.defaultUnlocks[scenario.number]!
            }
            for scen in scenario.unlocks {
                if scen != "ONEOF" {
                    if scen == "None" { return }
                    let scenarioToUpdate = getScenario(scenarioNumber: scen)!
                    scenarioToUpdate.isUnlocked = false
                }
            }
        } else { // Go ahead and toggle true
            for scen in scenario.unlocks {
                if scen == "None" { return }
                if scen == "ONEOF" { continue }
                let scenarioToUpdate = getScenario(scenarioNumber: scen)!
                scenarioToUpdate.isUnlocked = true
            }
        }
    }
    func areAnyUnlocksCompleted(scenario: Scenario) -> Bool {
        for scen in scenario.unlocks {
            if let answer = getScenario(scenarioNumber: scen) {
                if answer.isCompleted {
                    return true
                } else {
                    //return false
                    continue
                }
            }
        }
        return false
    }
    func didAnotherCompletedScenarioUnlockMe(scenario: Scenario) -> Bool {
        // Look at calling scenario's unlocks
        for unlock in scenario.unlocks {
            if !(unlock == "None") && !(unlock == "ONEOF") {
                // For each unlock, look at its unlockers (unlockedBy) - need to ignore Events though!
                for unlockedBy in getScenario(scenarioNumber: unlock)!.unlockedBy {
                    if !(unlockedBy.contains("Event")) && !(unlockedBy.contains("Envelope")) {
                        if (getScenario(scenarioNumber: unlockedBy)!.number == scenario.number) {
                            continue
                        } else {
                            if getScenario(scenarioNumber: unlockedBy)!.isCompleted {
                                return true
                            } else {
                                return false
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    func getScenario(scenarioNumber: String) -> Scenario? {
        
        if scenarioNumber == "None" || scenarioNumber == "ONEOF" {
            return nil
        } else {
            let scenInt = Int(scenarioNumber)!-1
            let scenario = allScenarios[scenInt]
            
            return scenario
        }
    }
    func getAdditionalTitles(for scenario: Scenario) -> [(number: String, title: String)] {
        var additionalTitles = [(_:String, _:String)]()
        for scen in scenario.unlocks {
            if scen != "None" && scen != "ONEOF" {
                let lookup = Int(scen)!-1
                additionalTitles.append((name:(self.allScenarios[lookup].number), title:(self.allScenarios[lookup].title)))
            }
        }
        return additionalTitles
    }
}
