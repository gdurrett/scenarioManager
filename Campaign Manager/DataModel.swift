//
//  DataModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/3/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

//Test iCloud update error messaging
enum myCKErrorType {
    case saveAchievement
    case updateLocalAchievement
    case saveScenarioStatus
    case updateLocalScenario
    case fetchRecord
}
protocol DataModelDelegate {
    func errorUpdating(error: CKError, type:myCKErrorType)
    func showProgressHUD()
    func hideProgressHUD()
    func darkenViewBGColor()
    func restoreViewBGColor()
}
extension Dictionary {
    mutating func changeKey(from: Key, to: Key) {
        self[to] = self[from]
        self.removeValue(forKey: from)
    }
}
class DataModel {
    
    // Try singleton
    static var sharedInstance = DataModel()
    
    var availableScenarios: [Scenario] {
        get {
            return allScenarios.filter { $0.isUnlocked == true && $0.requirementsMet == true && $0.isCompleted == false }
        }
    }
    var completedScenarios: [Scenario] {
        get {
            return allScenarios.filter { $0.isCompleted == true }
        }
    }
    var completedGlobalAchievements: [String:Bool] {
        get {
            return currentCampaign.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
        }
    }
    var completedPartyAchievements: [String:Bool] {
        get {
            return currentParty.achievements.filter { $0.value != false && $0.key != "None" && $0.key != "OR" }
        }
    }
    var assignedParties: [Party]? {
        get {
            var tempParties = [Party]()
            if currentCampaign.parties?.isEmpty != true {
                for party in currentCampaign.parties! {
                    tempParties.append(party)
                }
            } else {
                return nil
                //tempParties.append(Party(name: "None", characters: [], location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: false, assignedTo: "None"))
            }
            return tempParties
        }
    }
    var availableParties: [Party]? {
        get {
            var tempParties = [Party]()
            for party in self.parties {
                if party.value.assignedTo == "None" {
                    tempParties.append(party.value)
                } else {
                }
            }
            return tempParties
        }
    }
    var assignedCharacters: [Character] {
        get {
            var tempCharacters = [Character]()
            for character in characters.values {
                if character.assignedTo == self.currentParty.name {
                    tempCharacters.append(character)
                }
            }
            return tempCharacters
        }
    }
//    var retiredCharacters: [Character] {
//        get {
//            var tempCharacters = [Character]()
//            for character in characters.values {
//                if character.assignedTo == "None" && character.isRetired == true {
//                    tempCharacters.append(character)
//                }
//            }
//            return tempCharacters
//        }
//    }
    var availableCharacters: [Character] {
        get {
            var tempCharacters = [Character]()
            for character in self.characters.values {
                if character.assignedTo == "None" && character.isRetired != true {
                    tempCharacters.append(character)
                } else {
                    
                }
            }
            return tempCharacters
        }
    }
    var currentCampaign: Campaign {
        get {
            let filtered = campaigns.filter { pair in pair.value.isCurrent == true }
            
            if let myCampaign = filtered.values.first {
                // Remove unneeded MyCampaign
                if self.campaigns["MyCampaign"] != nil {
                    self.campaigns.removeValue(forKey: "MyCampaign")
                }
                return myCampaign
            } else {
                if self.campaigns["MyCampaign"] == nil {
                    createDefaultCampaign()
                }
                return campaigns["MyCampaign"]!
            }
        }
    }
    var currentCampaignNotes: String {
        get {
            return currentCampaign.notes
        }
        set {
            currentCampaign.notes = newValue
        }
    }
    var assignedCampaign: String { // campaign assigned to currentParty
        get {
            return currentParty.assignedTo
        }
    }
    var availableCampaigns: [String] {
        get {
            var tempCampaignTitles = [String]()
            for campaign in self.campaigns {
                if campaign.value.parties!.isEmpty {
                    tempCampaignTitles.append(campaign.value.title)
                }
            }
            return tempCampaignTitles
        }
    }
    var unavailableEvents: [Event] {
        get {
            return currentCampaign.events.filter { $0.isAvailable != true && $0.isCompleted != true }
        }
    }
    var availableEvents: [Event] {
        get {
            return currentCampaign.events.filter { $0.isAvailable == true }
        }
    }
    var completedEvents: [Event] {
        get {
            return currentCampaign.events.filter { $0.isCompleted == true }
        }
    }
    var currentParty: Party! {
        get {
            let filtered = parties.filter { pair in pair.value.isCurrent == true }
            if let myParty = filtered.values.first  {
                return myParty
            } else {
                if self.parties["MyParty"] == nil {
                    createParty(name: "MyParty", characters: [], location: "Gloomhaven", achievements: createPartyAchievements(), reputation: 0, isCurrent: true, assignedTo: "MyCampaign", notes: "Notes Here")
                }
                return parties["MyParty"]
            }
        }
        set {
            for thisParty in self.parties.values {
                thisParty.isCurrent = false
            }
            newValue.isCurrent = true
            loadParty(party: newValue.name)
        }
    }
    var currentPartyNotes: String {
        get {
            return currentParty.notes
        }
        set {
            currentParty.notes = newValue
        }
    }
    var allScenarios = [Scenario]()
    //var achievements = [ String : Bool ]()
    var globalAchievements = [String:Bool]()
    var partyAchievements = [String:Bool]()
    var requirementsMet = false
    var myAchieves = [String]()
    var or = false
    var unlocksLabel = String()
    var selectedScenario: Scenario?
    var mainCellBGImage = UIImage()
    var delegate: DataModelDelegate?
    
    // Campaigns
    var campaigns = [String: Campaign]()
    var defaultCampaign: Campaign?
    
    // Events
    var events = [Event]()

    // Parties
    var parties = [String: Party]()
    
    // Characters
    var characters = [String : Character]()

