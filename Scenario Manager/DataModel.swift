//
//  DataModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/3/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

class DataModel {
    
    // Try singleton
    static var sharedInstance = DataModel()
    
    var allScenarios = [Scenario]()
    var achievements = [ String : Bool ]()
    var availableScenarios: [Scenario] {
        get {
            print("Getting available scenarios")
            return allScenarios.filter { $0.isUnlocked == true && $0.requirementsMet == true && $0.completed == false }
        }
    }
    var completedScenarios: [Scenario] {
        get {
            print("Getting completed scenarios")
            return allScenarios.filter { $0.completed == true }
        }
    }
    var requirementsMet = false
    var myAchieves = [String]()
    var or = false
    var unlocksLabel = String()
    var selectedScenario: Scenario?
    var mainCellBGImage = UIImage()

    // Test 
    let testAttribute = [ "image" : #imageLiteral(resourceName: "spikyHeadGuy")]

    
    // Used by all VCs that color rows
    let unavailableBGColor = UIColor(hue: 30/360, saturation: 0/100, brightness: 95/100, alpha: 1.0)
    let availableBGColor = UIColor.white
    let completedBGColor = UIColor(hue: 30/360, saturation: 0/100, brightness: 90/100, alpha: 1.0)
    
    let defaultUnlocks = [ "13" : ["ONEOF", "15", "17", "20"] ]

    
    
    
    private init() {
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("Scenarios.plist")?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!){
            loadScenarios()
            
        } else {
        
            let scenario44String = NSMutableAttributedString(string: "Open envelope ")
            let image44Attachment = NSTextAttachment()
            image44Attachment.image = UIImage(named: "spikyHeadGuy.png")
            let image44String = NSAttributedString(attachment: image44Attachment)
            scenario44String.append(image44String)
            
            let scenario54String = NSMutableAttributedString(string: "Open envelope ")
            let image54Attachment = NSTextAttachment()
            image54Attachment.image = UIImage(named: "cthulhuFace.png")
            let image54String = NSAttributedString(attachment: image54Attachment)
            scenario54String.append(image54String)
            
            let scenario62String = NSMutableAttributedString(string: "Open envelope ")
            let image62Attachment = NSTextAttachment()
            image62Attachment.image = UIImage(named: "moonSymbol.png")
            let image62String = NSAttributedString(attachment: image62Attachment)
            scenario62String.append(image62String)
            
            let row0Scenario = Scenario(number: "1", title: "The Black Barrow", completed: false, requirementsMet: true, requirements: ["None": true], isUnlocked: true, unlockedBy: ["None"], unlocks: ["2"], achieves: ["First Steps"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill All Enemies.\n\nYou’ve just arrived in town, and you’re hungry for action. And food. Retrieve some stolen documents for Jekserah, a Valrath merchant.", locationString: "G-10, Corpsewood", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap1")
            allScenarios.append(row0Scenario)
            
            let row1Scenario = Scenario(number: "2", title: "Barrow Lair", completed: false, requirementsMet: false, requirements: ["First Steps": true], isUnlocked: false, unlockedBy: ["1"], unlocks: ["3", "4"], achieves: ["None"], rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Kill Bandit Commander and all revealed enemies.\n\nPursue the Bandit Commander deeper into the Barrow.", locationString: "G-11, Corpsewood", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap2")
            allScenarios.append(row1Scenario)

            let row2Scenario = Scenario(number: "3", title: "Inox Encampment", completed: false, requirementsMet: false, requirements: ["The Merchant Flees": false], isUnlocked: false, unlockedBy: ["2"], unlocks: ["8", "9"], achieves: ["Jekserah's Plans"], rewards: [NSAttributedString(string: "15 Gold Each"), NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Kill a number of enemies equal to five times the number of characters.\n\nJekserah would like you to deal with a band of Inox that have been harassing her trade caravans.", locationString: "G-3, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap3")
            allScenarios.append(row2Scenario)

            let row3Scenario = Scenario(number: "4", title: "Crypt of the Damned", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["2"], unlocks: ["5", "6"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies.\n\nBefore killing the Bandit Commander in the Barrow Lair, he mentioned something about the 'Gloom'. This might be a place we could learn more about it.", locationString: "E-11, Still River", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap4")
            allScenarios.append(row3Scenario)

            let row4Scenario = Scenario(number: "5", title: "Ruinous Crypt", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["4"], unlocks: ["10", "14", "19"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies.\n\nThe script you found in the Crypt of the Damned led you here, where it seems the Cultists are channeling Demons through an infernal portal. You can disrupt their plans by closing the rift.", locationString: "D-6, Stone Road", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap5")
            allScenarios.append(row4Scenario)

            let row5Scenario = Scenario(number: "6", title: "Decaying Crypt", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["4"], unlocks: ["8"], achieves: ["Jekserah's Plans", "Dark Bounty"], rewards: [NSAttributedString(string: "5 Gold Each")], summary: "Goal: Reveal the M tile and kill all revealed enemies.\n\nYou decide to lend the Cultists a hand and clear out some undead that have taken up residence at an important area of power.", locationString: "F-10, Still River", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap6")
            allScenarios.append(row5Scenario)

            let row6Scenario = Scenario(number: "7", title: "Vibrant Grotto", completed: false, requirementsMet: false, requirements: ["The Power of Enhancement": true, "The Merchant Flees": true], isUnlocked: false, unlockedBy: ["8"], unlocks: ["20"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Loot all treasure tiles.\n\nJekserah's gotten away, unfortunately, but the City Guard Argeise told you about an Aesther Enchanter named Hail who might be able to help. You'll have to fetch her some Biteroot first, however.", locationString: "C-12, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap7")
            allScenarios.append(row6Scenario)

            let row7Scenario = Scenario(number: "8", title: "Gloomhaven Warehouse", completed: false, requirementsMet: false, requirements: ["Jekserah's Plans": true, "The Dead Invade": false], isUnlocked: false, unlockedBy: ["3", "6"], unlocks: ["7", "13", "14"], achieves: ["The Merchant Flees"], rewards: [NSAttributedString(string: "+2 Reputation")], summary: "Goal: Kill both Inox bodyguards.\n\nA menacing figure has offered to exonerate your team of murder if you bring him Jekserah's head. She's hiding in the warehouse with more of her baddies, most likely.", locationString: "C-18, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap8")
            allScenarios.append(row7Scenario)

            let row8Scenario = Scenario(number: "9", title: "Diamond Mine", completed: false, requirementsMet: false, requirements: ["The Merchant Flees": false], isUnlocked: false, unlockedBy: ["3"], unlocks: ["11", "12"], achieves: ["The Dead Invade"], rewards: [NSAttributedString(string: "20 Gold Each"), NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Kill the Merciless Overseer and loot the treasure tile.\n\nBack at the Inox Encampment, Argeise warned you about this place, but you have dollar signs in your eyes. Take down the big guy and reap the rewards.", locationString: "L-2, Watcher Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap9")
            allScenarios.append(row8Scenario)

            let row9Scenario = Scenario(number: "10", title: "Plane of Elemental Power", completed: false, requirementsMet: false, requirements: ["The Rift Closed": false], isUnlocked: false, unlockedBy: ["5"], unlocks: ["21", "22"], achieves: ["A Demon's Errand"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies.\n\nYou step through the portal back in the Ruinous Crypt and end up here, wherever that is. You need to venture deeper, and to do that you'll have to kill a lot of bad guys.", locationString: "C-7, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap10")
            allScenarios.append(row9Scenario)

            let row10Scenario = Scenario(number: "11", title: "Gloomhaven Square A", completed: false, requirementsMet: false, requirements: ["End of the Invasion": false], isUnlocked: false, unlockedBy: ["9"], unlocks: ["16", "18"], achieves: ["End of the Invasion"], rewards: [NSAttributedString(string: "15 Gold Each"), NSAttributedString(string: "-2 Reputation"), NSAttributedString(string: "+2 Prosperity")], summary: "Goal: Kill the Captain of the Guard.\n\nYou decide to go in with Jekserah, and help her take down the City Guard, placing town rule into the Merchants' hands.", locationString: "B-16, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap11")
            allScenarios.append(row10Scenario)

            let row11Scenario = Scenario(number: "12", title: "Gloomhaven Square B", completed: false, requirementsMet: false, requirements: ["End of the Invasion": false], isUnlocked: false, unlockedBy: ["9"], unlocks: ["16", "18", "28"], achieves: ["End of the Invasion"], rewards: [NSAttributedString(string: "+4 Reputation")], summary: "Goal: Kill Jekserah.\n\nYou throw in your lot with the City Guard and attempt to hold the square against Jekserah's armies of undead.", locationString: "B-16, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap12")
            allScenarios.append(row11Scenario)

            let row12Scenario = Scenario(number: "13", title: "Temple of the Seer", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["8"], unlocks: ["ONEOF", "15", "17", "20"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies.\n\nIn your quest to locate Jekserah, you decide to venture to a temple high in the mountains where it is said an oracle resides. Maybe they can divine the Valrath's whereabouts.", locationString: "N-3, Watcher Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap13")
            allScenarios.append(row12Scenario)

            let row13Scenario = Scenario(number: "14", title: "Frozen Hollow", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["8", "18"], unlocks: ["None"], achieves: ["The Power of Enhancement"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill All Enemies.\n\nYou first meet Hail, the Aesther Enchanter, at her 'shop' in the Boiler District. You're hoping to have her divine Jekserah's whereabouts, but instead, you end up trudging out to the Coppernecks to retrieve an orb for her.", locationString: "C-10, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap14")
            allScenarios.append(row13Scenario)

            let row14Scenario = Scenario(number: "15", title: "Shrine of Strength", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["13"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "20 XP Each")], summary: "Goal: Loot the treasure tile.\n\nA wish granted to you by the Disembodied Voice at the temple, this shrine is purported to make those who conquer it stronger. Strength need not imply muscles, of course.", locationString: "B-11, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap15")
            allScenarios.append(row14Scenario)

            let row15Scenario = Scenario(number: "16", title: "Mountain Pass", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["13", "20"], unlocks: ["24", "25"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies.\n\nThe Captain of the Guard was duly impressed with your performance at Gloomhaven Square, and thinks you're up to the task of dealing with the sudden appearance of 'Dragons' up near the northern pass.", locationString: "B-6, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap16")
            allScenarios.append(row15Scenario)
            
            let row16Scenario = Scenario(number: "17", title: "Lost Island", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["13"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "25 Gold Each")], summary: "Goal: Kill all enemies.\n\nThe strange voice from the temple told you you would find riches here on this remote hunk of rock. Hopefully, said riches won't come at the expense of your lives.", locationString: "K-17, Misty Sea", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap17")
            allScenarios.append(row16Scenario)
            
            let row17Scenario = Scenario(number: "18", title: "Abandoned Sewers", completed: false, requirementsMet: false, requirements: ["None": true], isUnlocked: false, unlockedBy: ["11", "12", "20"], unlocks: ["14", "23", "26", "43"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies.\n\nOur friend the Captain of the Guard offered us the distinct pleasure of spelunking the sewer system beneath town to put a stop to whatever's poisoning the wells in Sinking Market.", locationString: "C-14, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap18")
            allScenarios.append(row17Scenario)
            
            let row18Scenario = Scenario(number: "19", title: "Forgotten Crypt", completed: false, requirementsMet: false, requirements: ["The Power of Enhancement": true], isUnlocked: false, unlockedBy: ["5"], unlocks: ["27"], achieves: ["Stonebreaker's Censer"], rewards: [NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Protect Hail until she reaches the altar.\n\nYou once again seek Hail's help, this time in an attempt to close the Rift to the Plane of Power for good. Hail's going to need something called an \"Elemental Censer\" to get the job done, and she's the only one who can handle it. That means protecting Hail from whatever's crawling around the Crypt.", locationString: "M-7, Serpent's Kiss River", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap19")
            allScenarios.append(row18Scenario)
            
            let row19Scenario = Scenario(number: "20", title: "Necromancer's Sanctum", completed: false, requirementsMet: false, requirements: ["The Merchant Flees": true], isUnlocked: false, unlockedBy: ["7", "13"], unlocks: ["16", "18", "28"], achieves: ["Stonebreaker's Censer"], rewards: [NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Kill Jekserah.\n\nTime to put Jekserah out of your misery. Hail's information on Jekserah's whereabouts was hard to come by, and as you wend your way through the forest to the Valrath's hideout you intend to get your pain's worth.", locationString: "H-13, Corpsewood", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap20")
            allScenarios.append(row19Scenario)
            
            let row20Scenario = Scenario(number: "21", title: "Infernal Throne", completed: false, requirementsMet: false, requirements: ["The Rift Closed": false], isUnlocked: false, unlockedBy: ["10"], unlocks: ["None"], achieves: ["The Demon Dethroned"], rewards: [NSAttributedString(string: "50 Gold Each"), NSAttributedString(string: "+1 Prosperity"), NSAttributedString(string: "Add City Event 78")], summary: "Goal: Kill the Prime Demon.\n\nToo late to turn back now. You have chosen to face the Prime Demon in his own throne room. Problem is, you need to kill the altar, not him. And the altar has a bad habit of moving around chamber.", locationString: "C-7, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap21")
            allScenarios.append(row20Scenario)
            
            let row21Scenario = Scenario(number: "22", title: "Temple of the Elements", completed: false, requirementsMet: false, requirements: ["OR" : true, "A Demon's Errand" : true, "Following Clues" : true], isUnlocked: false, unlockedBy: ["10"], unlocks: ["31", "35", "36"], achieves: ["Artifact: Recovered"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Destroy all altars.\n\nYou decide to play along with the Prime Demon and agree to make your way out to the temple to retrieve a powerful artifact for him. There will be much altar-smashing involved.", locationString: "K-8, Serpent's Kiss River", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap22")
            allScenarios.append(row21Scenario)
            
            let row22Scenario = Scenario(number: "23", title: "Deep Ruins", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["18"], unlocks: ["None"], achieves: ["Through the Ruins", "Ancient Technology"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Occupy all pressure plates simultaneously.\n\nYou have to go further into the damned sewers to find the source of the poison. Looks like you've stumbled upon some ancient tech that controls the doors here.", locationString: "C-15, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap23")
            allScenarios.append(row22Scenario)
            
            let row23Scenario = Scenario(number: "24", title: "Echo Chamber", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["16"], unlocks: ["30", "32"], achieves: ["The Voice's Command"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Open all doors (fog tiles).\n\nA voice calls out to you from deep within a cave near the Mountain Pass, where Demon and Inox were caught consorting. The voice may have something to do with all this, and in any case you feel powerfully compelled to enter the cave.", locationString: "C-6, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap24")
            allScenarios.append(row23Scenario)
            
            let row24Scenario = Scenario(number: "25", title: "Icecrag Ascent", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["16"], unlocks: ["33", "34"], achieves: ["The Drake's Command"], rewards: [NSAttributedString(string: "None")], summary: "Goal: All characters must escape through the exit.\n\nDragon-chasing has led you to the top of Mountain Pass, and you have decided to brave the ascent in pursuit of, who knows what it could be?", locationString: "A-5, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap25")
            allScenarios.append(row24Scenario)
            
            let row25Scenario = Scenario(number: "26", title: "Ancient Cistern", completed: false, requirementsMet: false, requirements: ["OR" : true, "Water Breathing" : true, "Through the Ruins" : true], isUnlocked: false, unlockedBy: ["18"], unlocks: ["22"], achieves: ["Following Clues"], rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "+1 Reputation"), NSAttributedString(string: "+2 Prosperity")], summary: "Goal: Cleanse all water pumps.\n\nYou finally reach the inevitable final room, where you see the tainted water pumps. Between you and them lies a lot of Ooze.", locationString: "D-15, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap26")
            allScenarios.append(row25Scenario)
            
            let row26Scenario = Scenario(number: "27", title: "Ruinous Rift", completed: false, requirementsMet: false, requirements: ["Artifact: Lost" : false, "Stonebreaker's Censer" : true], isUnlocked: false, unlockedBy: ["19"], unlocks: ["22"], achieves: ["The Rift Closed"], rewards: [NSAttributedString(string: "100 Gold Each (spend on enhancements)")], summary: "Goal: Protect Hail for ten rounds.\n\nNow that you've helped Hail retrieve the Elemental Censer, you venture to the nexus of the Rift hoping Hail's scheme will work. You'll have to protect her once again as she does her thing.", locationString: "E-6, Stone Road", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap27")
            allScenarios.append(row26Scenario)
            
            let row27Scenario = Scenario(number: "28", title: "Outer Ritual Chamber", completed: false, requirementsMet: false, requirements: ["Dark Bounty" : true], isUnlocked: false, unlockedBy: ["20"], unlocks: ["29"], achieves: ["An Invitation"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies.\n\nJekserah's last words warned you of a grave threat that emanates from this chamber. Time to investigate and see if there's any truth to those words.", locationString: "E-4, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap28")
            allScenarios.append(row27Scenario)
            
            let row28Scenario = Scenario(number: "29", title: "Sanctuary of Gloom", completed: false, requirementsMet: false, requirements: ["An Invitation" : true], isUnlocked: false, unlockedBy: ["28"], unlocks: ["29"], achieves: ["The Edge of Darkness"], rewards: [NSAttributedString(string: "15 XP Each")], summary: "Goal: Kill all enemies.\n\nA familiar Voice beckons you to enter the rift you found in the Outer Ritual Chamber. You decide to see this through to the end, whatever that might be.", locationString: "E-4, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap29")
            allScenarios.append(row28Scenario)
            
            let row29Scenario = Scenario(number: "30", title: "Shrine of the Depths", completed: false, requirementsMet: false, requirements: ["The Voice's Command" : true], isUnlocked: false, unlockedBy: ["24"], unlocks: ["42"], achieves: ["The Scepter and the Voice"], rewards: [NSAttributedString(string: "10 Gold Each")], summary: "Goal: Loot the treasure tile.\n\nAfter consulting with a bookish Quatryl, you discover that the Voice you've been hearing is a Demon of terrible power. You now understand it's been attempting to trick you into freeing it from its plane of imprisonment. The Quatryl points you to a sunken shrine which contains a scepter that could strengthen the binding of the Demon to its plane. Retrieve the scepter.", locationString: "N-15, Misty Sea", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap30")
            allScenarios.append(row29Scenario)
            
            let row30Scenario = Scenario(number: "31", title: "Plane of Night", completed: false, requirementsMet: false, requirements: ["The Power of Enhancement" : true, "Artifact: Recovered" : true], isUnlocked: false, unlockedBy: ["22"], unlocks: ["37", "38", "39", "43"], achieves: ["Artifact: Cleansed"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Destroy the rock column.\n\nThe corrupted artifact you found back in the Temple of the Elements needs the attention of an Enchanter. Alas, the only one you know is Hail. She knows what needs to be done to rebalance it, but that will involve the destruction of a towering column.", locationString: "A-16, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap31")
            allScenarios.append(row30Scenario)
            
            let row31Scenario = Scenario(number: "32", title: "Decrepit Wood", completed: false, requirementsMet: false, requirements: ["The Voice's Command" : true], isUnlocked: false, unlockedBy: ["24"], unlocks: ["33", "40"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Reveal the G tile, kill all revealed enemies, and loot the treasure tile.\n\nThe Voice has directed you to retrieve his so-called 'Vessel of Power' from some place deep in the Lingering Swamp. Get ready to face a horde of Militaristic Harrowers.", locationString: "L-11, Lingering Swamp", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap32")
            allScenarios.append(row31Scenario)
            
            let row32Scenario = Scenario(number: "33", title: "Savvas Armory", completed: false, requirementsMet: false, requirements: ["OR" : true, "The Voice's Command" : true, "The Drake's Command" : true], isUnlocked: false, unlockedBy: ["25"], unlocks: ["None"], achieves: ["The Voice's Treasure", "The Drake's Treasure"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Loot all tresure tiles, then all characters must escape through the exit (a).\n\nYou have chosen to cooperate with the Elder Drake you met atop Icecrag, who would like you to retrieve his stolen treasure from the Savvas clan.", locationString: "A-7, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap33")
            allScenarios.append(row32Scenario)
            
            let row33Scenario = Scenario(number: "34", title: "Scorched Summit", completed: false, requirementsMet: false, requirements: ["The Drake's Command" : true], isUnlocked: false, unlockedBy: ["25"], unlocks: ["None"], achieves: ["The Drake Slain"], rewards: [NSAttributedString(string: "20 Gold Each"), NSAttributedString(string: "+2 Reputation"), NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Kill the Elder Drake.\n\nUnmoved by the Drake's predicament, you decide to slay him and rid the land of another menace.", locationString: "A-4, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap34")
            allScenarios.append(row33Scenario)
            
            let row34Scenario = Scenario(number: "35", title: "Gloomhaven Battlements A", completed: false, requirementsMet: false, requirements: ["A Demon's Errand" : true, "The Demon Dethroned" : false], isUnlocked: false, unlockedBy: ["22"], unlocks: ["45"], achieves: ["REMOVE", "A Demon's Errand", "City Rule: Demonic", "Artifact: Lost"], rewards: [NSAttributedString(string: "30 Gold Each"), NSAttributedString(string: "-5 Reputation"), NSAttributedString(string: "-2 Prosperity"), NSAttributedString(string: "Add City Event 79")], summary: "Goal: Destroy door 'l' and kill the Captain of the Guard.\n\nYou bring the corrupted artifact you retrieved from the Temple of the Elements to the Prime Demon. You will now help him eliminate the City Guard and help the Demon rise to power.", locationString: "B-14, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap35")
            allScenarios.append(row34Scenario)
            
            let row35Scenario = Scenario(number: "36", title: "Gloomhaven Battlements B", completed: false, requirementsMet: false, requirements: ["A Demon's Errand" : true, "The Demon Dethroned" : false], isUnlocked: false, unlockedBy: ["22"], unlocks: ["None"], achieves: ["REMOVE", "A Demon's Errand", "The Demon Dethroned"], rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "+4 Reputation"), NSAttributedString(string: "Add City Event 78")], summary: "Goal: Kill the Prime Demon.\n\nRegretting your decision to retrieve the corrupted artifact for the Prime Demon, you turn tail and make for the City Battlements. You warn the City Guard and prepare to defend agains the approaching hoard of Demons.", locationString: "B-14, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap36")
            allScenarios.append(row35Scenario)
            
            let row36Scenario = Scenario(number: "37", title: "Doom Trench", completed: false, requirementsMet: false, requirements: ["Water Breathing" : true], isUnlocked: false, unlockedBy: ["31"], unlocks: ["47"], achieves: ["Through the Trench"], rewards: [NSAttributedString(string: "None")], summary: "Goal: All characters must escape through the exit (a).\n\nHail claims that this murky trench beneath the Misty Sea is one of the places from which tendrils of dark power emanated when we destroyed the rock column back in the Plane of Night. Make sure you take your Water Breathing Orb with you!", locationString: "G-18, Misty Sea", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap37")
            allScenarios.append(row36Scenario)
            
            let row37Scenario = Scenario(number: "38", title: "Slave Pens", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["31"], unlocks: ["44", "48"], achieves: ["Redthorn's Aid"], rewards: [NSAttributedString(string: "+1 Reputation")], summary: "Goal: Kill all enemies and protect the Orchid.\n\nThe second location identified by Hail as a source of corruption for the artifact is buried deep within the Dagger Forest. To get there, you'll need the help of an Orchid famililiar with the area. Help the Orchid destroy its Inox enslavers and he'll show you how to get to the right location.", locationString: "G-2, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap38")
            allScenarios.append(row37Scenario)
            
            let row38Scenario = Scenario(number: "39", title: "Treacherous Divide", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["31"], unlocks: ["15", "46"], achieves: ["Across the Divide"], rewards: [NSAttributedString(string: "10XP Each")], summary: "Goal: Destroy the altar (a).\n\nThe third of the vessel-corrupting locations lies somewhere high in the Copperneck Mountains. Before you can get there, you are going to have to scale a summit and find a bridge that will connect you to your ultimate destination. Bring your thickest furs and sharpest swords.", locationString: "B-11, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap39")
            allScenarios.append(row38Scenario)
            
            let row39Scenario = Scenario(number: "40", title: "Ancient Defense Network", completed: false, requirementsMet: false, requirements: ["The Voice's Command" : true, "The Voice's Treasure": true], isUnlocked: false, unlockedBy: ["32"], unlocks: ["41"], achieves: ["Ancient Technology"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Occupy both pressure plates (a) simultaneously.\n\nThe Voice has guided you to this treacherous, trap-filled tomb entrance. In order to progress to the Vessel's resting place, you must first survive a gauntlet of monsters, and then figure out how to unlock the tomb.", locationString: "F-12, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap40")
            allScenarios.append(row39Scenario)
            
            let row40Scenario = Scenario(number: "41", title: "Timeworn Tomb", completed: false, requirementsMet: false, requirements: ["The Voice's Command" : true], isUnlocked: false, unlockedBy: ["40"], unlocks: ["None"], achieves: ["The Voice Freed"], rewards: [NSAttributedString(string: "50 Gold Each"), NSAttributedString(string: "25XP Each"), NSAttributedString(string: "2 ✔️ Each"), NSAttributedString(string: "+2 Prosperity")], summary: "Goal: All characters must escape through the exit (a).\n\nNow that you've shut down the Defense Network, you can proceed to the tomb and retrieve the third Vessel for the Voice.", locationString: "F-12, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap41")
            allScenarios.append(row40Scenario)
            
            let row41Scenario = Scenario(number: "42", title: "Realm of the Voice", completed: false, requirementsMet: false, requirements: ["The Scepter and the Voice" : true], isUnlocked: false, unlockedBy: ["30"], unlocks: ["None"], achieves: ["REMOVE", "The Voice's Command"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Destroy all vocal chords.\n\nWith the scepter you retrieved from the Shrine of the Depths in your hand, you once again enter the Echo Chamber hopeful that you can defeat the Voice once and for all. The Voice's last howl will likely be an ear-shattering trial.", locationString: "C-5, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap42")
            allScenarios.append(row41Scenario)
            
            let row42Scenario = Scenario(number: "43", title: "Drake Nest", completed: false, requirementsMet: false, requirements: ["The Power of Enhancement" : true], isUnlocked: false, unlockedBy: ["18"], unlocks: ["None"], achieves: ["Water Breathing"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill a number of drakes equal to four times the number of characters.\n\nYou want to be able to travel anywhere in the land, and that includes under water. Hail has a plan to help you achieve that ability, but you'll need to kill a bunch of drakes first. ", locationString: "D-4, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap43")
            allScenarios.append(row42Scenario)
            
            let row43Scenario = Scenario(number: "44", title: "Tribal Assault", completed: false, requirementsMet: false, requirements: ["Redthorn's Aid" : true], isUnlocked: false, unlockedBy: ["38"], unlocks: ["None"], achieves: ["None"], rewards: [scenario44String, NSAttributedString(string: "+2 Reputation")], summary: "Goal: Kill all enemies and protect all captive Orchids(a).\n\nAghast at Redthorn's story about the Inox raid on their village, you feel compelled to help him free his brethren from the Inox slavers a short distance from the Slave Pens.", locationString: "F-3, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap44")
            allScenarios.append(row43Scenario)
            
            let row44Scenario = Scenario(number: "45", title: "Rebel Swamp", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["35"], unlocks: ["49", "50"], achieves: ["None"], rewards: [NSAttributedString(string: "20 Gold Each"), NSAttributedString(string: "-2 Reputation")], summary: "Goal: Destroy all totems (a).\n\nThe Prime Demon has commanded you to remove all remaining pockets of resistance. Apparently, the swamps host one of the bigger pockets, unlikely as that seems. Better investigate and root out any rebels that might remain.", locationString: "M-9, Lingering Swamp", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap45")
            allScenarios.append(row44Scenario)
            
            let row45Scenario = Scenario(number: "46", title: "Nightmare Peak", completed: false, requirementsMet: false, requirements: ["Across the Divide" : true], isUnlocked: false, unlockedBy: ["39"], unlocks: ["51"], achieves: ["End of Corruption 1"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill the Winged Horror.\n\nWith the way to the peak now clear, you forge on to the summit only to encounter the likely source of vessel corruption. Unfortunately, it's a big, nasty Demon.", locationString: "A-11, Copperneck Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap46")
            allScenarios.append(row45Scenario)
            
            let row46Scenario = Scenario(number: "47", title: "Lair of the Unseeing Eye", completed: false, requirementsMet: false, requirements: ["Through the Trench" : true], isUnlocked: false, unlockedBy: ["37"], unlocks: ["51"], achieves: ["End of Corruption 2"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill the Sightless Eye.\n\nYou've made it through the Deep Trench, and have found what you believe is one of the sources of corruption Hail was speaking of. Keep an eye out for this monster, he's like nothing you've encountered before.", locationString: "H-18, Misty Sea", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap47")
            allScenarios.append(row46Scenario)
            
            let row47Scenario = Scenario(number: "48", title: "Shadow Weald", completed: false, requirementsMet: false, requirements: ["Redthorn's Aid" : true], isUnlocked: false, unlockedBy: ["38"], unlocks: ["51"], achieves: ["End of Corruption 3"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill the Dark Rider.\n\nRedthorn escorts you to this place deep within the Dagger Forest, where you hope to find another of the sources of corruption of the vessel you brought back to Hail. This Dark Rider fellow doesn't seem to friendly, alas.", locationString: "E-1, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap48")
            allScenarios.append(row47Scenario)
            
            let row48Scenario = Scenario(number: "49", title: "Rebel's Stand", completed: false, requirementsMet: false, requirements: ["City Rule: Demonic" : true], isUnlocked: false, unlockedBy: ["45"], unlocks: ["None"], achieves: ["Annihilation of Order"], rewards: [NSAttributedString(string: "50 Gold Each"), NSAttributedString(string: "-3 Reputation")], summary: "Goal: Kill the Siege Cannon.\n\nGuided by the directions given by the gullible Guard in his last breath back in the Rebel Swamp, you find what remains of the resistance. As you fight your way through the camp, you notice a towering contraption that cannot remain in rebel hands.", locationString: "N-7, Lingering Swamp", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap49")
            allScenarios.append(row48Scenario)
            
            let row49Scenario = Scenario(number: "50", title: "Ghost Fortress", completed: false, requirementsMet: false, requirements: ["City Rule: Demonic" : true, "Annihilation of Order": false], isUnlocked: false, unlockedBy: ["45"], unlocks: ["None"], achieves: ["City Rule: Militaristic"], rewards: [NSAttributedString(string: "+3 Reputation"), NSAttributedString(string: "-2 Prosperity")], summary: "Goal: Loot all treasure tiles.\n\nFollowing the dying Guard's directions, you come upon the rebel camp in the foothills of the Watcher Mountains. The rebels have a Siege Cannon ready to go, but they need to arm their men for the attack on Gloomhaven. Break into the Fortress and retrieve the weapons cache.", locationString: "C-17, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap50")
            allScenarios.append(row49Scenario)
            
            let row50Scenario = Scenario(number: "51", title: "The Void", completed: false, requirementsMet: false, requirements: ["End of Corruption 1" : true, "End of Corruption 2": true, "End of Corruption 3": true], isUnlocked: false, unlockedBy: ["46", "47", "48"], unlocks: ["None"], achieves: ["End of Gloom"], rewards: [NSAttributedString(string: "+5 Reputation"), NSAttributedString(string: "+5 Prosperity"), NSAttributedString(string: "Add City Event 81"), NSAttributedString(string: "Add Road Event 69")], summary: "Goal: Kill the Gloom.\n\nThe seriousness of Hail's tone gets your attention. Seems a fellow named Bastian - an Aesther gone bad - has occupied a place called The Void. He's going to turn the world to ash unless you can get to him first.", locationString: "A-15, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap51")
            allScenarios.append(row50Scenario)
            
            let row51Scenario = Scenario(number: "52", title: "Noxious Cellar", completed: false, requirementsMet: false, requirements: ["Seeker of Xorn personal quest" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["53"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: All characters must loot one treasure tile.\n\nYour search for the remains of Xorn takes on renewed urgency as you come across a tome that points you to old shack in the Sinking Market. Gather your team and investigate!", locationString: "D-14, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap52")
            allScenarios.append(row51Scenario)
            
            let row52Scenario = Scenario(number: "53", title: "Crypt Basement", completed: false, requirementsMet: false, requirements: ["Seeker of Xorn personal quest" : true], isUnlocked: false, unlockedBy: ["52"], unlocks: ["54"], achieves: ["Staff of Xorn item equipped"], rewards: [NSAttributedString(string: "Staff of Xorn (Item 114)")], summary: "Goal: Survive for ten rounds.\n\nThe staff you found in the Noxious Cellar has yielded further clues in your search for Xorn: A map to a secret room in the Crypt of the Damned. The search will continue there.", locationString: "F-11, Still River", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap53")
            allScenarios.append(row52Scenario)
            
            let row53Scenario = Scenario(number: "54", title: "Palace of Ice", completed: false, requirementsMet: false, requirements: ["Seeker of Xorn personal quest" : true, "Staff of Xorn item equipped" : true], isUnlocked: false, unlockedBy: ["53"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Add City and Road Events 59 instead of normal events"), scenario54String], summary: "Goal: Place the fully-charged Staff of Xorn on the altar.\n\nThe ethereal warden in the Crypt Basement prepared the staff for you, and told you to bring it to the Palace of Ice. Your job is to charge it and lay it upon the altar.", locationString: "D-8, Copperneck mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap54")
            allScenarios.append(row53Scenario)
            
            let row54Scenario = Scenario(number: "55", title: "Foggy Thicket", completed: false, requirementsMet: false, requirements: ["Take Back the Trees personal quest" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["56"], achieves: ["None"], rewards: [NSAttributedString(string: "10 Collective Gold")], summary: "Goal: Loot the treasure tile in the third room.\n\nThe ethereal warden in the Crypt Basement prepared the staff for you, and told you to bring it to the Palace of Ice. Your job is to charge it and lay it upon the altar.", locationString: "G-5, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap55")
            allScenarios.append(row54Scenario)
            
            let row55Scenario = Scenario(number: "56", title: "Bandit's Wood", completed: false, requirementsMet: false, requirements: ["Take Back the Trees personal quest" : true], isUnlocked: false, unlockedBy: ["55"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Take Back the Trees personal quest: COMPLETE"), scenario44String, NSAttributedString(string: "10 Gold each"), NSAttributedString(string: "+2 Reputation")], summary: "Goal: Kill the Infiltrator.\n\nThe map you retrieved from the Foggy Thicket has led you to the Bandit camp. You need to finish these guys off, but take care to protect the captive Orchids.", locationString: "G-4, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap56")
            allScenarios.append(row55Scenario)
            
            let row56Scenario = Scenario(number: "57", title: "Investigation", completed: false, requirementsMet: false, requirements: ["Vengeance personal quest" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["58"], achieves: ["None"], rewards: [NSAttributedString(string: "+1 Reputation")], summary: "Goal: Kill all enemies and protect at least one captive Orchid.\n\nYour information has led you to the West Barracks. The corrupt Lieutenant who was on duty the night your friend was murdered is stationed here, and you aim to get answers.", locationString: "G-4, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap57")
            allScenarios.append(row56Scenario)
            
            let row57Scenario = Scenario(number: "58", title: "Bloody Shack", completed: false, requirementsMet: false, requirements: ["Vengeance personal quest" : true], isUnlocked: false, unlockedBy: ["57"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Vengeance personal quest: COMPLETE"), NSAttributedString(string: "Open envelope X"), NSAttributedString(string: "+2 Reputation")], summary: "Goal: Kill the Harvester.\n\nLed to this run down shack by clues left on the Infiltrator's body, you gird yourself for what is likely to be a nasty battle. Your need for revenge has gotten you this far, but can it propel you through what lies within?", locationString: "E-15, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap58")
            allScenarios.append(row57Scenario)
            
            let row58Scenario = Scenario(number: "59", title: "Forgotten Grove", completed: false, requirementsMet: false, requirements: ["Finding the Cure personal quest" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["60"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies and loot the treasure tile.\n\nThe elder spoke of a plant that could provide a cure for the plague that's decimated your village. A helpful Quatryl has fashioned a compass which has led you to the supposed whereabouts of this magical plant. Nothing hard about harvesting a plant, right?", locationString: "F-1, Dagger Forest", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap59")
            allScenarios.append(row58Scenario)
            
            let row59Scenario = Scenario(number: "60", title: "Alchemy Lab", completed: false, requirementsMet: false, requirements: ["Finding the Cure personal quest" : true], isUnlocked: false, unlockedBy: ["59"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Finding the Cure personal quest: COMPLETE"), NSAttributedString(string: "Open envelope X"), NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Loot all treasure tiles, then all characters must escape through the entrance.\n\nThe Quatryl double-crossed you back in the Forgotten Grove, and you don't take kindly to such behavior. You arrive at the University, only to find the Alchemy Lab on fire. The cure lies within the inferno somewhere, according to the sheepish Quatryl. Even a raging fire won't keep you from obtaining the cure.", locationString: "B-15, Gloomhaven", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap60")
            allScenarios.append(row59Scenario)
            
            let row60Scenario = Scenario(number: "61", title: "Fading Lighthouse", completed: false, requirementsMet: false, requirements: ["The Fall of Man personal quest" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["62"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Loot all treasure tiles.\n\nYou can't explain exactly why you think the evidence you're looking for is all the way down in the swamp, but you are even more sure when you spy a lighthouse along the shore in the distance. Now here, now gone, you realize the lighthouse is constantly shifting between planes of existence. No matter, you need to get in there and glean whatever you can about those who came before.", locationString: "N-11, Lingering Swamp", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap61")
            allScenarios.append(row60Scenario)
            
            let row61Scenario = Scenario(number: "62", title: "Pit of Souls", completed: false, requirementsMet: false, requirements: ["The Fall of Man personal quest" : true], isUnlocked: false, unlockedBy: ["61"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "The Fall of Man personal quest: COMPLETE"), scenario62String, NSAttributedString(string: "10XP Each")], summary: "Goal: Kill the Hungry Soul.\n\nYou're drawn ever deeper into the bowels of the lighthouse, and restless souls form dusty bones into sword-wielding skeletons. Forge onward and confront whatever malcontented beings remain trapped here.", locationString: "N-11, Lingering Swamp", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap62")
            allScenarios.append(row61Scenario)
            
            let row62Scenario = Scenario(number: "63", title: "Magma Pit", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "15 Gold Each")], summary: "Goal: Kill all enemies.\n\nIf the reports are true, there's gold to be found on this active volcano high in the Watcher Mountains. As always, come prepared for battle, as nothing in Gloomhaven comes easily.", locationString: "M-1, Watcher Mountains", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap63")
            allScenarios.append(row62Scenario)
            
            let row63Scenario = Scenario(number: "64", title: "Underwater Lagoon", completed: false, requirementsMet: false, requirements: ["Water Breathing" : true], isUnlocked: true, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "10XP Each")], summary: "Goal: Kill all enemies.\n\nYou came by the map easily enough, so there must be a catch. Nevertheless, you're raring to take advantage of your water breathing capability and explore this mysterious lagoon way out in the Misty Sea. The hired boat's captain will only come so close to the shore of this place, so bring a dinghy with you.", locationString: "R-16, Misty Sea", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap64")
            allScenarios.append(row63Scenario)
            
            let row64Scenario = Scenario(number: "65", title: "Sulfur Mine", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["Ancient Technology"], rewards: [NSAttributedString(string: "Ancient Drill design (Item 112)")], summary: "Goal: Kill all enemies and loot all treasure tiles.\n\nEveryone knows where this place is due to the overwhelming stench that emanates for miles in all directions. Not so well-known is the fact that ancient technology of some sort lies deep within the mine. You know a few folks who would love to get their hands on such tech.", locationString: "L-5, Watcher Mountains", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap65")
            allScenarios.append(row64Scenario)
            
            let row65Scenario = Scenario(number: "66", title: "Clockwork Cove", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["Ancient Technology"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Occupy pressure plate (e).\n\nEver on the lookout for lost technology, this cove up along the coast near town seems promising. Rumor has it that the place is chocked full of gears and levers (and traps, of course).", locationString: "G-14, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap66")
            allScenarios.append(row65Scenario)
            
            let row66Scenario = Scenario(number: "67", title: "Arcane Library", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["Ancient Technology"], rewards: [NSAttributedString(string: "Power Core (Item 132)")], summary: "Goal: Kill the Arcane Golem.\n\nYou have discovered the location of the old mystic Morsbane's Tower. The place is long past its prime but still home to ancient treasure, if rumors are to be believed.", locationString: "K-2, Watcher Mountains", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap67")
            allScenarios.append(row66Scenario)
            
            let row67Scenario = Scenario(number: "68", title: "Toxic Moor", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Two(2) Major Healing potions (Item 027)")], summary: "Goal: Kill all enemies and protect the Tree (a).\n\nYou've heard tell of a great tree that grows somewhere deep within the Lingering Swamp. It supposedly possesses great healing power, but is rumored to be the target of vile creatures bent on its destruction. Whether it be a soft spot for nature, or the hope of finding valuable potions, you need to get down there and defend the tree.", locationString: "N-8, Lingering Swamp", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap68")
            allScenarios.append(row67Scenario)
            
            let row68Scenario = Scenario(number: "69", title: "Well of the Unfortunate", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "15 Gold Each")], summary: "Goal: Bring the doll to the well.\n\nThere's an old well up along the Stone Road that's supposed to grant wishes to those who throw items of value into its depths. Though you're not particularly superstitious, your curiosity drives you to go see for yourself.", locationString: "F-8, Stone Road", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap69")
            allScenarios.append(row68Scenario)
            
            let row69Scenario = Scenario(number: "70", title: "Chained Isle", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "+2 Prosperity")], summary: "Goal: Kill all demons.\n\nYou've heard enough about the haunted island to fill several story books. No one dares go near the remote hunk of rock deep in the Misty Sea for fear of the tormented souls haunting the shore. A recently-discovered journal details the existence of a cohort of demons somewhere on the island, which could be the source of the discomfited souls. Wipe out the demons, and maybe the Chained Isle will become a destination once again.", locationString: "J-17, Misty Sea", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap70")
            allScenarios.append(row69Scenario)
            
            let row70Scenario = Scenario(number: "71", title: "Windswept Highlands", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Two(2) Major Power potions")], summary: "Goal: Loot all treasure tiles, then all characters must escape through exit (a).\n\nYou've uncovered an alchemist's log book, wherein you read about a plant (jerry root) which can be used to formulate a powerful concoction. If you can retrieve this plant from the highlands along the Serpent's Kiss River, you might be able to fetch some decent coin for it.", locationString: "K-5, Serpent's Kiss River", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap71")
            allScenarios.append(row70Scenario)
            
            let row71Scenario = Scenario(number: "72", title: "Oozing Grove", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "+1 Reputation"), NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Destroy all trees and kill all Oozes.\n\nTown librarian Dominic fears the military will quash his attempts to chronicle Gloomhaven history. If you scratch Councilman Greymare's back, the councilman will do what he can to protect Dominic. Clear Greymare's Corpsewood estate of an Ooze infestation.", locationString: "H-12, Corpsewood", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap72")
            allScenarios.append(row71Scenario)
            
            let row72Scenario = Scenario(number: "73", title: "Rockslide Ridge", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "+1 Reputation")], summary: "Goal: Kill all enemies and loot all treasure tiles.\n\nDominic the librarian implores you to recover a Codex that contains vital information about Gloomhaven's ancient history. Problem is, it's purportedly in the hands of a band of Inox.", locationString: "N-5, Watcher Mountains", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap73")
            allScenarios.append(row72Scenario)
            
            let row73Scenario = Scenario(number: "74", title: "Merchant Ship", completed: false, requirementsMet: false, requirements: ["High Sea Escort" : true], isUnlocked: false, unlockedBy: ["City Event 76A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "+2 Prosperity")], summary: "Goal: Kill all enemies and keep the ship afloat.\n\nMerchant Gavin has hired you to put an end to the sea piracy that's destroying his business. Board one of his ships and let the pirates come to you, then finish them off for good.", locationString: "I-14, Misty Sea", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap74")
            allScenarios.append(row73Scenario)
            
            let row74Scenario = Scenario(number: "75", title: "Overgrown Graveyard", completed: false, requirementsMet: false, requirements: ["Grave Job" : true], isUnlocked: false, unlockedBy: ["City Event 77A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "60 Gold Each")], summary: "Goal: Dig up all graves and kill the Bloated Regent.\n\nNotorious fence Red Nick thinks you will make great grave robbers. Apparently there's much loot to be pilfered from a cemetary out on the east side of the Corpsewood, assuming the job isn't beneath you.", locationString: "G-12, Corpsewood", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap75")
            allScenarios.append(row74Scenario)
            
            let row75Scenario = Scenario(number: "76", title: "Harrower Hive", completed: false, requirementsMet: false, requirements: ["Bravery" : true], isUnlocked: false, unlockedBy: ["Secret Envelope"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Reveal all rooms and kill all enemies.\n\nThere's a group of Harrowers slaughtering people out along the East Road, and they need to be stopped. Problem is, no-one has stepped up to take on this extremely dangerous task. If you're up to it, head out to their hive in the Watcher Mountains and wipe them out.", locationString: "L-3, Watcher Mountains", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap76")
            allScenarios.append(row75Scenario)
            
            let row76Scenario = Scenario(number: "77", title: "Vault of Secrets", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["None"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "5 XP Each")], summary: "Goal: Loot all treasure tiles and kill all City Guards before the alarm is raised.\n\nLibrarian Dominic's beloved Codex was stolen from him by a mysterious group calling themselves The Vigil. He has directed you to sneak in to their Vault of Secrets and recover the Codex without raising an alarm.", locationString: "B-17, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap77")
            allScenarios.append(row76Scenario)
            
            let row77Scenario = Scenario(number: "78", title: "Sacrifice Pit", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["City Event 34A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "+3 Reputation")], summary: "Goal: Kill all enemies and stop the sacrifice.\n\nYou've followed a cloaked figure to what you believe could be the Ravens' hideout. This may be your chance cleanse the city of these vile cultists for good.", locationString: "B-14, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap78")
            allScenarios.append(row77Scenario)
            
            let row78Scenario = Scenario(number: "79", title: "Lost Temple", completed: false, requirementsMet: false, requirements: ["Fish's Aid" : true], isUnlocked: false, unlockedBy: ["City Event 72A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "15 Gold Each")], summary: "Goal: Kill the Betrayer.\n\nAn old bandit, Fish, tells you that the metal sphere and rod you are puzzling over is in fact a key to a temple that contains untold riches. You decide to take Fish at his word and follow him out to the swamps to scare up some gold.", locationString: "K-12, Lingering Swamp", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap79")
            allScenarios.append(row78Scenario)
            
            let row79Scenario = Scenario(number: "80", title: "Vigil Keep", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["Road Event 49A/49B"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "10 XP Each")], summary: "Goal: All characters must loot one treasure tile and then escape.\n\nYour investigations into the Vigil have landed you in a jail cell deep within their keep. A friend offers a bit of help, but you must still regain your weapons and items if you're going to escape this place.", locationString: "K-1, Watcher Mountains", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap80")
            allScenarios.append(row79Scenario)
            
            let row80Scenario = Scenario(number: "81", title: "Temple of the Eclipse", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["City Event 17B"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "10 XP Each")], summary: "Goal: Kill the Colorless.\n\nJust when you thought that coin you bought off the strange Savvas merchant was a worthless bauble, an Aesther tells you its markings lead to a mysterious temple. This proves to be too enticing to ignore, so you head out to the Dagger Forest ready to explore.", locationString: "D-2, Dagger Forest", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap81")
            allScenarios.append(row80Scenario)
            
            let row81Scenario = Scenario(number: "82", title: "Burning Mountain", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["Road Event 24A/24B"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "+1 Reputation OR"), NSAttributedString(string: "-1 Reputation, -2 Prosperity")], summary: "Goal: Sacrifice one artifact or escape with all artifacts.\n\nThat band of Inox you passed on the road were fleeing what their Shaman called 'A Mountain Aflame'. After coming upon the scorched Inox village, you decide to brave the climb to the peak beyond and see just what's really going on.", locationString: "M-6, Watcher Mountains", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap82")
            allScenarios.append(row81Scenario)
            
            let row82Scenario = Scenario(number: "83", title: "Shadows Within", completed: false, requirementsMet: false, requirements: ["Bad Business" : true], isUnlocked: false, unlockedBy: ["City Event 31A/31B"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "40 Collective Gold")], summary: "Goal: Kill all enemies.\n\nThe woman who approached you during a drunken night gambling at the Brown Door caught your attention with a parchment bearing the Raven insignia. She's appealing to you to rescue her kidnapped daughter from the vile cultists. You've got a lead on their whereabouts, so it's time to go knock some heads.", locationString: "C-15, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap83")
            allScenarios.append(row82Scenario)
            
            let row83Scenario = Scenario(number: "84", title: "Crystalline Cave", completed: false, requirementsMet: false, requirements: ["Tremors" : true], isUnlocked: false, unlockedBy: ["City Event 73A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Resonant Crystal (Item 133)"), NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Kill all enemies and protect the crystal (a).\n\nThat crystal you found turns out to contain earth-shaking power - quite literally. After consulting with a Quatryl over what to do about it, you're off to restore the crystal to its proper place and forever quiet the rumblings.", locationString: "D-12, Copperneck Mountains", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap84")
            allScenarios.append(row83Scenario)
            
            let row84Scenario = Scenario(number: "85", title: "Sun Temple", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["Road Event 61B", "Road Event 62A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Orb of Dawn (Item 121)")], summary: "Goal: Kill all enemies.\n\nSun Demons have sought your help in ridding their temple of Night Demons. You begrudgingly agree to assist them.", locationString: "M-3, Watcher Mountains", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap85")
            allScenarios.append(row84Scenario)
            
            let row85Scenario = Scenario(number: "86", title: "Harried Village", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["City Event 63A"], unlocks: ["87"], achieves: ["The Poison's Source"], rewards: [NSAttributedString(string: "+2 Reputation")], summary: "Goal: Save seven villagers before five are killed.\n\nFind out what's poisoning the residents of Hook Coast and report back to the City Guard.", locationString: "D-15, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap86")
            allScenarios.append(row85Scenario)

            let row86Scenario = Scenario(number: "87", title: "Corrupted Cove", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["86", "City Event 47A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "+1 Reputation"), NSAttributedString(string: "+1 Prosperity")], summary: "Goal: Kill the Giant Ooze.\n\nA resident of the Hook Coast points out the source of the poison ravaging his village. You go to a cove just to the south to investigate further.", locationString: "I-9, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap87")
            allScenarios.append(row86Scenario)
            
            let row87Scenario = Scenario(number: "88", title: "Plane of Water", completed: false, requirementsMet: false, requirements: ["Water Breathing" : true, "Water Staff" : true], isUnlocked: false, unlockedBy: ["City Event 68A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Staff of Summoning (Item 120)")], summary: "Goal: Bring the Lurker King's claw to the crystal (a).\n\nThat Summoner's Staff you found is gushing water all over your room at the Sleeping Lion, so you gamely try to figure out how to stop it. Suddenly a planar threshold appears before you, and you step through.", locationString: "D-16, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap88")
            allScenarios.append(row87Scenario)
            
            let row88Scenario = Scenario(number: "89", title: "Syndicate Hideout", completed: false, requirementsMet: false, requirements: ["Sin-Ra" : true], isUnlocked: false, unlockedBy: ["City Event 64A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "50 Collective Gold")], summary: "Goal: Kill all enemies.\n\nThe Sin-Ra Syndicate has a beef with your 'friend' the Nightshroud, so they have decided to strike at you. Find their hideout and make them regret it.", locationString: "C-17, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap89")
            allScenarios.append(row88Scenario)
            
            let row89Scenario = Scenario(number: "90", title: "Demonic Rift", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["Road Event 44A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Black Censer (Item 128")], summary: "Goal: Close the rift.\n\nYour friend the Spellweaver showed up out of nowhere one night to help you fend off some Night Demons. She's asked for your help in destroying with the rift from whence they came.", locationString: "J-7, Serpent's Kiss River", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap90")
            allScenarios.append(row89Scenario)
            
            let row90Scenario = Scenario(number: "91", title: "Wild Melee", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["City Event 58B"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "2 ✔️ Each")], summary: "Goal: Kill all enemies.\n\nYou take the drunken logger's bar-table rant about a Vermling riding a bear seriously, and head out to the Dagger Forest to see what he was on about.", locationString: "E-2, Dagger Forest", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap91")
            allScenarios.append(row90Scenario)
            
            let row91Scenario = Scenario(number: "92", title: "Back Alley Brawl", completed: false, requirementsMet: false, requirements: ["Debt Collection" : true], isUnlocked: false, unlockedBy: ["City Event 67B"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "10 Gold Each"), NSAttributedString(string: "-3 Reputation")], summary: "Goal: Kill all non-city enemies.\n\nSome Inox thought they could extort you for a debt owed by someone else. You would rather meet them in the alley outside the Sleeping Lion and show them your preferred form of payback.", locationString: "C-14, Gloomhaven", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap92")
            allScenarios.append(row91Scenario)
            
            let row92Scenario = Scenario(number: "93", title: "Sunken Vessel", completed: false, requirementsMet: false, requirements: ["A Map to Treasure" : true], isUnlocked: false, unlockedBy: ["City Event 08A"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "10 XP Each")], summary: "Goal: Kill all enemies.\n\nYou decided to purchase a faded map from a Valrath merchant. It supposedly points to sunken treasure, so you rent a boat and sail to where X marks the spot.", locationString: "N-17, Misty Sea", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap93")
            allScenarios.append(row92Scenario)
            
            let row93Scenario = Scenario(number: "94", title: "Vermling Nest", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["City Event 78A"], unlocks: ["95"], achieves: ["Through the Nest"], rewards: [NSAttributedString(string: "None")], summary: "Goal: Kill all enemies and loot the treasure tile.\n\nThe old man who approached your table at the Sleeping Lion asked you to retrieve an artifact for him. He promised that there would be plenty of riches to be found once the Vermlings protecting it were dealt with.", locationString: "F-12, Corpsewood", isManuallyUnlockable: true, mainCellBGImage: "scenarioMgrMap94")
            allScenarios.append(row93Scenario)
            
            let row94Scenario = Scenario(number: "95", title: "Payment Due", completed: false, requirementsMet: false, requirements: ["None" : true], isUnlocked: false, unlockedBy: ["94"], unlocks: ["None"], achieves: ["None"], rewards: [NSAttributedString(string: "Skull of Hatred (Item 119)")], summary: "Goal: Kill the Prime Lieutenant.\n\nAfter dealing with the Vermling nest, you were expecting to find a glittering trove. Instead, you've been thrust into a battle arena for the entertainment of the Prime Lieutenant.", locationString: "G-12, Corpsewood", isManuallyUnlockable: false, mainCellBGImage: "scenarioMgrMap95")
            allScenarios.append(row94Scenario)
            
            achievements = [
                "None"                                  : true,
                "First Steps"                           : false,
                "Jekserah's Plans"                      : false,
                "Dark Bounty"                           : false,
                "The Merchant Flees"                    : false,
                "The Dead Invade"                       : false,
                "A Demon's Errand"                      : false,
                "End of the Invasion"                   : false,
                "The Power of Enhancement"              : false,
                "Stonebreaker's Censer"                 : false,
                "The Demon Dethroned"                   : false,
                "Through the Ruins"                     : false,
                "The Voice's Command"                   : false,
                "The Drake's Command"                   : false,
                "Following Clues"                       : false,
                "The Rift Closed"                       : false,
                "An Invitation"                         : false,
                "The Edge of Darkness"                  : false,
                "The Scepter and the Voice"             : false,
                "Artifact: Cleansed"                    : false,
                "Artifact: Lost"                        : false,
                "Artifact: Recovered"                   : false,
                "The Voice's Treasure"                  : false,
                "The Drake's Treasure"                  : false,
                "The Drake Slain"                       : false,
                "City Rule: Demonic"                    : false,
                "Through the Trench"                    : false,
                "Redthorn's Aid"                        : false,
                "Across the Divide"                     : false,
                "The Voice Freed"                       : false,
                "Water Breathing"                       : false,
                "End of Corruption 1"                   : false,
                "End of Corruption 2"                   : false,
                "End of Corruption 3"                   : false,
                "Annihilation of Order"                 : false,
                "City Rule: Militaristic"               : false,
                "End of Gloom"                          : false,
                "The Poison's Source"                   : false,
                "Through the Nest"                      : false,
                "High Sea Escort"                       : false,
                "Grave Job"                             : false,
                "Bravery"                               : false,
                "Fish's Aid"                            : false,
                "Bad Business"                          : false,
                "Tremors"                               : false,
                "Sin-Ra"                                : false,
                "Debt Collection"                       : false,
                "A Map to Treasure"                     : false,
                "Chosen by picker"                      : false,
                "Ancient Technology"                    : false,
                "OR"                                    : true,
                "Seeker of Xorn personal quest"         : false,
                "Staff of Xorn item equipped"           : false,
                "Take Back the Trees personal quest"    : false,
                "Vengeance personal quest"              : false,
                "Finding the Cure personal quest"       : false,
                "The Fall of Man personal quest"        : false
                ]
                        //saveScenarios()
        }
        
        print("Documents folder is \(documentsDirectory())")
        print("Data file path is \(dataFilePath())")
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Scenarios.plist")
    }
    func saveScenarios() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        // this line is different from before
        archiver.encode(allScenarios, forKey: "Scenarios")
        archiver.encode(achievements, forKey: "Achievements")
        archiver.finishEncoding()
        data.write(to: dataFilePath(), atomically: true)
    }
    func loadScenarios() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            allScenarios = unarchiver.decodeObject(forKey: "Scenarios") as! [Scenario]
            achievements = unarchiver.decodeObject(forKey: "Achievements") as! [ String : Bool ]
            unarchiver.finishDecoding()
        }
    }
    func getScenario(scenarioNumber: String) -> Scenario? {
        
        if scenarioNumber == "None" || scenarioNumber == "ONEOF" || scenarioNumber.contains("Event") || scenarioNumber.contains("Envelope") {
            return nil
        } else {
            let scenInt = Int(scenarioNumber)!-1
            let scenario = allScenarios[scenInt]
            
            return scenario
        }
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
