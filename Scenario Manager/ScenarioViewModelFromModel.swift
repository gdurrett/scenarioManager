//
//  ScenarioViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation


class ScenarioViewModelFromModel: NSObject, ScenarioViewControllerViewModel {
    
    let dataModel: DataModel
    
    var allScenarios: [Scenario]
    var availableScenarios: [Scenario]
    var completedScenarios: [Scenario]
    var selectedScenario: Scenario?
    var myAchieves = [String]()
    
    // MARK: Init
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        
        self.allScenarios = dataModel.allScenarios
        self.availableScenarios = dataModel.availableScenarios
        self.completedScenarios = dataModel.completedScenarios
    }
    // MARK: Helper functions
    func updateAvailableScenarios(scenario: Scenario, isCompleted: Bool) {
        
        toggleUnlocks(for: scenario, to: isCompleted)
        let completed = allScenarios.filter { $0.completed == true }
        myAchieves = completed.filter { $0.achieves != ["None"] }.flatMap { $0.achieves }
        
        setAchievements(atches: scenario.achieves, toggle: isCompleted)
        setRequirementsMet()
        
        dataModel.saveScenarios()
        
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
                } else if dataModel.achievements[ach]! != bool && !scenario.completed {
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
                    getScenario(scenarioNumber: scen)?.isUnlocked = false
                }
            }
        } else { // Go ahead and toggle true
            for scen in scenario.unlocks {
                getScenario(scenarioNumber: scen)?.isUnlocked = true
            }
        }
    }
    func areAnyUnlocksCompleted(scenario: Scenario) -> Bool {
        for scen in scenario.unlocks {
            if let answer = getScenario(scenarioNumber: scen) {
                if answer.completed {
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
                // For each unlock, look at its unlockers (unlockedBy)
                for unlockedBy in getScenario(scenarioNumber: unlock)!.unlockedBy {
                    if (getScenario(scenarioNumber: unlockedBy)!.number == scenario.number) {
                        continue
                    } else {
                        if getScenario(scenarioNumber: unlockedBy)!.completed {
                            return true
                        } else {
                            return false
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
}