    var availableCharacterTypes: [String] {
        get {
            let availableCharTypes = currentCampaign.availableCharacterTypes.filter { $0.value == true }
            return Array(availableCharTypes.keys)
        }
    }
    var lockedCharacterTypes: [String] {
        get {
            let lockedCharTypes = currentCampaign.availableCharacterTypes.filter { $0.value == false }
            return Array(lockedCharTypes.keys)
        }
    }
    var availableCharacterTypesAttributed: [SeparatedAttributedStrings] {
        get {
            var tempTypes = [SeparatedAttributedStrings]()
            let tempVal = currentCampaign.availableCharacterTypes.filter({ $0.value == true })
            for myType in tempVal.keys {
                let type = myType.replacingOccurrences(of: "\u{fffc}", with: "")
                if type == "BeastTyrant" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: beastTyrantString))
                } else if type == "Berserker" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: berserkerString))
                } else if type == "Brute" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: bruteString))
                } else if type == "Cragheart" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: cragheartString))
                } else if type == "Doomstalker" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: doomstalkerString))
                } else if type == "Elementalist" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: elementalistString))
                } else if type == "Mindthief" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: mindthiefString))
                } else if type == "Nightshroud" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: nightshroudString))
                } else if type == "Plagueherald" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: plagueheraldString))
                } else if type == "Quartermaster" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: quartermasterString))
                } else if type == "Sawbones" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: sawbonesString))
                } else if type == "Scoundrel" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: scoundrelString))
                } else if type == "Soothsinger" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: soothsingerString))
                } else if type == "Spellweaver" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: spellweaverString))
                } else if type == "Summoner" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: summonerString))
                } else if type == "Sunkeeper" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: sunkeeperString))
                } else if type == "Tinkerer" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: tinkererString))
                } else {
                    print("Doesn't look like anything to me: \(myType)")
                }
            }
            return tempTypes
        }
    }
    var lockedCharacterTypesAttributed: [SeparatedAttributedStrings] {
        get {
            var tempTypes = [SeparatedAttributedStrings]()
            for type in currentCampaign.availableCharacterTypes.filter ({ $0.value == false }).keys {
                
                //let type = myType.replacingOccurrences(of: "\u{fffc}", with: "")
                if type == "Beast Tyrant" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: beastTyrantString))
                } else if type == "Berserker" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: berserkerString))
                } else if type == "Brute" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: bruteString))
                } else if type == "Cragheart" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: cragheartString))
                } else if type == "Doomstalker" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: doomstalkerString))
                } else if type == "Elementalist" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: elementalistString))
                } else if type == "Mindthief" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: mindthiefString))
                } else if type == "Nightshroud" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: nightshroudString))
                } else if type == "Plagueherald" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: plagueheraldString))
                } else if type == "Quartermaster" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: quartermasterString))
                } else if type == "Sawbones" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: sawbonesString))
                } else if type == "Scoundrel" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: scoundrelString))
                } else if type == "Soothsinger" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: soothsingerString))
                } else if type == "Spellweaver" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: spellweaverString))
                } else if type == "Summoner" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: summonerString))
                } else if type == "Sunkeeper" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: sunkeeperString))
                } else if type == "Tinkerer" {
                    tempTypes.append(SeparatedAttributedStrings(rowString: tinkererString))
                } else {
                    print("Doesn't look like anything to me: \(type)")
                }
            }
            return tempTypes
        }
    }
    var beastTyrantString, berserkerString, bruteString, cragheartString, doomstalkerString, elementalistString, mindthiefString, nightshroudString, plagueheraldString, quartermasterString, sawbonesString, scoundrelString, soothsingerString, spellweaverString, summonerString, sunkeeperString, tinkererString : NSMutableAttributedString

    
    // Store newly-created characters, campaign name, and partyname
    var newCharacters = [String : Character]()
    var newCampaignName = String()
    var newPartyName = String()
    
    // Get a CloudKit object
    let myCloudKitMgr = CloudKitMgr()
    
    
    // Used when we uncomplete scenario 13 to restore unlock options
    let defaultUnlocks = [ "13" : ["ONEOF", "15", "17", "20"] ]
    
    private init() {
        let resizePercentage = CGFloat(0.7)
        
        // Create characterType attributed strings
        beastTyrantString = NSMutableAttributedString(string: "  Beast Tyrant")
        let beastTyrantImageAttachment = NSTextAttachment()
        //beastTyrantImageAttachment.image = UIImage(named: "beastTyrantIcon.png")
        beastTyrantImageAttachment.image = UIImage(named: "beastTyrantIcon.png")?.resizeWith(percentage: resizePercentage)
        let beastTyrantImageString = NSAttributedString(attachment: beastTyrantImageAttachment)
        beastTyrantString.insert(beastTyrantImageString, at: 0)
        
        berserkerString = NSMutableAttributedString(string: "  Berserker")
        let berserkerImageAttachment = NSTextAttachment()
        berserkerImageAttachment.image = UIImage(named: "berserkerIcon.png")?.resizeWith(percentage: resizePercentage)
        let berserkerImageString = NSAttributedString(attachment: berserkerImageAttachment)
        berserkerString.insert(berserkerImageString, at: 0)
        
        bruteString = NSMutableAttributedString(string: "  Brute")
        let bruteImageAttachment = NSTextAttachment()
        bruteImageAttachment.image = UIImage(named: "bruteIcon.png")?.resizeWith(percentage: resizePercentage)
        let bruteImageString = NSAttributedString(attachment: bruteImageAttachment)
        bruteString.insert(bruteImageString, at: 0)
        
        cragheartString = NSMutableAttributedString(string: "  Cragheart")
        let cragheartImageAttachment = NSTextAttachment()
        cragheartImageAttachment.image = UIImage(named: "cragheartIcon.png")?.resizeWith(percentage: resizePercentage)
        let cragheartImageString = NSAttributedString(attachment: cragheartImageAttachment)
        cragheartString.insert(cragheartImageString, at: 0)
        
        doomstalkerString = NSMutableAttributedString(string: "  Doomstalker")
        let doomstalkerImageAttachment = NSTextAttachment()
        doomstalkerImageAttachment.image = UIImage(named: "doomstalkerIcon.png")?.resizeWith(percentage: resizePercentage)
        let doomstalkerImageString = NSAttributedString(attachment: doomstalkerImageAttachment)
        doomstalkerString.insert(doomstalkerImageString, at: 0)
        
        elementalistString = NSMutableAttributedString(string: "  Elementalist")
        let elementalistImageAttachment = NSTextAttachment()
        elementalistImageAttachment.image = UIImage(named: "elementalistIcon.png")?.resizeWith(percentage: resizePercentage)
        let elementalistImageString = NSAttributedString(attachment: elementalistImageAttachment)
        elementalistString.insert(elementalistImageString, at: 0)
        
        mindthiefString = NSMutableAttributedString(string: "  Mindthief")
        let mindthiefImageAttachment = NSTextAttachment()
        mindthiefImageAttachment.image = UIImage(named: "mindthiefIcon.png")?.resizeWith(percentage: resizePercentage)
        let mindthiefImageString = NSAttributedString(attachment: mindthiefImageAttachment)
        mindthiefString.insert(mindthiefImageString, at: 0)
        
        nightshroudString = NSMutableAttributedString(string: "  Nightshroud")
        let nightshroudImageAttachment = NSTextAttachment()
        nightshroudImageAttachment.image = UIImage(named: "nightshroudIcon.png")?.resizeWith(percentage: resizePercentage)
        let nightshroudImageString = NSAttributedString(attachment: nightshroudImageAttachment)
        nightshroudString.insert(nightshroudImageString, at: 0)
        
        plagueheraldString = NSMutableAttributedString(string: "  Plagueherald")
        let plagueheraldImageAttachment = NSTextAttachment()
        plagueheraldImageAttachment.image = UIImage(named: "plagueheraldIcon.png")?.resizeWith(percentage: resizePercentage)
        let plagueheraldImageString = NSAttributedString(attachment: plagueheraldImageAttachment)
        plagueheraldString.insert(plagueheraldImageString, at: 0)
        
        quartermasterString = NSMutableAttributedString(string: "  Quartermaster")
        let quartermasterImageAttachment = NSTextAttachment()
        quartermasterImageAttachment.image = UIImage(named: "quartermasterIcon.png")?.resizeWith(percentage: resizePercentage)
        let quartermasterImageString = NSAttributedString(attachment: quartermasterImageAttachment)
        quartermasterString.insert(quartermasterImageString, at: 0)
        
        sawbonesString = NSMutableAttributedString(string: "  Sawbones")
        let sawbonesImageAttachment = NSTextAttachment()
        sawbonesImageAttachment.image = UIImage(named: "sawbonesIcon.png")?.resizeWith(percentage: resizePercentage)
        let sawbonesImageString = NSAttributedString(attachment: sawbonesImageAttachment)
        sawbonesString.insert(sawbonesImageString, at: 0)
        
        scoundrelString = NSMutableAttributedString(string: "  Scoundrel")
        let scoundrelImageAttachment = NSTextAttachment()
        scoundrelImageAttachment.image = UIImage(named: "scoundrelIcon.png")?.resizeWith(percentage: resizePercentage)
        let scoundrelImageString = NSAttributedString(attachment: scoundrelImageAttachment)
        scoundrelString.insert(scoundrelImageString, at: 0)
        
        soothsingerString = NSMutableAttributedString(string: "  Soothsinger")
        let soothsingerImageAttachment = NSTextAttachment()
        soothsingerImageAttachment.image = UIImage(named: "soothsingerIcon.png")?.resizeWith(percentage: resizePercentage)
        let soothsingerImageString = NSAttributedString(attachment: soothsingerImageAttachment)
        soothsingerString.insert(soothsingerImageString, at: 0)
        
        spellweaverString = NSMutableAttributedString(string: "  Spellweaver")
        let spellweaverImageAttachment = NSTextAttachment()
        spellweaverImageAttachment.image = UIImage(named: "spellweaverIcon.png")?.resizeWith(percentage: resizePercentage)
        let spellweaverImageString = NSAttributedString(attachment: spellweaverImageAttachment)
        spellweaverString.insert(spellweaverImageString, at: 0)
        
        summonerString = NSMutableAttributedString(string: "  Summoner")
        let summonerImageAttachment = NSTextAttachment()
        summonerImageAttachment.image = UIImage(named: "summonerIcon.png")?.resizeWith(percentage: resizePercentage)
        let summonerImageString = NSAttributedString(attachment: summonerImageAttachment)
        summonerString.insert(summonerImageString, at: 0)
        
        sunkeeperString = NSMutableAttributedString(string: "  Sunkeeper")
        let sunkeeperImageAttachment = NSTextAttachment()
        sunkeeperImageAttachment.image = UIImage(named: "sunkeeperIcon.png")?.resizeWith(percentage: resizePercentage)
        let sunkeeperImageString = NSAttributedString(attachment: sunkeeperImageAttachment)
        sunkeeperString.insert(sunkeeperImageString, at: 0)
        
        tinkererString = NSMutableAttributedString(string: "  Tinkerer")
        let tinkererImageAttachment = NSTextAttachment()
        tinkererImageAttachment.image = UIImage(named: "tinkererIcon.png")?.resizeWith(percentage: resizePercentage)
        let tinkererImageString = NSAttributedString(attachment: tinkererImageAttachment)
        tinkererString.insert(tinkererImageString, at: 0)
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("Campaigns.plist")?.path
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath!){
            loadCampaignsFromLocal()
            setCampaignsAndParties()
//            for campaign in campaigns {
//                if campaign.value.isCurrent == true {
//                    loadCampaign(campaign: campaign.key)
//                    break
//                }
//            }
//            for party in parties {
//                if party.value.isCurrent == true {
//                    loadParty(party: party.key)
//                    break
//                }
//            }
        } else {
            
            let scenario44String = NSMutableAttributedString(string: "Open envelope ")
            let image44Attachment = NSTextAttachment()
            image44Attachment.image = UIImage(named: "doomstalkerIcon.png")?.resizeWith(percentage: resizePercentage)
            let image44String = NSAttributedString(attachment: image44Attachment)
            scenario44String.append(image44String)
            
            let scenario54String = NSMutableAttributedString(string: "Open envelope ")
            let image54Attachment = NSTextAttachment()
            image54Attachment.image = UIImage(named: "plagueheraldIcon.png")?.resizeWith(percentage: resizePercentage)
            let image54String = NSAttributedString(attachment: image54Attachment)
            scenario54String.append(image54String)
            
            let scenario62String = NSMutableAttributedString(string: "Open envelope ")
            let image62Attachment = NSTextAttachment()
            image62Attachment.image = UIImage(named: "nightshroudIcon.png")?.resizeWith(percentage: resizePercentage)
            let image62String = NSAttributedString(attachment: image62Attachment)
            scenario62String.append(image62String)
            
            let row0Scenario = Scenario(
                number: "1",
                title: "The Black Barrow",
                isCompleted: false,
                requirementsMet: true,
                requirements: ["None": true],
                isUnlocked: true,
                unlockedBy: ["None"],
                unlocks: ["2"],
                achieves: ["First Steps"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill All Enemies.\n\nYou’ve just arrived in town, and you’re hungry for action. And food. Retrieve some stolen documents for Jekserah, a Valrath merchant.",
                locationString: "G-10, Corpsewood",
                linksTo: ["2 - Barrow Lair"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row0Scenario)
            
            let row1Scenario = Scenario(
                number: "2",
                title: "Barrow Lair",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["First Steps": true],
                isUnlocked: false, unlockedBy: ["1"],
                unlocks: ["3", "4"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Kill Bandit Commander and all revealed enemies.\n\nPursue the Bandit Commander deeper into the Barrow.",
                locationString: "G-11, Corpsewood",
                linksTo: ["1 - Black Barrow"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row1Scenario)

            let row2Scenario = Scenario(
                number: "3",
                title: "Inox Encampment",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Merchant Flees": false],
                isUnlocked: false,
                unlockedBy: ["2"],
                unlocks: ["8", "9"],
                achieves: ["Jekserah's Plans"],
                rewards: [NSAttributedString(string: "15 Gold Each"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Kill a number of enemies equal to five times the number of characters.\n\nJekserah would like you to deal with a band of Inox that have been harassing her trade caravans.",
                locationString: "G-3, Dagger Forest",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row2Scenario)

            let row3Scenario = Scenario(
                number: "4",
                title: "Crypt of the Damned",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["2"],
                unlocks: ["5", "6"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies.\n\nBefore killing the Bandit Commander in the Barrow Lair, he mentioned something about the 'Gloom'. This might be a place we could learn more about it.",
                locationString: "E-11, Still River",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row3Scenario)

            let row4Scenario = Scenario(
                number: "5",
                title: "Ruinous Crypt",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["4"],
                unlocks: ["10", "14", "19"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies.\n\nThe script you found in the Crypt of the Damned led you here, where it seems the Cultists are channeling Demons through an infernal portal. You can disrupt their plans by closing the rift.",
                locationString: "D-6, Stone Road",
                linksTo: ["10 - Plane of Elemental Power"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row4Scenario)

            let row5Scenario = Scenario(
                number: "6",
                title: "Decaying Crypt",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["4"],
                unlocks: ["8"],
                achieves: ["Jekserah's Plans", "Dark Bounty"],
                rewards: [NSAttributedString(string: "5 Gold Each")],
                summary: "Goal: Reveal the M tile and kill all revealed enemies.\n\nYou decide to lend the Cultists a hand and clear out some undead that have taken up residence at an important area of power.",
                locationString: "F-10, Still River",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row5Scenario)

            let row6Scenario = Scenario(
                number: "7",
                title: "Vibrant Grotto",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Power of Enhancement": true, "The Merchant Flees": true],
                isUnlocked: false,
                unlockedBy: ["8"],
                unlocks: ["20"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Loot all treasure tiles.\n\nJekserah's gotten away, unfortunately, but the City Guard Argeise told you about an Aesther Enchanter named Hail who might be able to help. You'll have to fetch her some Biteroot first, however.",
                locationString: "C-12, Copperneck Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row6Scenario)

            let row7Scenario = Scenario(
                number: "8",
                title: "Gloomhaven Warehouse",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Jekserah's Plans": true, "The Dead Invade": false],
                isUnlocked: false,
                unlockedBy: ["3", "6"],
                unlocks: ["7", "13", "14"],
                achieves: ["The Merchant Flees"],
                rewards: [NSAttributedString(string: "+2 Reputation")],
                summary: "Goal: Kill both Inox bodyguards.\n\nA menacing figure has offered to exonerate your team of murder if you bring him Jekserah's head. She's hiding in the warehouse with more of her baddies, most likely.",
                locationString: "C-18, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row7Scenario)

            let row8Scenario = Scenario(
                number: "9",
                title: "Diamond Mine",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Merchant Flees": false],
                isUnlocked: false,
                unlockedBy: ["3"],
                unlocks: ["11", "12"],
                achieves: ["The Dead Invade"],
                rewards: [NSAttributedString(string: "20 Gold Each"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Kill the Merciless Overseer and loot the treasure tile.\n\nBack at the Inox Encampment, Argeise warned you about this place, but you have dollar signs in your eyes. Take down the big guy and reap the rewards.",
                locationString: "L-2, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row8Scenario)

            let row9Scenario = Scenario(
                number: "10",
                title: "Plane of Elemental Power",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Rift Neutralized": false],
                isUnlocked: false,
                unlockedBy: ["5"],
                unlocks: ["21", "22"],
                achieves: ["A Demon's Errand"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies.\n\nYou step through the portal back in the Ruinous Crypt and end up here, wherever that is. You need to venture deeper, and to do that you'll have to kill a lot of bad guys.",
                locationString: "C-7, Stone Road",
                linksTo: ["5 - Ruinous Crypt", "21 - Infernal Throne"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row9Scenario)

            let row10Scenario = Scenario(
                number: "11",
                title: "Gloomhaven Square A",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["End of the Invasion": false],
                isUnlocked: false,
                unlockedBy: ["9"],
                unlocks: ["16", "18"],
                achieves: ["City Rule: Economic", "End of the Invasion"],
                rewards: [NSAttributedString(string: "15 Gold Each"), NSAttributedString(string: "-2 Reputation"), NSAttributedString(string: "+2 Prosperity")],
                summary: "Goal: Kill the Captain of the Guard.\n\nYou decide to go in with Jekserah, and help her take down the City Guard, placing town rule into the Merchants' hands.",
                locationString: "B-16, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row10Scenario)

            let row11Scenario = Scenario(
                number: "12",
                title: "Gloomhaven Square B",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["End of the Invasion": false],
                isUnlocked: false,
                unlockedBy: ["9"],
                unlocks: ["16", "18", "28"],
                achieves: ["End of the Invasion"],
                rewards: [NSAttributedString(string: "+4 Reputation")],
                summary: "Goal: Kill Jekserah.\n\nYou throw in your lot with the City Guard and attempt to hold the square against Jekserah's armies of undead.",
                locationString: "B-16, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row11Scenario)

            let row12Scenario = Scenario(
                number: "13",
                title: "Temple of the Seer",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["8"],
                unlocks: ["ONEOF", "15", "17", "20"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies.\n\nIn your quest to locate Jekserah, you decide to venture to a temple high in the mountains where it is said an oracle resides. Maybe they can divine the Valrath's whereabouts.",
                locationString: "N-3, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row12Scenario)

            let row13Scenario = Scenario(
                number: "14",
                title: "Frozen Hollow",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["5", "8", "18"],
                unlocks: ["None"],
                achieves: ["The Power of Enhancement"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill All Enemies.\n\nYou first meet Hail, the Aesther Enchanter, at her 'shop' in the Boiler District. You're hoping to have her divine Jekserah's whereabouts, but instead, you end up trudging out to the Coppernecks to retrieve an orb for her.",
                locationString: "C-10, Copperneck Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row13Scenario)

            let row14Scenario = Scenario(
                number: "15",
                title: "Shrine of Strength",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["13"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "20 XP Each")],
                summary: "Goal: Loot the treasure tile.\n\nA wish granted to you by a disembodied voice at the temple, this shrine is purported to make those who conquer it stronger. Strength need not imply bulging muscles, of course.",
                locationString: "B-11, Copperneck Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row14Scenario)

            let row15Scenario = Scenario(
                number: "16",
                title: "Mountain Pass",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["13", "20"],
                unlocks: ["24", "25"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies.\n\nThe Captain of the Guard was duly impressed with your performance at Gloomhaven Square, and thinks you're up to the task of dealing with the sudden appearance of 'Dragons' up near the northern pass.",
                locationString: "B-6, Copperneck Mountains",
                linksTo: ["24 - Echo Chamber"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row15Scenario)
            
            let row16Scenario = Scenario(
                number: "17",
                title: "Lost Island",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["13"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "25 Gold Each")],
                summary: "Goal: Kill all enemies.\n\nThe strange voice from the Temple of the Seer told you you would find riches here on this remote hunk of rock. Hopefully, said riches won't come at the expense of your lives.",
                locationString: "K-17, Misty Sea",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row16Scenario)
            
            let row17Scenario = Scenario(
                number: "18",
                title: "Abandoned Sewers",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None": true],
                isUnlocked: false,
                unlockedBy: ["11", "12", "20"],
                unlocks: ["14", "23", "26", "43"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies.\n\nOur friend the Captain of the Guard offered us the distinct pleasure of spelunking the sewer system beneath town to put a stop to whatever's poisoning the wells in Sinking Market.",
                locationString: "C-14, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row17Scenario)
            
            let row18Scenario = Scenario(
                number: "19",
                title: "Forgotten Crypt",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Power of Enhancement": true],
                isUnlocked: false,
                unlockedBy: ["5"],
                unlocks: ["27"],
                achieves: ["Stonebreaker's Censer"],
                rewards: [NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Protect Hail until she reaches the altar.\n\nYou once again seek Hail's help, this time in an attempt to close the Rift to the Plane of Power for good. Hail's going to need something called an \"Elemental Censer\" to get the job done, and she's the only one who can handle it. That means protecting Hail from whatever's crawling around the Crypt.",
                locationString: "M-7, Lingering Swamp",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row18Scenario)
            
            let row19Scenario = Scenario(
                number: "20",
                title: "Necromancer's Sanctum",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Merchant Flees": true],
                isUnlocked: false,
                unlockedBy: ["7", "13"],
                unlocks: ["16", "18", "28"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "20 Gold Each"), NSAttributedString(string: "+2 Reputation"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Kill Jekserah.\n\nTime to put Jekserah out of your misery. Hail's information on Jekserah's whereabouts was hard to come by, and as you wend your way through the forest to the Valrath's hideout you intend to get your pain's worth.",
                locationString: "H-13, Corpsewood",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row19Scenario)
            
            let row20Scenario = Scenario(
                number: "21",
                title: "Infernal Throne",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Rift Neutralized": false],
                isUnlocked: false,
                unlockedBy: ["10"],
                unlocks: ["None"],
                achieves: ["The Rift Neutralized"],
                rewards: [NSAttributedString(string: "50 Gold Each"), NSAttributedString(string: "+1 Prosperity"), NSAttributedString(string: "Add City Event 78")],
                summary: "Goal: Kill the Prime Demon.\n\nToo late to turn back now. You have chosen to face the Prime Demon in his own throne room. Problem is, you need to kill the altar, not him. And the altar has a bad habit of not staying in one place.",
                locationString: "C-7, Stone Road",
                linksTo: ["10 - Plane of Elemental Power"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row20Scenario)
            
            let row21Scenario = Scenario(
                number: "22",
                title: "Temple of the Elements",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["OR" : true, "A Demon's Errand" : true, "Following Clues" : true],
                isUnlocked: false,
                unlockedBy: ["10"],
                unlocks: ["31", "35", "36"],
                achieves: ["Artifact: Recovered"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Destroy all altars.\n\nYou decide to play along with the Prime Demon and make your way out to the Temple of the Elements to retrieve a powerful artifact for him.",
                locationString: "K-8, Serpent's Kiss River",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row21Scenario)
            
            let row22Scenario = Scenario(
                number: "23",
                title: "Deep Ruins",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["18"],
                unlocks: ["None"],
                achieves: ["Through the Ruins", "Ancient Technology:1"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Occupy all pressure plates simultaneously.\n\nYou have to go further into the city sewers to find the source of the poison. Looks like you've stumbled upon some ancient tech that controls the doors here.",
                locationString: "C-15, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row22Scenario)
            
            let row23Scenario = Scenario(
                number: "24",
                title: "Echo Chamber",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["16"],
                unlocks: ["30", "32"],
                achieves: ["The Voice's Command"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Open all doors (fog tiles).\n\nA voice calls out to you from deep within a cave near the Mountain Pass, where Demon and Inox were caught consorting. You feel powerfully compelled to enter the cave.",
                locationString: "C-6, Copperneck Mountains",
                linksTo: ["16 - Mountain Pass"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row23Scenario)
            
            let row24Scenario = Scenario(
                number: "25",
                title: "Icecrag Ascent",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["16"],
                unlocks: ["33", "34"],
                achieves: ["The Drake's Command"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: All characters must escape through the exit.\n\nDragon-chasing has led you to the top of Mountain Pass, and you have decided to brave the ascent in pursuit of the beast.",
                locationString: "A-5, Copperneck Mountains",
                linksTo: ["34 - Scorched Summit"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row24Scenario)
            
            let row25Scenario = Scenario(
                number: "26",
                title: "Ancient Cistern",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["OR" : true, "Water-Breathing" : true, "Through the Ruins" : true],
                isUnlocked: false,
                unlockedBy: ["18"],
                unlocks: ["22"],
                achieves: ["Following Clues"],
                rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "+1 Reputation"), NSAttributedString(string: "+2 Prosperity")],
                summary: "Goal: Cleanse all water pumps.\n\nYou reach the final room in the maze of sewers, where you see the tainted water pumps. Between you and them lies a lot of Ooze.",
                locationString: "D-15, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row25Scenario)
            
            let row26Scenario = Scenario(
                number: "27",
                title: "Ruinous Rift",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Artifact: Lost" : false, "Stonebreaker's Censer" : true],
                isUnlocked: false,
                unlockedBy: ["19"],
                unlocks: ["22"],
                achieves: ["The Rift Neutralized"],
                rewards: [NSAttributedString(string: "100 Gold Each (spend on enhancements)")],
                summary: "Goal: Protect Hail for ten rounds.\n\nNow that you've helped Hail retrieve the Elemental Censer, you venture to the nexus of the Rift hoping Hail's scheme will work. You'll have to protect her once again as she does her thing.",
                locationString: "E-6, Stone Road",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row26Scenario)
            
            let row27Scenario = Scenario(
                number: "28",
                title: "Outer Ritual Chamber",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Dark Bounty" : true],
                isUnlocked: false,
                unlockedBy: ["12", "20"],
                unlocks: ["29"],
                achieves: ["An Invitation"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies.\n\nJekserah's last words warned you of a grave threat that emanates from this chamber. Time to investigate and see if there's any truth to those words.",
                locationString: "E-4, Dagger Forest",
                linksTo: ["29 - Sanctuary of Gloom"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row27Scenario)
            
            let row28Scenario = Scenario(
                number: "29",
                title: "Sanctuary of Gloom",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["An Invitation" : true],
                isUnlocked: false,
                unlockedBy: ["28"],
                unlocks: ["29"],
                achieves: ["The Edge of Darkness"],
                rewards: [NSAttributedString(string: "15 XP Each")],
                summary: "Goal: Kill all enemies.\n\nA familiar voice beckons you to enter the rift you found in the Outer Ritual Chamber. You decide to see this through to the end, whatever that might be.",
                locationString: "E-4, Dagger Forest",
                linksTo: ["28 - Outer Ritual Chamber"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row28Scenario)
            
            let row29Scenario = Scenario(
                number: "30",
                title: "Shrine of the Depths",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Voice's Command" : true],
                isUnlocked: false,
                unlockedBy: ["24"],
                unlocks: ["42"],
                achieves: ["The Scepter and the Voice"],
                rewards: [NSAttributedString(string: "10 Gold Each")],
                summary: "Goal: Loot the treasure tile.\n\nAfter consulting with a bookish Quatryl, you discover that the Voice you've been hearing is a Demon of terrible power. You now understand it's been attempting to trick you into freeing it from its plane of imprisonment. The Quatryl points you to a sunken shrine which contains a scepter that could strengthen the binding of the Demon to its plane. Retrieve the scepter.",
                locationString: "N-15, Misty Sea",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row29Scenario)
            
            let row30Scenario = Scenario(
                number: "31",
                title: "Plane of Night",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Power of Enhancement" : true, "Artifact: Recovered" : true],
                isUnlocked: false,
                unlockedBy: ["22"],
                unlocks: ["37", "38", "39", "43"],
                achieves: ["Artifact: Cleansed"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Destroy the rock column.\n\nThe corrupted artifact you found back in the Temple of the Elements needs the attention of an Enchanter. Of course, Hail comes to mind. She knows what needs to be done to rebalance it, but that will involve the destruction of a towering column.",
                locationString: "A-16, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row30Scenario)
            
            let row31Scenario = Scenario(
                number: "32",
                title: "Decrepit Wood",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Voice's Command" : true],
                isUnlocked: false,
                unlockedBy: ["24"],
                unlocks: ["33", "40"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Reveal the G tile, kill all revealed enemies, and loot the treasure tile.\n\nThe voice has directed you to retrieve his so-called 'Vessel of Power' from some place deep in the Lingering Swamp. Get ready to face a horde of Militaristic Harrowers.",
                locationString: "L-11, Lingering Swamp",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row31Scenario)
            
            let row32Scenario = Scenario(
                number: "33",
                title: "Savvas Armory",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["OR" : true, "The Voice's Command" : true, "The Drake's Command" : true],
                isUnlocked: false,
                unlockedBy: ["25"],
                unlocks: ["None"],
                achieves: ["The Voice's Treasure", "The Drake's Treasure"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Loot all treasure tiles, then all characters must escape through the exit (a).\n\nYou have chosen to cooperate with the Elder Drake you met atop Icecrag, who would like you to retrieve his stolen treasure from a Savvas clan.",
                locationString: "A-7, Copperneck Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row32Scenario)
            
            let row33Scenario = Scenario(
                number: "34",
                title: "Scorched Summit",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Drake's Command" : true, "The Drake Aided" : false],
                isUnlocked: false,
                unlockedBy: ["25"],
                unlocks: ["None"],
                achieves: ["REMOVE", "The Drake's Command", "The Drake Slain"],
                rewards: [NSAttributedString(string: "20 Gold Each"), NSAttributedString(string: "+2 Reputation"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Kill the Elder Drake.\n\nUnmoved by the Drake's predicament, you decide to slay him and rid the land of another menace.",
                locationString: "A-4, Copperneck Mountains",
                linksTo: ["25 - Icecrag Ascent"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row33Scenario)
            
            let row34Scenario = Scenario(
                number: "35",
                title: "Gloomhaven Battlements A",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["A Demon's Errand" : true, "The Rift Neutralized" : false],
                isUnlocked: false,
                unlockedBy: ["22"],
                unlocks: ["45"],
                achieves: ["REMOVE", "A Demon's Errand", "City Rule: Demonic", "Artifact: Lost"],
                rewards: [NSAttributedString(string: "30 Gold Each"), NSAttributedString(string: "-5 Reputation"), NSAttributedString(string: "-2 Prosperity"), NSAttributedString(string: "Add City Event 79")],
                summary: "Goal: Destroy door 'l' and kill the Captain of the Guard.\n\nYou bring the corrupted artifact you retrieved from the Temple of the Elements to the Prime Demon. You will now help him eliminate the City Guard and help the Demon rise to power.",
                locationString: "B-14, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row34Scenario)
            
            let row35Scenario = Scenario(
                number: "36",
                title: "Gloomhaven Battlements B",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["A Demon's Errand" : true, "The Rift Neutralized" : false],
                isUnlocked: false,
                unlockedBy: ["22"],
                unlocks: ["None"],
                achieves: ["REMOVE", "A Demon's Errand", "The Rift Neutralized"],
                rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "+4 Reputation"), NSAttributedString(string: "Add City Event 78")],
                summary: "Goal: Kill the Prime Demon.\n\nRegretting your decision to retrieve the corrupted artifact for the Prime Demon, you turn tail and make for the City Battlements. You warn the City Guard and prepare to defend against the approaching hoard of Demons.",
                locationString: "B-14, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row35Scenario)
            
            let row36Scenario = Scenario(
                number: "37",
                title: "Doom Trench",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Water-Breathing" : true],
                isUnlocked: false,
                unlockedBy: ["31"],
                unlocks: ["47"],
                achieves: ["Through the Trench"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: All characters must escape through the exit (a).\n\nHail claims that this murky trench beneath the Misty Sea is one of the places from which tendrils of dark power emanated when we destroyed the rock column back in the Plane of Night. Make sure you take your Water-Breathing Orb with you!",
                locationString: "G-18, Misty Sea",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row36Scenario)
            
            let row37Scenario = Scenario(
                number: "38",
                title: "Slave Pens",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["31"],
                unlocks: ["44", "48"],
                achieves: ["Redthorn's Aid"],
                rewards: [NSAttributedString(string: "+1 Reputation")],
                summary: "Goal: Kill all enemies and protect the Orchid.\n\nThe second location identified by Hail as a source of corruption for the artifact is buried deep within the Dagger Forest. To get there, you'll need the help of an Orchid familiar with the area. Help the Orchid destroy its Inox enslavers and he'll show you how to get to the right location.",
                locationString: "G-2, Dagger Forest",
                linksTo: ["44 - Tribal Assault"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row37Scenario)
            
            let row38Scenario = Scenario(
                number: "39",
                title: "Treacherous Divide",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["31"],
                unlocks: ["15", "46"],
                achieves: ["Across the Divide"],
                rewards: [NSAttributedString(string: "10XP Each")],
                summary: "Goal: Destroy the altar (a).\n\nThe third of the vessel-corrupting locations lies somewhere high in the Copperneck Mountains. Before you can get there, you are going to have to scale a summit and find a bridge that will connect you to your ultimate destination. Bring your thickest furs and sharpest swords.",
                locationString: "B-11, Copperneck Mountains",
                linksTo: ["46 - Nightmare Peak"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row38Scenario)
            
            let row39Scenario = Scenario(
                number: "40",
                title: "Ancient Defense Network",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Voice's Command" : true, "The Voice's Treasure": true],
                isUnlocked: false,
                unlockedBy: ["32", "33"],
                unlocks: ["41"],
                achieves: ["Ancient Technology:2"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Occupy both pressure plates (a) simultaneously.\n\nThe Voice has guided you to this treacherous, trap-filled tomb entrance. In order to progress to the Vessel's resting place, you must first survive a gauntlet of monsters, and then figure out how to unlock the tomb.",
                locationString: "F-12, Copperneck Mountains",
                linksTo: ["Timeworn Tomb"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row39Scenario)
            
            let row40Scenario = Scenario(
                number: "41",
                title: "Timeworn Tomb",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Voice's Command" : true],
                isUnlocked: false,
                unlockedBy: ["40"],
                unlocks: ["None"],
                achieves: ["The Voice Freed"],
                rewards: [NSAttributedString(string: "50 Gold Each"), NSAttributedString(string: "25XP Each"), NSAttributedString(string: "2 ✔️ Each"), NSAttributedString(string: "+2 Prosperity")],
                summary: "Goal: All characters must escape through the exit (a).\n\nNow that you've shut down the Defense Network, you can proceed to the tomb and retrieve the third Vessel for the Voice.",
                locationString: "F-12, Copperneck Mountains",
                linksTo: ["40 - Ancient Defense Network"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row40Scenario)
            
            let row41Scenario = Scenario(
                number: "42",
                title: "Realm of the Voice",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Scepter and the Voice" : true, "The Voice Freed" : false],
                isUnlocked: false,
                unlockedBy: ["30"],
                unlocks: ["None"],
                achieves: ["REMOVE", "The Voice's Command", "The Voice Silenced"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Destroy all vocal chords.\n\nWith the scepter you retrieved from the Shrine of the Depths in your hand, you again enter the Echo Chamber hopeful that you can defeat the Voice once and for all. The Voice's last howl will likely be an ear-shattering trial.",
                locationString: "C-5, Copperneck Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row41Scenario)
            
            let row42Scenario = Scenario(
                number: "43",
                title: "Drake Nest",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Power of Enhancement" : true],
                isUnlocked: false,
                unlockedBy: ["18", "31"],
                unlocks: ["None"],
                achieves: ["Water-Breathing"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill a number of drakes equal to four times the number of characters.\n\nYou want to be able to travel anywhere in the land, and that includes under water. Hail has a plan to help you achieve that ability, but you'll need to kill a bunch of scaly monsters first. ",
                locationString: "D-4, Dagger Forest",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row42Scenario)
            
            let row43Scenario = Scenario(
                number: "44",
                title: "Tribal Assault",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Redthorn's Aid" : true],
                isUnlocked: false,
                unlockedBy: ["38"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [scenario44String, NSAttributedString(string: "+2 Reputation")],
                summary: "Goal: Kill all enemies and protect all captive Orchids(a).\n\nAghast at Redthorn's story about the Inox raid on their village, you feel compelled to help him free his brethren from the Inox slavers a short distance from the Slave Pens.",
                locationString: "F-3, Dagger Forest",
                linksTo: ["38 - Slave Pens"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row43Scenario)
            
            let row44Scenario = Scenario(
                number: "45",
                title: "Rebel Swamp",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["35"],
                unlocks: ["49", "50"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "20 Gold Each"), NSAttributedString(string: "-2 Reputation")],
                summary: "Goal: Destroy all totems (a).\n\nThe Prime Demon has commanded you to remove all remaining pockets of resistance. Apparently, the swamps host one of the bigger pockets. Better investigate and root out any rebels that might remain.",
                locationString: "M-9, Lingering Swamp",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row44Scenario)
            
            let row45Scenario = Scenario(
                number: "46",
                title: "Nightmare Peak",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Across the Divide" : true],
                isUnlocked: false,
                unlockedBy: ["39"],
                unlocks: ["51"],
                achieves: ["End of Corruption 1"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill the Winged Horror.\n\nWith the way to the peak now clear, you forge on to the summit only to encounter the likely source of vessel corruption. Unfortunately, it's a big, nasty Demon.",
                locationString: "A-11, Copperneck Mountains",
                linksTo: ["Treacherous Divide"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row45Scenario)
            
            let row46Scenario = Scenario(
                number: "47",
                title: "Lair of the Unseeing Eye",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Through the Trench" : true],
                isUnlocked: false,
                unlockedBy: ["37"],
                unlocks: ["51"],
                achieves: ["End of Corruption 2"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill the Sightless Eye.\n\nYou've made it through the Deep Trench, and have found what you believe is one of the sources of corruption Hail was speaking of. Keep an eye out for this monster; he's like nothing you've encountered before.",
                locationString: "H-18, Misty Sea",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row46Scenario)
            
            let row47Scenario = Scenario(
                number: "48",
                title: "Shadow Weald",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Redthorn's Aid" : true],
                isUnlocked: false,
                unlockedBy: ["38"],
                unlocks: ["51"],
                achieves: ["End of Corruption 3"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill the Dark Rider.\n\nRedthorn escorts you to this place deep within the Dagger Forest, where you hope to find another of the sources of corruption of the vessel you brought back to Hail. This Dark Rider fellow doesn't seem too friendly, alas.",
                locationString: "E-1, Dagger Forest",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row47Scenario)
            
            let row48Scenario = Scenario(
                number: "49",
                title: "Rebel's Stand",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["City Rule: Demonic" : true],
                isUnlocked: false,
                unlockedBy: ["45"],
                unlocks: ["None"],
                achieves: ["Annihilation of Order"],
                rewards: [NSAttributedString(string: "50 Gold Each"), NSAttributedString(string: "-3 Reputation")],
                summary: "Goal: Kill the Siege Cannon.\n\nGuided by the directions given by the gullible Guard in his last breath back in the Rebel Swamp, you find what remains of the resistance. As you fight your way through the camp, you notice a towering contraption that should not remain in rebel hands.",
                locationString: "N-7, Lingering Swamp",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row48Scenario)
            
            let row49Scenario = Scenario(
                number: "50",
                title: "Ghost Fortress",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["City Rule: Demonic" : true, "Annihilation of Order": false],
                isUnlocked: false,
                unlockedBy: ["45"],
                unlocks: ["None"],
                achieves: ["City Rule: Militaristic"],
                rewards: [NSAttributedString(string: "+3 Reputation"), NSAttributedString(string: "-2 Prosperity")],
                summary: "Goal: Loot all treasure tiles.\n\nFollowing the dying Guard's directions, you come upon the rebel camp in the foothills of the Watcher Mountains. The rebels have a Siege Cannon ready to go, but they need to arm their men for the attack on Gloomhaven. Break into the Fortress and retrieve the weapons cache before the rebels can get to it.",
                locationString: "C-17, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row49Scenario)
            
            let row50Scenario = Scenario(
                number: "51",
                title: "The Void",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["End of Corruption 1" : true, "End of Corruption 2": true, "End of Corruption 3": true],
                isUnlocked: false,
                unlockedBy: ["46", "47", "48"],
                unlocks: ["None"],
                achieves: ["End of Gloom"],
                rewards: [NSAttributedString(string: "+5 Reputation"), NSAttributedString(string: "+5 Prosperity"), NSAttributedString(string: "Add City Event 81"), NSAttributedString(string: "Add Road Event 69")],
                summary: "Goal: Kill the Gloom.\n\nThe seriousness of Hail's tone gets your attention. Seems a fellow named Bastian - an Aesther gone bad - is occupying a realm called The Void. He's going to turn the world to ash unless you can get to him first.",
                locationString: "A-15, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row50Scenario)
            
            let row51Scenario = Scenario(
                number: "52",
                title: "Noxious Cellar",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Seeker of Xorn personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["53"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: All characters must loot one treasure tile.\n\nYour search for the remains of Xorn takes on renewed urgency as you come across a tome that points you to an old shack in the Sinking Market. Gather your team and investigate.",
                locationString: "D-14, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row51Scenario)
            
            let row52Scenario = Scenario(
                number: "53",
                title: "Crypt Basement",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Seeker of Xorn personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["52"],
                unlocks: ["54"],
                achieves: ["Staff of Xorn item equipped"],
                rewards: [NSAttributedString(string: "Staff of Xorn (Item 114)")],
                summary: "Goal: Survive for ten rounds.\n\nThe staff you found in the Noxious Cellar has yielded further clues in your search for Xorn: A map to a secret room in the Crypt of the Damned. The search will continue there.",
                locationString: "F-11, Still River",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row52Scenario)
            
            let row53Scenario = Scenario(
                number: "54",
                title: "Palace of Ice",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Seeker of Xorn personal quest" : true, "Staff of Xorn item equipped" : true],
                isUnlocked: false,
                unlockedBy: ["53"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Immediately retire the Seeker of Xorn"), NSAttributedString(string: "Add City and Road Events 59 instead of normal events"), scenario54String],
                summary: "Goal: Place the fully-charged Staff of Xorn on the altar.\n\nThe ethereal warden in the Crypt Basement prepared the staff for you, and told you to bring it to the Palace of Ice. Your job is to charge it and lay it upon the altar.",
                locationString: "D-8, Copperneck mountains",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row53Scenario)
            
            let row54Scenario = Scenario(
                number: "55",
                title: "Foggy Thicket",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Take Back the Trees personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["56"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "10 Collective Gold")],
                summary: "Goal: Loot the treasure tile in the third room.\n\nYou have revenge on your mind as you return to the Dagger Forest to search for clues to the whereabouts of the bandits who destroyed your village.",
                locationString: "G-5, Dagger Forest",
                linksTo: ["56 - Bandit's Wood"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row54Scenario)
            
            let row55Scenario = Scenario(
                number: "56",
                title: "Bandit's Wood",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Take Back the Trees personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["55"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Take Back the Trees personal quest: COMPLETE"), scenario44String, NSAttributedString(string: "10 Gold each"), NSAttributedString(string: "+2 Reputation")],
                summary: "Goal: Kill the Infiltrator.\n\nThe map you retrieved from the Foggy Thicket has led you to the Bandit camp. You need to finish these guys off, but take care to protect the captive Orchids.",
                locationString: "G-4, Dagger Forest",
                linksTo: ["55 - Foggy Thicket"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row55Scenario)
            
            let row56Scenario = Scenario(
                number: "57",
                title: "Investigation",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Vengeance personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["58"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "+1 Reputation")],
                summary: "Goal: Kill all enemies and protect at least one captive Orchid.\n\nYour information has led you to the West Barracks. The corrupt Lieutenant who was on duty the night your friend was murdered is stationed here, and you aim to get answers.",
                locationString: "D-14, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row56Scenario)
            
            let row57Scenario = Scenario(
                number: "58",
                title: "Bloody Shack",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Vengeance personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["57"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Vengeance personal quest: COMPLETE"), NSAttributedString(string: "Open envelope X"), NSAttributedString(string: "+2 Reputation")],
                summary: "Goal: Kill the Harvester.\n\nLed to this run down shack by clues left on the Infiltrator's body, you gird yourself for what is likely to be a nasty battle. Your need for revenge has gotten you this far, but can it sustain you through what lies within?",
                locationString: "E-15, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row57Scenario)
            
            let row58Scenario = Scenario(
                number: "59",
                title: "Forgotten Grove",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Finding the Cure personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["60"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies and loot the treasure tile.\n\nThe elder spoke of a plant that could provide a cure for the plague that's decimated your village. A helpful Quatryl has fashioned a compass which has led you to the supposed whereabouts of this magical plant. Nothing hard about harvesting a plant, right?",
                locationString: "F-1, Dagger Forest",
                linksTo: ["None"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row58Scenario)
            
            let row59Scenario = Scenario(
                number: "60",
                title: "Alchemy Lab",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Finding the Cure personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["59"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Finding the Cure personal quest: COMPLETE"), NSAttributedString(string: "Open envelope X"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Loot all treasure tiles, then all characters must escape through the entrance.\n\nThe Quatryl double-crossed you back in the Forgotten Grove, and you don't take kindly to such behavior. You arrive at the University, only to find the Alchemy Lab on fire. The cure lies within the inferno somewhere, according to the sheepish Quatryl. Even a raging fire won't keep you from obtaining the cure.",
                locationString: "B-15, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row59Scenario)
            
            let row60Scenario = Scenario(
                number: "61",
                title: "Fading Lighthouse",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Fall of Man personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["62"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Loot all treasure tiles.\n\nYou can't explain exactly why you think the evidence you're looking for is all the way down in the swamp, but you feel you are on the right track when you spy a lighthouse along the shore in the distance. Now here, now gone, you realize the lighthouse is constantly shifting between planes of existence. No matter, you need to get in there and glean whatever you can about those who came before.",
                locationString: "N-11, Lingering Swamp",
                linksTo: ["62 - Pit of Souls"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row60Scenario)
            
            let row61Scenario = Scenario(
                number: "62",
                title: "Pit of Souls",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["The Fall of Man personal quest" : true],
                isUnlocked: false,
                unlockedBy: ["61"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "The Fall of Man personal quest: COMPLETE"), scenario62String, NSAttributedString(string: "10XP Each")],
                summary: "Goal: Kill the Hungry Soul.\n\nYou're drawn ever deeper into the bowels of the lighthouse, and restless souls form dusty bones into sword-wielding skeletons. Forge onward and confront whatever malcontented beings remain trapped here.",
                locationString: "N-11, Lingering Swamp",
                linksTo: ["61 - Fading Lighthouse"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row61Scenario)
            
            let row62Scenario = Scenario(
                number: "63",
                title: "Magma Pit",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "15 Gold Each")],
                summary: "Goal: Kill all enemies.\n\nIf the reports are true, there's gold to be found on this active volcano high in the Watcher Mountains. As always, come prepared for battle, as nothing in Gloomhaven comes easily.",
                locationString: "M-1, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row62Scenario)
            
            let row63Scenario = Scenario(
                number: "64",
                title: "Underwater Lagoon",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Water-Breathing" : true],
                isUnlocked: true,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "10XP Each")],
                summary: "Goal: Kill all enemies.\n\nYou came by the map easily enough, so there must be a catch. Nevertheless, you're raring to take advantage of your water breathing capability and explore this mysterious lagoon way out in the Misty Sea. The hired boat's captain will only come so close to the shore of this place, so bring a dinghy with you.",
                locationString: "R-16, Misty Sea",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row63Scenario)
            
            let row64Scenario = Scenario(
                number: "65",
                title: "Sulfur Mine",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["Ancient Technology:3"],
                rewards: [NSAttributedString(string: "Ancient Drill design (Item 112)")],
                summary: "Goal: Kill all enemies and loot all treasure tiles.\n\nEveryone knows where this place is due to the overwhelming stench that emanates for miles in all directions. Not so well-known is the fact that ancient technology of some sort lies deep within the mine. You know a few folks who would love to get their hands on such tech - for the right price.",
                locationString: "L-5, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row64Scenario)
            
            let row65Scenario = Scenario(
                number: "66",
                title: "Clockwork Cove",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["Ancient Technology:4"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Occupy pressure plate (e).\n\nEver on the lookout for lost technology, this cove up along the coast near town seems promising. Rumor has it that the place is chocked full of gears and levers (and traps, of course).",
                locationString: "G-14, Copperneck Mountains",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row65Scenario)
            
            let row66Scenario = Scenario(
                number: "67",
                title: "Arcane Library",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["Ancient Technology:5"],
                rewards: [NSAttributedString(string: "Power Core (Item 132)")],
                summary: "Goal: Kill the Arcane Golem.\n\nYou have discovered the location of the old mystic Morsbane's Tower. The place is long past its prime but still home to ancient treasure, if rumors are to be believed.",
                locationString: "K-2, East Road",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row66Scenario)
            
            let row67Scenario = Scenario(
                number: "68",
                title: "Toxic Moor",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Two(2) Major Healing potions (Item 027)")],
                summary: "Goal: Kill all enemies and protect the Tree (a).\n\nYou've heard tell of a great tree that grows somewhere deep within the Lingering Swamp. It supposedly possesses great healing power, but is rumored to be the target of vile creatures bent on its destruction. Whether it be a soft spot for nature, or the hope of finding valuable potions, you need to get down there and defend the tree.",
                locationString: "N-8, Lingering Swamp",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row67Scenario)
            
            let row68Scenario = Scenario(
                number: "69",
                title: "Well of the Unfortunate",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "15 Gold Each")],
                summary: "Goal: Bring the doll to the well.\n\nThere's an old well up along the Stone Road that's supposed to grant wishes to those who throw items of value into its depths. Though you're not particularly superstitious, your curiosity drives you to go see for yourself.",
                locationString: "F-8, Stone Road",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row68Scenario)
            
            let row69Scenario = Scenario(
                number: "70",
                title: "Chained Isle",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "+2 Prosperity")],
                summary: "Goal: Kill all demons.\n\nYou've heard enough about the haunted island to fill several story books. No one dares go near the remote hunk of rock deep in the Misty Sea for fear of the tormented souls haunting the shore. A recently-discovered journal details the existence of a cohort of demons somewhere on the island, which could be the source of the discomfited souls. Wipe out the demons, and maybe the Chained Isle will become a destination once again.",
                locationString: "J-17, Misty Sea",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row69Scenario)
            
            let row70Scenario = Scenario(
                number: "71",
                title: "Windswept Highlands",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Two(2) Major Power potions")],
                summary: "Goal: Loot all treasure tiles, then all characters must escape through exit (a).\n\nYou've uncovered an alchemist's log book, wherein you read about a plant (jerry root) which can be used to formulate a powerful concoction. If you can retrieve this plant from the highlands along the Serpent's Kiss River, you might be able to fetch some decent coin for it.",
                locationString: "K-5, Serpent's Kiss River",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row70Scenario)
            
            let row71Scenario = Scenario(
                number: "72",
                title: "Oozing Grove",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "+1 Reputation"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Destroy all trees and kill all Oozes.\n\nTown librarian Dominic fears the military will quash his attempts to chronicle Gloomhaven history. If you scratch Councilman Greymare's back, the councilman will do what he can to protect Dominic. In this case, the back-scratching involves clearing Greymare's Corpsewood estate of an Ooze infestation.",
                locationString: "H-12, Corpsewood",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row71Scenario)
            
            let row72Scenario = Scenario(
                number: "73",
                title: "Rockslide Ridge",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "+1 Reputation")],
                summary: "Goal: Kill all enemies and loot all treasure tiles.\n\nDominic the librarian implores you to recover a Codex that contains vital information about Gloomhaven's ancient history. Problem is, it's purportedly in the hands of a band of Inox.",
                locationString: "N-5, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row72Scenario)
            
            let row73Scenario = Scenario(
                number: "74",
                title: "Merchant Ship",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["High Sea Escort" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 76A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "+2 Prosperity")],
                summary: "Goal: Kill all enemies and keep the ship afloat.\n\nMerchant Gavin has hired you to put an end to the sea piracy that's destroying his business. Board one of his ships and let the pirates come to you, then finish them off for good.",
                locationString: "I-14, Misty Sea",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row73Scenario)
            
            let row74Scenario = Scenario(
                number: "75",
                title: "Overgrown Graveyard",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Grave Job" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 77A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "60 Gold Each")],
                summary: "Goal: Dig up all graves and kill the Bloated Regent.\n\nNotorious fence Red Nick thinks you will make great grave robbers. Apparently there's much loot to be pilfered from a cemetary out on the east side of the Corpsewood, assuming the job isn't beneath you.",
                locationString: "G-12, Corpsewood",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row74Scenario)
            
            let row75Scenario = Scenario(
                number: "76",
                title: "Harrower Hive",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Bravery" : true],
                isUnlocked: false,
                unlockedBy: ["Secret Envelope"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Reveal all rooms and kill all enemies.\n\nThere's a group of Harrowers slaughtering people out along the East Road, and they need to be stopped. Problem is, no-one has stepped up to take on this extremely dangerous task. If you're up to it, head out to their hive in the Watcher Mountains and wipe them out.",
                locationString: "L-3, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row75Scenario)
            
            let row76Scenario = Scenario(
                number: "77",
                title: "Vault of Secrets",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["None"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "5 XP Each")],
                summary: "Goal: Loot all treasure tiles and kill all City Guards before the alarm is raised.\n\nLibrarian Dominic's beloved Codex was stolen from him by a mysterious group calling themselves The Vigil. He has directed you to sneak in to their Vault of Secrets and recover the Codex without raising an alarm.",
                locationString: "B-17, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row76Scenario)
            
            let row77Scenario = Scenario(
                number: "78",
                title: "Sacrifice Pit",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 34A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "+3 Reputation")],
                summary: "Goal: Kill all enemies and stop the sacrifice.\n\nYou've followed a cloaked figure to what you believe could be the Ravens' hideout. This may be your chance cleanse the city of these vile cultists for good.",
                locationString: "B-14, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row77Scenario)
            
            let row78Scenario = Scenario(
                number: "79",
                title: "Lost Temple",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Fish's Aid" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 72A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "15 Gold Each")],
                summary: "Goal: Kill the Betrayer.\n\nAn old bandit, Fish, tells you that the metal sphere and rod you are puzzling over is in fact a key to a temple that contains untold riches. You decide to take Fish at his word and follow him out to the swamps to scare up some gold.",
                locationString: "K-12, Lingering Swamp",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row78Scenario)
            
            let row79Scenario = Scenario(
                number: "80",
                title: "Vigil Keep",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["Road Event 49A/49B"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "10 XP Each")],
                summary: "Goal: All characters must loot one treasure tile and then escape.\n\nYour investigations into the Vigil have landed you in a jail cell deep within their keep. A friend offers a bit of help, but you must still regain your weapons and items if you're going to escape this place.",
                locationString: "K-1, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row79Scenario)
            
            let row80Scenario = Scenario(
                number: "81",
                title: "Temple of the Eclipse",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 17B"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "10 XP Each")],
                summary: "Goal: Kill the Colorless.\n\nJust when you thought that coin you bought off the strange Savvas merchant was a worthless bauble, an Aesther tells you its markings lead to a mysterious temple. This proves to be too enticing to ignore, so you head out to the Dagger Forest ready to explore.",
                locationString: "D-2, Dagger Forest",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row80Scenario)
            
            let row81Scenario = Scenario(
                number: "82",
                title: "Burning Mountain",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["Road Event 24A/24B"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "+1 Reputation OR"), NSAttributedString(string: "-1 Reputation, -2 Prosperity")],
                summary: "Goal: Sacrifice one artifact or escape with all artifacts.\n\nThat band of Inox you passed on the road were fleeing what their Shaman called 'A Mountain Aflame'. After coming upon the scorched Inox village, you decide to brave the climb to the peak beyond and see just what's really going on.",
                locationString: "M-6, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row81Scenario)
            
            let row82Scenario = Scenario(
                number: "83",
                title: "Shadows Within",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Bad Business" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 31A/31B"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "40 Collective Gold")],
                summary: "Goal: Kill all enemies.\n\nThe woman who approached you during a drunken night gambling at the Brown Door caught your attention with a parchment bearing the Raven insignia. She's appealing to you to rescue her kidnapped daughter from the nasty cultist group. You've got a lead on their whereabouts, so it's time to go knock some heads.",
                locationString: "C-15, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row82Scenario)
            
            let row83Scenario = Scenario(
                number: "84",
                title: "Crystalline Cave",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Tremors" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 73A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Resonant Crystal (Item 133)"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Kill all enemies and protect the crystal (a).\n\nThat crystal you found turns out to contain earth-shaking power - quite literally. After consulting with a Quatryl over what to do about it, you're off to restore the crystal to its proper place and hopefully quiet the rumblings.",
                locationString: "D-12, Copperneck Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row83Scenario)
            
            let row84Scenario = Scenario(
                number: "85",
                title: "Sun Temple",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["Road Event 61B", "Road Event 62A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Orb of Dawn (Item 121)")],
                summary: "Goal: Kill all enemies.\n\nSun Demons have sought your help in ridding their temple of Night Demons. You begrudgingly agree to assist them.",
                locationString: "M-3, Watcher Mountains",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row84Scenario)
            
            let row85Scenario = Scenario(
                number: "86",
                title: "Harried Village",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 63A"],
                unlocks: ["87"],
                achieves: ["The Poison's Source"],
                rewards: [NSAttributedString(string: "+2 Reputation")],
                summary: "Goal: Save seven villagers before five are killed.\n\nFind out what's poisoning the residents of Hook Coast and report back to the City Guard.",
                locationString: "D-15, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row85Scenario)

            let row86Scenario = Scenario(
                number: "87",
                title: "Corrupted Cove",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["86", "City Event 47A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "+1 Reputation"), NSAttributedString(string: "+1 Prosperity")],
                summary: "Goal: Kill the Giant Ooze.\n\nA resident of the Hook Coast points out the source of the poison ravaging his village. Travel to a cove just to the south to investigate further.",
                locationString: "I-9, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row86Scenario)
            
            let row87Scenario = Scenario(
                number: "88",
                title: "Plane of Water",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Water-Breathing" : true, "Water Staff" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 68A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Staff of Summoning (Item 120)")],
                summary: "Goal: Bring the Lurker King's claw to the crystal (a).\n\nThat Summoner's Staff you found is gushing water all over your room at the Sleeping Lion, so you gamely try to figure out how to stop it. Suddenly a planar threshold appears before you, and you step through.",
                locationString: "D-16, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row87Scenario)
            
            let row88Scenario = Scenario(
                number: "89",
                title: "Syndicate Hideout",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Sin-Ra" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 64A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "50 Collective Gold")],
                summary: "Goal: Kill all enemies.\n\nThe Sin-Ra Syndicate has a beef with your 'friend' the Nightshroud, so they have decided to strike at you. Find their hideout and make them regret it.",
                locationString: "C-17, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row88Scenario)
            
            let row89Scenario = Scenario(
                number: "90",
                title: "Demonic Rift",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["Road Event 44A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Black Censer (Item 128")],
                summary: "Goal: Close the rift.\n\nYour friend the Spellweaver showed up out of nowhere one night to help you fend off some Night Demons. She's asked for your help in destroying with the rift from whence they came.",
                locationString: "J-7, Serpent's Kiss River",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row89Scenario)
            
            let row90Scenario = Scenario(
                number: "91",
                title: "Wild Melee",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 58B"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "2 ✔️ Each")],
                summary: "Goal: Kill all enemies.\n\nYou take the drunken logger's bar-table rant about a Vermling riding a bear seriously, and head out to the Dagger Forest to see what he was on about.",
                locationString: "E-2, Dagger Forest",
                linksTo: ["None"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row90Scenario)
            
            let row91Scenario = Scenario(
                number: "92",
                title: "Back Alley Brawl",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["Debt Collection" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 67B"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "-3 Reputation")],
                summary: "Goal: Kill all non-city enemies.\n\nSome Inox thought they could extort you for a debt owed by someone else. You would rather meet them in the alley outside the Sleeping Lion and show them your preferred form of payback.",
                locationString: "C-14, Gloomhaven",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row91Scenario)
            
            let row92Scenario = Scenario(
                number: "93",
                title: "Sunken Vessel",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["A Map to Treasure" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 08A"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "10 XP Each")],
                summary: "Goal: Kill all enemies.\n\nYou decided to purchase a faded map from a Valrath merchant. It supposedly points to sunken treasure, so you rent a boat and sail to where X marks the spot.",
                locationString: "N-17, Misty Sea",
                linksTo: ["Gloomhaven"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row92Scenario)
            
            let row93Scenario = Scenario(
                number: "94",
                title: "Vermling Nest",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["City Event 78A"],
                unlocks: ["95"],
                achieves: ["Through the Nest"],
                rewards: [NSAttributedString(string: "None")],
                summary: "Goal: Kill all enemies and loot the treasure tile.\n\nThe old man who approached your table at the Sleeping Lion asked you to retrieve an artifact for him. He promised that there would be plenty of riches to be found once the Vermlings protecting it were dealt with.",
                locationString: "F-12, Corpsewood",
                linksTo: ["95 - Payment Due"],
                isManuallyUnlockable: true
            )
            allScenarios.append(row93Scenario)
            
            let row94Scenario = Scenario(
                number: "95",
                title: "Payment Due",
                isCompleted: false,
                requirementsMet: false,
                requirements: ["None" : true],
                isUnlocked: false,
                unlockedBy: ["94"],
                unlocks: ["None"],
                achieves: ["None"],
                rewards: [NSAttributedString(string: "Skull of Hatred (Item 119)")],
                summary: "Goal: Kill the Prime Lieutenant.\n\nAfter dealing with the Vermling nest, you were expecting to find a glittering trove. Instead, you've been thrust into a battle arena for the entertainment of the Prime Lieutenant.",
                locationString: "G-12, Corpsewood",
                linksTo: ["94 - Vermling Nest"],
                isManuallyUnlockable: false
            )
            allScenarios.append(row94Scenario)
            
            globalAchievements = [
                "None"                                  : true,
                "OR"                                    : true,
                "Annihilation of Order"                 : false,
                "Artifact: Cleansed"                    : false,
                "Artifact: Lost"                        : false,
                "Artifact: Recovered"                   : false,
                "Ancient Technology:1"                  : false,
                "Ancient Technology:2"                  : false,
                "Ancient Technology:3"                  : false,
                "Ancient Technology:4"                  : false,
                "Ancient Technology:5"                  : false,
                "City Rule: Economic"                   : false,
                "City Rule: Militaristic"               : true,
                "City Rule: Demonic"                    : false,
                "End of Corruption 1"                   : false,
                "End of Corruption 2"                   : false,
                "End of Corruption 3"                   : false,
                "End of Gloom"                          : false,
                "End of the Invasion"                   : false,
                "The Dead Invade"                       : false,
                "The Drake Aided"                       : false,
                "The Drake Slain"                       : false,
                "The Edge of Darkness"                  : false,
                "The Merchant Flees"                    : false,
                "The Power of Enhancement"              : false,
                "The Rift Neutralized"                  : false,
                "The Voice Freed"                       : false,
                "The Voice Silenced"                    : false,
                "Water-Breathing"                       : false
            ]
            
            // Create iCloud private DB schema if no plist exists. Logic will change.
//            checkIfCampaignRecordExists() {
//                result in
//                if result != nil {
//                    print("No need to create CK Schema. Updating local values from Cloud")
//                    //DispatchQueue.main.async {
//                    self.getCharactersFromCloud() { myName,myGoal,myType,myLevel,myIsActive,myIsRetired,myIsAssignedTo in
//                        self.characters[myName]!.goal = myGoal
//                        self.characters[myName]!.type = myType
//                        self.characters[myName]!.level = myLevel
//                        self.characters[myName]!.isActive = myIsActive
//                        self.characters[myName]!.isRetired = myIsRetired
//                        self.characters[myName]!.assignedTo = myIsAssignedTo
//                    }
//                    self.updateCampaignsFromCloud() { campaigns in
//                        self.campaigns = campaigns
//                    }
//
//                } else { // No cloud schema, no local plist -> create new default campaign
//                    // Need to make sure it's not that we just can't contact the container (due to authentication issues, e.g.) If that's the case, we need to give user a way to try again before overwriting Cloud
//                    print("Attempting to create CK Schema")
//                    self.createCampaign(title: "MyCampaign", isCurrent: true, parties: [self.createDefaultParty()])
//                    //self.createDefaultCharacters()
//                    self.saveCampaignsLocally()
////                    self.updateCampaignRecords()
//                }
//            }
        }
        
        print("Documents folder is \(documentsDirectory())")
        print("Data file path is \(dataFilePath())")
    }
    func setCurrentParty(party: Party) {
        for thisParty in self.parties.values {
            thisParty.isCurrent = false
        }
        party.isCurrent = true
        loadParty(party: party.name)

    }
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Campaigns.plist")
    }
    func saveCampaignsLocally() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(allScenarios, forKey: "Scenarios")
        archiver.encode(campaigns, forKey: "Campaigns")
        archiver.encode(parties, forKey: "Parties")
        archiver.encode(characters, forKey: "Characters")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    func loadCampaignsFromLocal() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            allScenarios = unarchiver.decodeObject(forKey: "Scenarios") as! [Scenario]
            campaigns = unarchiver.decodeObject(forKey: "Campaigns") as! [ String: Campaign ]
            parties = unarchiver.decodeObject(forKey: "Parties") as! [ String:Party ]
            characters = unarchiver.decodeObject(forKey: "Characters") as! [ String:Character ]
            unarchiver.finishDecoding()
        }
    }
    func setCampaignsAndParties() {
        for campaign in campaigns {
            if campaign.value.isCurrent == true {
                loadCampaign(campaign: campaign.key)
                break
            }
        }
        for party in parties {
            if party.value.isCurrent == true {
                loadParty(party: party.key)
                break
            }
        }
    }
    func getScenario(scenarioNumber: String) -> Scenario? {
        
        if scenarioNumber == "None" || scenarioNumber == "OR" || scenarioNumber.contains("Event") || scenarioNumber.contains("Envelope") {
            return nil
        } else {
            let scenInt = Int(scenarioNumber)!-1
            let scenario = allScenarios[scenInt]
            
            return scenario
        }
    }
    // Campaign functions
    func createCampaign(title: String, isCurrent: Bool, parties: [Party]) {
        if (campaigns[title] == nil) {
            let newCampaign = Campaign(title: title, parties: parties, achievements:[:], prosperityCount: 0, sanctuaryDonations: 0, events: createEvents(), isUnlocked: [], requirementsMet: [], isCompleted: [], isCurrent: isCurrent, ancientTechCount: 0, availableCharacterTypes: createCharacterTypes(), notes: "")
            for scenario in allScenarios {
                if scenario.number == "1" {
                    newCampaign.isUnlocked.append(true)
                    newCampaign.requirementsMet.append(true)
                    newCampaign.isCompleted.append(false)
                } else {
                    newCampaign.isUnlocked.append(false)
                    newCampaign.requirementsMet.append(false)
                    newCampaign.isCompleted.append(false)
                }
            }
            for achievement in globalAchievements {
                if achievement.key == "None" || achievement.key == "OR" {
                    newCampaign.achievements[achievement.key] = true
                } else {
                    newCampaign.achievements[achievement.key] = false
                }
            }
            campaigns[title] = newCampaign
            if newCampaign.isCurrent == true {
                loadCampaign(campaign: newCampaign.title)
            }
        } else {
            print("Campaign \(campaigns[title]!.title) already exists!")
        }
    }
    func resetCurrentCampaign() {
        let campaign = currentCampaign
        var count = 0
        for scenario in self.allScenarios {
            if scenario.number == "1" {
                campaign.isUnlocked[count] = true
                campaign.isCompleted[count] = false
                campaign.requirementsMet[count] = true
                count += 1
            } else {
                campaign.isUnlocked[count] = false
                campaign.isCompleted[count] = false
                campaign.requirementsMet[count] = false
                count+=1
            }
        }
        for achievement in currentCampaign.achievements {
            if achievement.key == "None" || achievement.key == "OR" {
                campaign.achievements[achievement.key] = true
            } else {
                campaign.achievements[achievement.key] = false
            }
        }
    }
    func loadCampaign(campaign: String) {
        if let requestedCampaign = campaigns[campaign] {
            var count = 0
            for scenario in allScenarios {
                scenario.isUnlocked = requestedCampaign.isUnlocked[count]
                scenario.requirementsMet = requestedCampaign.requirementsMet[count]
                scenario.isCompleted = requestedCampaign.isCompleted[count]
                count += 1
            }
            for achievement in requestedCampaign.achievements.keys {
                let newStatus = requestedCampaign.achievements[achievement]
                self.globalAchievements[achievement] = newStatus
            }
            updateLocalCampaignIsCurrent(campaign: requestedCampaign.title)
            updateCloudCampaignIsCurrent(campaign: requestedCampaign.title) // Make sure to set others to not current
        } else {
            print("No such campaign exists")
        }
    }
    func updateLocalCampaignIsCurrent(campaign: String) {
        for myCampaign in campaigns {
            myCampaign.value.isCurrent = false
        }
        campaigns[campaign]?.isCurrent = true
    }
    func updateCloudCampaignIsCurrent(campaign: String) {
        var records = [CKRecord]()
        for myCampaign in self.campaigns {
            if myCampaign.value.isCurrent == true {
            } else {
                let campaignRecordID = CKRecordID(recordName: myCampaign.value.title)
                let campaignRecord = CKRecord(recordType: "CampaignStatus", recordID: campaignRecordID)
                campaignRecord["isCurrent"] = false as CKRecordValue
                
                records.append(campaignRecord)
            }
        }
        // Need to put these into a separate function/class one day
        let uploadOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        uploadOperation.savePolicy = .allKeys
        uploadOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordsIDs, error in
            if let ckError = error as? CKError {
                self.delegate?.errorUpdating(error: ckError as CKError, type: myCKErrorType.saveScenarioStatus)
                print("Error updating campaign isCurrent statuses: \(error!.localizedDescription)")
            } else {
            }
        }
        self.myCloudKitMgr.privateDatabase.add(uploadOperation)
    }
    // Party functions
    func createParty(name: String, characters: [Character], location: String, achievements: [String:Bool], reputation: Int, isCurrent: Bool, assignedTo: String, notes: String) {
        if (parties[name] == nil) {
            let newParty = Party(name: name, characters: characters, location: location, achievements: createPartyAchievements(), reputation: reputation, isCurrent: isCurrent, assignedTo: assignedTo, notes: notes)
            parties[name] = newParty
            if newParty.isCurrent == true {
                loadParty(party: newParty.name)
            }
            //print("Added party: \(newParty.name)")
        } else {
            //print("Party \(parties[name]!.name) already exists!")
        }
    }
    func loadParty(party: String) {
        if let requestedParty = parties[party] {
            for achievement in partyAchievements.keys {
                let newStatus = requestedParty.achievements[achievement]
                self.partyAchievements[achievement] = newStatus
                updateLocalPartyIsCurrent(party: party)
            }
            print("In Load, getting \(requestedParty.notes) for \(requestedParty.name)")
            for party in parties {
                print("Party \(party.key) has notes: \(party.value.notes)")
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadParty"), object: nil) // Trigger setRequirementsMetForCurrentParty in Scenario VM
        } else {
            //print("No such party exists")
        }
    }
    func updateLocalPartyIsCurrent(party: String) {
        for myParty in parties {
            myParty.value.isCurrent = false
        }
        parties[party]!.isCurrent = true
    }
    func createPartyAchievements() -> [String:Bool] {
        let newAchievements = [
            "None"                                  : true,
            "OR"                                    : true,
            "A Demon's Errand"                      : false,
            "A Map to Treasure"                     : false,
            "Across the Divide"                     : false,
            "An Invitation"                         : false,
            "Bad Business"                          : false,
            "Bravery"                               : false,
            "Dark Bounty"                           : false,
            "Debt Collection"                       : false,
            "Finding the Cure personal quest"       : false,
            "First Steps"                           : false,
            "Fish's Aid"                            : false,
            "Following Clues"                       : false,
            "Grave Job"                             : false,
            "High Sea Escort"                       : false,
            "Jekserah's Plans"                      : false,
            "Seeker of Xorn personal quest"         : false,
            "Staff of Xorn item equipped"           : false,
            "Redthorn's Aid"                        : false,
            "Sin-Ra"                                : false,
            "Stonebreaker's Censer"                 : false,
            "Take Back the Trees personal quest"    : false,
            "The Drake's Command"                   : false,
            "The Drake's Treasure"                  : false,
            "The Fall of Man personal quest"        : false,
            "The Poison's Source"                   : false,
            "The Scepter and the Voice"             : false,
            "The Voice's Command"                   : false,
            "The Voice's Treasure"                  : false,
            "Through the Nest"                      : false,
            "Through the Ruins"                     : false,
            "Through the Trench"                    : false,
            "Tremors"                               : false,
            "Vengeance personal quest"              : false,
            "Water Staff"                           : false
        ]
        return newAchievements
    }
    // End party functions
    // MARK: Create character types dictionary
    func createCharacterTypes() -> [String:Bool] {
        let availableCharacterTypes = [
            "Beast Tyrant"                          : false,
            "Berserker"                             : false,
            "Brute"                                 : true,
            "Cragheart"                             : true,
            "Doomstalker"                           : false,
            "Elementalist"                          : false,
            "Mindthief"                             : true,
            "Nightshroud"                           : false,
            "Plagueherald"                          : false,
            "Quartermaster"                         : false,
            "Sawbones"                              : false,
            "Scoundrel"                             : true,
            "Soothsinger"                           : false,
            "Spellweaver"                           : true,
            "Summoner"                              : false,
            "Sunkeeper"                             : false,
            "Tinkerer"                              : true
            ]
        return availableCharacterTypes
    }
    // MARK: Create new events array
    func createEvents() -> [Event] {
        var newEvents = [Event]()
        // Create Road Event objects and append to events array
        let r1 = Event(
            type: .road,
            number: "Road 01",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r1)
        let r2 = Event(
            type: .road,
            number: "Road 02",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r2)
        let r3 = Event(
            type: .road,
            number: "Road 03",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r3)
        let r4 = Event(
            type: .road,
            number: "Road 04",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r4)
        let r5 = Event(
            type: .road,
            number: "Road 05",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r5)
        let r6 = Event(
            type: .road,
            number: "Road 06",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r6)
        let r7 = Event(
            type: .road,
            number: "Road 07",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r7)
        let r8 = Event(
            type: .road,
            number: "Road 08",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r8)
        let r9 = Event(
            type: .road,
            number: "Road 09",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r9)
        let r10 = Event(
            type: .road,
            number: "Road 10",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r10)
        let r11 = Event(
            type: .road,
            number: "Road 11",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r11)
        let r12 = Event(
            type: .road,
            number: "Road 12",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r12)
        let r13 = Event(
            type: .road,
            number: "Road 13",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r13)
        let r14 = Event(
            type: .road,
            number: "Road 14",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r14)
        let r15 = Event(
            type: .road,
            number: "Road 15",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r15)
        let r16 = Event(
            type: .road,
            number: "Road 16",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r16)
        let r17 = Event(
            type: .road,
            number: "Road 17",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r17)
        let r18 = Event(
            type: .road,
            number: "Road 18",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        
        newEvents.append(r18)
        let r19 = Event(
            type: .road,
            number: "Road 19",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r19)
        let r20 = Event(
            type: .road,
            number: "Road 20",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r20)
        let r21 = Event(
            type: .road,
            number: "Road 21",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r21)
        let r22 = Event(
            type: .road,
            number: "Road 22",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r22)
        let r23 = Event(
            type: .road,
            number: "Road 23",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r23)
        let r24 = Event(
            type: .road,
            number: "Road 24",
            choice: "",
            unlocks: "82",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r24)
        let r25 = Event(
            type: .road,
            number: "Road 25",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r25)
        let r26 = Event(
            type: .road,
            number: "Road 26",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r26)
        let r27 = Event(
            type: .road,
            number: "Road 27",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r27)
        let r28 = Event(
            type: .road,
            number: "Road 28",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r28)
        let r29 = Event(
            type: .road,
            number: "Road 29",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r29)
        let r30 = Event(
            type: .road,
            number: "Road 30",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(r30)
        let r31 = Event(
            type: .road,
            number: "Road 31",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r31)
        let r32 = Event(
            type: .road,
            number: "Road 32",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r32)
        let r33 = Event(
            type: .road,
            number: "Road 33",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r33)
        let r34 = Event(
            type: .road,
            number: "Road 34",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r34)
        let r35 = Event(
            type: .road,
            number: "Road 35",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r35)
        let r36 = Event(
            type: .road,
            number: "Road 36",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r36)
        let r37 = Event(
            type: .road,
            number: "Road 37",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r37)
        let r38 = Event(
            type: .road,
            number: "Road 38",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r38)
        let r39 = Event(
            type: .road,
            number: "Road 39",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r39)
        let r40 = Event(
            type: .road,
            number: "Road 40",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r40)
        let r41 = Event(
            type: .road,
            number: "Road 41",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r41)
        let r42 = Event(
            type: .road,
            number: "Road 42",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r42)
        let r43 = Event(
            type: .road,
            number: "Road 43",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r43)
        let r44 = Event(
            type: .road,
            number: "Road 44",
            choice: "",
            unlocks: "90",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r44)
        let r45 = Event(
            type: .road,
            number: "Road 45",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r45)
        let r46 = Event(
            type: .road,
            number: "Road 46",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r46)
        let r47 = Event(
            type: .road,
            number: "Road 47",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r47)
        let r48 = Event(
            type: .road,
            number: "Road 48",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r48)
        let r49 = Event(
            type: .road,
            number: "Road 49",
            choice: "",
            unlocks: "80",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r49)
        let r50 = Event(
            type: .road,
            number: "Road 50",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r50)
        let r51 = Event(
            type: .road,
            number: "Road 51",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r51)
        let r52 = Event(
            type: .road,
            number: "Road 52",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r52)
        let r53 = Event(
            type: .road,
            number: "Road 53",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r53)
        let r54 = Event(
            type: .road,
            number: "Road 54",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r54)
        let r55 = Event(
            type: .road,
            number: "Road 55",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r55)
        let r56 = Event(
            type: .road,
            number: "Road 56",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r56)
        let r57 = Event(
            type: .road,
            number: "Road 57",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r57)
        let r58 = Event(
            type: .road,
            number: "Road 58",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r58)
        let r59 = Event(
            type: .road,
            number: "Road 59",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r59)
        let r60 = Event(
            type: .road,
            number: "Road 60",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r60)
        let r61 = Event(
            type: .road,
            number: "Road 61",
            choice: "",
            unlocks: "85",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r61)
        let r62 = Event(
            type: .road,
            number: "Road 62",
            choice: "",
            unlocks: "85",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r62)
        let r63 = Event(
            type: .road,
            number: "Road 63",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r63)
        let r64 = Event(
            type: .road,
            number: "Road 64",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r64)
        let r65 = Event(
            type: .road,
            number: "Road 65",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r65)
        let r66 = Event(
            type: .road,
            number: "Road 66",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r66)
        let r67 = Event(
            type: .road,
            number: "Road 67",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r67)
        let r68 = Event(
            type: .road,
            number: "Road 68",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r68)
        let r69 = Event(
            type: .road,
            number: "Road 69",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(r69)
        // Create City Event objects and append to events array
        let c1 = Event(
            type: .city,
            number: "City 01",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c1)
        let c2 = Event(
            type: .city,
            number: "City 02",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c2)
        let c3 = Event(
            type: .city,
            number: "City 03",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c3)
        let c4 = Event(
            type: .city,
            number: "City 04",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c4)
        let c5 = Event(
            type: .city,
            number: "City 05",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c5)
        let c6 = Event(
            type: .city,
            number: "City 06",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c6)
        let c7 = Event(
            type: .city,
            number: "City 07",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c7)
        let c8 = Event(
            type: .city,
            number: "City 08",
            choice: "",
            unlocks: "93",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c8)
        let c9 = Event(
            type: .city,
            number: "City 09",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c9)
        let c10 = Event(
            type: .city,
            number: "City 10",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c10)
        let c11 = Event(
            type: .city,
            number: "City 11",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c11)
        let c12 = Event(
            type: .city,
            number: "City 12",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c12)
        let c13 = Event(
            type: .city,
            number: "City 13",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c13)
        let c14 = Event(
            type: .city,
            number: "City 14",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c14)
        let c15 = Event(
            type: .city,
            number: "City 15",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c15)
        let c16 = Event(
            type: .city,
            number: "City 16",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c16)
        let c17 = Event(
            type: .city,
            number: "City 17",
            choice: "",
            unlocks: "81",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c17)
        let c18 = Event(
            type: .city,
            number: "City 18",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        
        newEvents.append(c18)
        let c19 = Event(
            type: .city,
            number: "City 19",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c19)
        let c20 = Event(
            type: .city,
            number: "City 20",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c20)
        let c21 = Event(
            type: .city,
            number: "City 21",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c21)
        let c22 = Event(
            type: .city,
            number: "City 22",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c22)
        let c23 = Event(
            type: .city,
            number: "City 23",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c23)
        let c24 = Event(
            type: .city,
            number: "City 24",
            choice: "",
            unlocks: "82",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c24)
        let c25 = Event(
            type: .city,
            number: "City 25",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c25)
        let c26 = Event(
            type: .city,
            number: "City 26",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c26)
        let c27 = Event(
            type: .city,
            number: "City 27",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c27)
        let c28 = Event(
            type: .city,
            number: "City 28",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c28)
        let c29 = Event(
            type: .city,
            number: "City 29",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c29)
        let c30 = Event(
            type: .city,
            number: "City 30",
            choice: "",
            unlocks: "None",
            isAvailable: true,
            isCompleted: false
        )
        newEvents.append(c30)
        let c31 = Event(
            type: .city,
            number: "City 31",
            choice: "",
            unlocks: "83",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c31)
        let c32 = Event(
            type: .city,
            number: "City 32",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c32)
        let c33 = Event(
            type: .city,
            number: "City 33",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c33)
        let c34 = Event(
            type: .city,
            number: "City 34",
            choice: "",
            unlocks: "78",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c34)
        let c35 = Event(
            type: .city,
            number: "City 35",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c35)
        let c36 = Event(
            type: .city,
            number: "City 36",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c36)
        let c37 = Event(
            type: .city,
            number: "City 37",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c37)
        let c38 = Event(
            type: .city,
            number: "City 38",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c38)
        let c39 = Event(
            type: .city,
            number: "City 39",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c39)
        let c40 = Event(
            type: .city,
            number: "City 40",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c40)
        let c41 = Event(
            type: .city,
            number: "City 41",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c41)
        let c42 = Event(
            type: .city,
            number: "City 42",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c42)
        let c43 = Event(
            type: .city,
            number: "City 43",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c43)
        let c44 = Event(
            type: .city,
            number: "City 44",
            choice: "",
            unlocks: "90",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c44)
        let c45 = Event(
            type: .city,
            number: "City 45",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c45)
        let c46 = Event(
            type: .city,
            number: "City 46",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c46)
        let c47 = Event(
            type: .city,
            number: "City 47",
            choice: "",
            unlocks: "87",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c47)
        let c48 = Event(
            type: .city,
            number: "City 48",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c48)
        let c49 = Event(
            type: .city,
            number: "City 49",
            choice: "",
            unlocks: "80",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c49)
        let c50 = Event(
            type: .city,
            number: "City 50",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c50)
        let c51 = Event(
            type: .city,
            number: "City 51",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c51)
        let c52 = Event(
            type: .city,
            number: "City 52",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c52)
        let c53 = Event(
            type: .city,
            number: "City 53",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c53)
        let c54 = Event(
            type: .city,
            number: "City 54",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c54)
        let c55 = Event(
            type: .city,
            number: "City 55",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c55)
        let c56 = Event(
            type: .city,
            number: "City 56",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c56)
        let c57 = Event(
            type: .city,
            number: "City 57",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c57)
        let c58 = Event(
            type: .city,
            number: "City 58",
            choice: "",
            unlocks: "91",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c58)
        let c59 = Event(
            type: .city,
            number: "City 59",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c59)
        let c60 = Event(
            type: .city,
            number: "City 60",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c60)
        let c61 = Event(
            type: .city,
            number: "City 61",
            choice: "",
            unlocks: "85",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c61)
        let c62 = Event(
            type: .city,
            number: "City 62",
            choice: "",
            unlocks: "85",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c62)
        let c63 = Event(
            type: .city,
            number: "City 63",
            choice: "",
            unlocks: "86",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c63)
        let c64 = Event(
            type: .city,
            number: "City 64",
            choice: "",
            unlocks: "89",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c64)
        let c65 = Event(
            type: .city,
            number: "City 65",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c65)
        let c66 = Event(
            type: .city,
            number: "City 66",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c66)
        let c67 = Event(
            type: .city,
            number: "City 67",
            choice: "",
            unlocks: "92",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c67)
        let c68 = Event(
            type: .city,
            number: "City 68",
            choice: "",
            unlocks: "88",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c68)
        let c69 = Event(
            type: .city,
            number: "City 69",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c69)
        let c70 = Event(
            type: .city,
            number: "City 70",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c70)
        let c71 = Event(
            type: .city,
            number: "City 71",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c71)
        let c72 = Event(
            type: .city,
            number: "City 72",
            choice: "",
            unlocks: "79",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c72)
        let c73 = Event(
            type: .city,
            number: "City 73",
            choice: "",
            unlocks: "84",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c73)
        let c74 = Event(
            type: .city,
            number: "City 74",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c74)
        let c75 = Event(
            type: .city,
            number: "City 75",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c75)
        let c76 = Event(
            type: .city,
            number: "City 76",
            choice: "",
            unlocks: "74",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c76)
        let c77 = Event(
            type: .city,
            number: "City 77",
            choice: "",
            unlocks: "75",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c77)
        let c78 = Event(
            type: .city,
            number: "City 78",
            choice: "",
            unlocks: "94",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c78)
        let c79 = Event(
            type: .city,
            number: "City 79",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c79)
        let c80 = Event(
            type: .city,
            number: "City 80",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c80)
        let c81 = Event(
            type: .city,
            number: "City 81",
            choice: "",
            unlocks: "None",
            isAvailable: false,
            isCompleted: false
        )
        newEvents.append(c81)
        return newEvents
    }
    func createDefaultCampaign() {
        createCampaign(title: "MyCampaign", isCurrent: true, parties: [createDefaultParty()])
    }
    func createDefaultParty() -> Party {
        createParty(name: "MyParty", characters: [], location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: "MyCampaign", notes: "Party Notes")
        return self.parties["MyParty"]!
    }
    func resetAll() {
        for scenario in allScenarios {
            if scenario.number == "1" {
                scenario.isCompleted = false
                scenario.isAvailable = true
                scenario.isUnlocked = true
                //continue
            } else {
                scenario.isUnlocked = false
                scenario.isCompleted = false
                scenario.isAvailable = false
            }
        }
        for achievement in globalAchievements {
            if achievement.key == "None" || achievement.key == "OR" {
                globalAchievements[achievement.key] = true
            } else {
                globalAchievements[achievement.key] = false
            }
        }
        for achievement in partyAchievements {
            if achievement.key == "None" || achievement.key == "OR" {
                partyAchievements[achievement.key] = true
            } else {
                partyAchievements[achievement.key] = false
            }
        }
    }
    // CloudKit methods
    func updateCampaignRecords() {
        //Put call to func to check if logged into iCloud here?
        var records = [CKRecord]()
        let campaignRecordID = CKRecordID(recordName: (currentCampaign.title))
        let campaignRecord = CKRecord(recordType: "CampaignStatus", recordID: campaignRecordID)
        //let campaignReference = CKReference(recordID: campaignRecordID, action: .deleteSelf)
        let campaignTitle = currentCampaign.title
        let partyName = currentParty.name
        campaignRecord["title"] = campaignTitle as CKRecordValue
        let campaignIsCurrent = currentCampaign.isCurrent
        campaignRecord["isCurrent"] = campaignIsCurrent as CKRecordValue

        records.append(campaignRecord)
        
        for party in assignedParties! {
            let partyRecordID = CKRecordID(recordName: party.name)
            let partyRecord = CKRecord(recordType: "Party", recordID: partyRecordID)
            let partyName = party.name
            partyRecord["name"] = partyName as NSString
            //let party
        }
        for scenario in allScenarios {
            let scenarioStatusRecordID = CKRecordID(recordName: scenario.number + "_\(currentCampaign.title)")
            let scenarioStatusRecord = CKRecord(recordType: "ScenarioStatus", recordID: scenarioStatusRecordID)
            
            let completedState = scenario.isCompleted ? 1 : 0
            scenarioStatusRecord["isCompleted"] = completedState as NSNumber
            let unlockedState = scenario.isUnlocked ? 1 : 0
            scenarioStatusRecord["isUnlocked"] = unlockedState as NSNumber
            let requirementsMetState = scenario.requirementsMet ? 1 : 0
            scenarioStatusRecord["requirementsMet"] = requirementsMetState as NSNumber
            scenarioStatusRecord["owningCampaign"] = campaignTitle as CKRecordValue

            records.append(scenarioStatusRecord)
            
        }
        for achievement in globalAchievements {
            let achievementStatusRecordID = CKRecordID(recordName: achievement.key + "_\(currentCampaign.title)")
            let achievementStatusRecord = CKRecord(recordType: "Achievement", recordID: achievementStatusRecordID)
            let achievementState = achievement.value ? 1 : 0
            achievementStatusRecord["isComplete"] = achievementState as NSNumber
            achievementStatusRecord["owningCampaign"] = campaignTitle as CKRecordValue
            
            records.append(achievementStatusRecord)
        }
        for partyAchievement in partyAchievements {
            let partyAchievementStatusRecordID = CKRecordID(recordName: partyAchievement.key + "_\(partyName)")
            let partyAchievementStatusRecord = CKRecord(recordType: "PartyAchievement", recordID: partyAchievementStatusRecordID)
            let partyAchievementState = partyAchievement.value ? 1 : 0
            partyAchievementStatusRecord["isComplete"] = partyAchievementState as NSNumber
            partyAchievementStatusRecord["owningParty"] = partyName as CKRecordValue
            
            records.append(partyAchievementStatusRecord)
        }
        for character in self.characters {
            let characterRecordID = CKRecordID(recordName: character.key)
            let characterRecord = CKRecord(recordType: "Character", recordID: characterRecordID)
            characterRecord["name"] = character.value.name as NSString
            characterRecord["goal"] = character.value.goal as NSString
            characterRecord["type"] = character.value.type as NSString
            characterRecord["level"] = character.value.level as NSNumber
            let isActiveState = character.value.isActive ? 1 : 0
            characterRecord["isActive"] = isActiveState as NSNumber
            let isRetiredState = character.value.isRetired ? 1 : 0
            characterRecord["isRetired"] = isRetiredState as NSNumber
            characterRecord["assignedTo"] = character.value.assignedTo! as NSString
            
            for scenario in character.value.playedScenarios! {
                characterRecord[scenario] = scenario as NSString
            }
            
            records.append(characterRecord)
        }

        let uploadOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        uploadOperation.savePolicy = .allKeys
        uploadOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordsIDs, error in
            if let ckError = error as? CKError {
                self.delegate?.errorUpdating(error: ckError as CKError, type: myCKErrorType.saveScenarioStatus)
                print("Error saving campaign records: \(error!.localizedDescription)")
            } else {
                print("Successfully saved campaign records")
                self.delegate?.hideProgressHUD()
                self.delegate?.restoreViewBGColor()
            }
        }
        delegate?.darkenViewBGColor()
        delegate?.showProgressHUD()
        self.myCloudKitMgr.privateDatabase.add(uploadOperation)
    }
    func checkIfCampaignRecordExists(completion:@escaping (String?) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CampaignStatus", predicate: predicate)
        
        myCloudKitMgr.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let ckError = error as? CKError {
                self.delegate?.errorUpdating(error: ckError as CKError, type: myCKErrorType.fetchRecord)
                print("Didn't find an existing iCloud schema.")
                completion(nil)
            } else {
                for record in records! {
                    if record.value(forKey: "isCurrent") as! Bool == true {
                        completion(record.value(forKey: "title") as? String)
                    }
                }
                print("Found pre-existing iCloud schema.")
            }
        }
    }
    func updateCampaignsFromCloud(completion: @escaping ([String:Campaign]) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "CampaignStatus", predicate: predicate)
        var campaignName = String()
        myCloudKitMgr.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let ckError = error as? CKError {
                self.delegate?.errorUpdating(error: ckError as CKError, type: myCKErrorType.fetchRecord)
                print("Error updating local campaigns from iCloud.")
            } else {
                for record in records! {
                    campaignName = record.recordID.recordName
                    let current = record["isCurrent"] as! Bool == true ? true : false
                    print("From cloud, campaignName is \(campaignName)")
                    self.createCampaign(title: campaignName, isCurrent: current, parties: [])
                    let newCampaign = self.campaigns[campaignName]!
                    newCampaign.isCurrent = record["isCurrent"] as! Bool
                    newCampaign.parties = record["parties"] as? [Party]
                    self.getAchievementsStatusFromCloud(campaign: newCampaign.title) { achievements in
                        newCampaign.achievements = achievements
                    }
                    self.getScenarioStatusFromCloud(campaign: newCampaign.title) { isUnlocked, _, _ in
                        for myUnlocked in isUnlocked {
                            newCampaign.isUnlocked[Int(myUnlocked.key)! - 1] = myUnlocked.value
                        }
                    }
                    self.getScenarioStatusFromCloud(campaign: newCampaign.title) { _, isCompleted, _ in
                        for myIsCompleted in isCompleted {
                            newCampaign.isCompleted[Int(myIsCompleted.key)! - 1] = myIsCompleted.value
                        }
                    }
                    self.getScenarioStatusFromCloud(campaign: newCampaign.title) { _, _, requirementsMet in
                        for myRequirementsMet in requirementsMet {
                            newCampaign.requirementsMet[Int(myRequirementsMet.key)! - 1] = myRequirementsMet.value
                        }
                    }
                    self.campaigns[campaignName] = newCampaign
                }
                completion(self.campaigns)
            }
        }
    }
    func getAchievementsStatusFromCloud(campaign: String, completion: @escaping ([String:Bool]) -> ()) {
        let predicate = NSPredicate(format:"owningCampaign == %@", campaign)
        let query = CKQuery(recordType: "Achievement", predicate: predicate)
        var cloudAchievements = [String:Bool]()
        myCloudKitMgr.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let ckError = error as? CKError {
                self.delegate?.errorUpdating(error: ckError as CKError, type: myCKErrorType.fetchRecord)
                print("Error fetching record: \(error!.localizedDescription)")
            } else {
                print("Found \(records!.count) Achievement records matching query")
                for record in records! {
                    let newStatus = record["isComplete"] as! Bool
                    let recordName = record.recordID.recordName
                    let shortenedKey = recordName.replacingOccurrences(of: "_" + campaign, with: "")
                    cloudAchievements[shortenedKey] = newStatus
                }
                completion(cloudAchievements)
            }
        }
    }
    func getScenarioStatusFromCloud(campaign: String, completion: @escaping ([String:Bool], [String:Bool], [String:Bool]) -> ()) {
        let predicate = NSPredicate(format:"owningCampaign == %@", campaign)
        let query = CKQuery(recordType: "ScenarioStatus", predicate: predicate)
        
        var myIsUnlocked = [String:Bool]()
        var myIsCompleted = [String:Bool]()
        var myRequirementsMet = [String:Bool]()
        
        myCloudKitMgr.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let ckError = error as? CKError {
                self.delegate?.errorUpdating(error: ckError as CKError, type: myCKErrorType.fetchRecord)
                print("Error fetching record: \(error!.localizedDescription)")
            } else {
                print("Found \(records!.count) Scenario records matching query")
                for record in records! {
                    let recordName = record.recordID.recordName
                    let number = recordName.replacingOccurrences(of: "_" + campaign, with: "")
                    let isUnlockedStatus = record["isUnlocked"] as! Bool
                    myIsUnlocked[number] = isUnlockedStatus
                    let isCompletedStatus = record["isCompleted"] as! Bool
                    myIsCompleted[number] = isCompletedStatus
                    let requirementsMetStatus = record["requirementsMet"] as! Bool
                    myRequirementsMet[number] = requirementsMetStatus
                }
                completion(myIsUnlocked, myIsCompleted, myRequirementsMet)
            }
        }
    }
    func getCharactersFromCloud(completion: @escaping (String, String, String, Double, Bool, Bool, String) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Character", predicate: predicate)
        
//        var myName = String()
//        var myGoal = String()
//        var myType = String()
//        var myLevel = Double()
//        var myIsActive = Bool()
//        var myIsRetired = Bool()
//        var myIsAssignedTo = String()
        
        myCloudKitMgr.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let ckError = error as? CKError {
                self.delegate?.errorUpdating(error: ckError as CKError, type: myCKErrorType.fetchRecord)
                print("Error fetching record: \(error!.localizedDescription)")
            } else {
                print("Found \(records!.count) Character records matching query.")
            }
        }
        //completion(myName, myGoal, myType, myLevel, myIsActive, myIsRetired, myIsAssignedTo)
    }
}
extension UIImage {
    
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

class ScenarioNumberAndTitle {
    
    var number: String?
    var title: String?
    
    func returnTitle (number: String) -> String {
        // Need to address "None" case (e.g. first scenario has no unlocker)
        if let title = DataModel.sharedInstance.getScenario(scenarioNumber: number)?.title {
            return title
        } else if number.contains("Event") { //Address case where unlockedBy is Event
            title = ""
            return title!
        } else {
            title = "None"
            return title!
        }
    }
    init(number: String) {
        self.number = number
        self.title = returnTitle(number: number)
    }
}

class SeparatedAttributedStrings {
    
    var rowString: NSAttributedString?
    
    init(rowString: NSAttributedString) {
        self.rowString = rowString
    }
}

class SeparatedStrings {
    var rowString: String?
    
    init(rowString: String) {
        self.rowString = rowString
    }
}

class AssetExtractor {
    
    static func createLocalUrl(forImageNamed name: String) -> URL? {
        
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).png")
        let path = url.path
        
        guard fileManager.fileExists(atPath: path) else {
            guard
                let image = UIImage(named: name),
                let data = UIImagePNGRepresentation(image)
                else { return nil }
            
            fileManager.createFile(atPath: path, contents: data, attributes: nil)
            return url
        }
        
        return url
    }
}
