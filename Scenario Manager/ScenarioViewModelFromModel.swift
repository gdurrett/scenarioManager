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
    var campaign: Dynamic<Campaign>
    let availableScenarios: Dynamic<[Scenario]>
    let completedScenarios: Dynamic<[Scenario]>
    var selectedScenario: Scenario?
    var myAchieves = [String]()
    var scenarioMgrViewBGString = String()
    
    // MARK: Init
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.allScenarios = dataModel.allScenarios
        //self.campaign = dataModel.currentCampaign!
        self.campaign = Dynamic(dataModel.currentCampaign)
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
        self.campaign.value = dataModel.currentCampaign
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
                    campaign.value.achievements[ach]! = false
                    remove = false
                } else {
                    if !(ach == "None") {
                        dataModel.achievements[ach]! = true
                        campaign.value.achievements[ach]! = true
                    }
                }
            } else {
                if remove {
                    dataModel.achievements[ach]! = true
                    campaign.value.achievements[ach]! = true
                    remove = false
                } else {
                    if !(ach == "None") && !(myAchieves.contains(ach)){
                        dataModel.achievements[ach]! = false
                        campaign.value.achievements[ach]! = false
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
                        campaign.value.requirementsMet[Int(scenario.number)! - 1] = true
                        break
                    }
                } else if dataModel.achievements[ach]! != bool && !scenario.isCompleted {
                    scenario.requirementsMet = false
                    campaign.value.requirementsMet[Int(scenario.number)! - 1] = false
                    break
                } else {
                    scenario.requirementsMet = true
                    campaign.value.requirementsMet[Int(scenario.number)! - 1] = true
                }
            }
        }
    }
    func toggleUnlocks(for scenario: Scenario, to: Bool) {
        // If we're trying to set to uncompleted
        if to == false {
            // Check each of this scenarios unlocks to see if another completed scenario has unlocked this unlock
            for unlock in scenario.unlocks {
                // Send each unlock to see, but only if unlock is a scenario
                if (unlock == "None") { return }
                if (unlock == "ONEOF") { scenario.unlocks = dataModel.defaultUnlocks[scenario.number]! ; continue }
                let scenarioToUpdate = getScenario(scenarioNumber: unlock)!
                if didAnotherCompletedScenarioUnlockMe(unlockToCheck: scenarioToUpdate, sendingScenario: scenario) {
                    // This unlock is unlocked by another completed scenario, so OK to set unlocked
                    scenarioToUpdate.isUnlocked = true
                    campaign.value.isUnlocked[Int(scenarioToUpdate.number)! - 1] = true
                } else {
                    // This unlock is not unlocked by another completed scenario, so NOT OK to set unlocked
                    scenarioToUpdate.isUnlocked = false
                    campaign.value.isUnlocked[Int(scenarioToUpdate.number)! - 1] = false
                }
            }
        } else { // Go ahead and toggle true
            for scen in scenario.unlocks {
                if scen == "None" { return }
                if scen == "ONEOF" { continue }
                let scenarioToUpdate = getScenario(scenarioNumber: scen)!
                scenarioToUpdate.isUnlocked = true
                campaign.value.isUnlocked[Int(scenarioToUpdate.number)! - 1] = true
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
    func didAnotherCompletedScenarioUnlockMe(unlockToCheck: Scenario, sendingScenario: Scenario) -> Bool {
        for unlockedBy in unlockToCheck.unlockedBy {
            // If unlockedBy is the sending scenario, ignore and move on to next unlock
            if unlockedBy == sendingScenario.number { continue }
            if !(unlockedBy.contains("Event")) && !(unlockedBy.contains("Envelope")) {
                let unlockedBy = getScenario(scenarioNumber: unlockedBy)
                if unlockedBy!.isCompleted {
                    return true
                } else {
                    return false
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
