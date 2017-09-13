//
//  CreateCampaignViewModelFromModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

protocol CaseCountable {
    static func countCases() -> Int
    static var caseCount: Int { get }
}
// provide a default implementation to count the cases for Int enums assuming starting at 0 and contiguous
extension CaseCountable where Self : RawRepresentable, Self.RawValue == Int {
    // count the number of cases in the enum
    static func countCases() -> Int {
        // starting at zero, verify whether the enum can be instantiated from the Int and increment until it cannot
        var count = 0
        while let _ = Self(rawValue: count) { count += 1 }
        return count
    }
}
// Move these to separate files?
struct CreateCampaignTitleCellViewModel {
    
//    let campaignTitleTextField: String?
    let campaignTitleTextFieldPlaceholder: String
    
    init() {
        self.campaignTitleTextFieldPlaceholder = "Enter Campaign Title"
    }
}

enum SectionTypes: Int, CaseCountable {
    
    case Title
    case Characters
    
    static let caseCount = SectionTypes.countCases()
}

class CreateCampaignViewModelFromModel: NSObject, CreateCampaignViewControllerViewModel, CreateCampaignCharacterCellDelegate {
    
    let dataModel: DataModel
    var campaign = [String:Campaign]()
    var characters: [String:Character]
    let numberOfSections = SectionTypes.caseCount
    let sections = [SectionTypes.Title, SectionTypes.Characters]
    var remainingCharacters: [String:Character]
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.characters = dataModel.characters
        self.remainingCharacters = characters
    }

    func returnTextFieldPlaceholderText() -> String {
        return "Select Character"
    }
    func updateAvailableCharacters(characterToRemove: String) {
        if self.remainingCharacters.count == 1 {
            print("Not removing last")
        } else {
            print("Calling remove again!")
            self.remainingCharacters.removeValue(forKey: characterToRemove)
        }
    }
    func createCampaign(title: String, characters: [Character]) {
        print("Got title: \(title)")
        print("Got character: \(characters.map { $0.name })")
        dataModel.createCampaign(title: title, isCurrent: true, characters: characters)
    }
}
