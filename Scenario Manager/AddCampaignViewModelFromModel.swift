//
//  AddCampaignViewModelFromModel.swift
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
struct AddCampaignTitleCellViewModel {
    
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

class AddCampaignViewModelFromModel: NSObject, CampaignViewControllerViewModel {
    
    let dataModel: DataModel
    var campaigns: [String:Campaign]
    var characters: [Character]
    let numberOfSections = SectionTypes.caseCount
    let sections = [SectionTypes.Title, SectionTypes.Characters]
    
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.campaigns = dataModel.campaigns
        self.characters = dataModel.characters
    }
    func returnTextFieldPlaceholderText() -> String {
        return "Select Character"
    }
    func returnCharacters() -> [Character] {
        return self.characters
    }
    func addCampaign(title: String) {
        print("Got title: \(title)")
        //dataModel.addCampaign(campaign: campaign, isCurrent: true)
    }
}
