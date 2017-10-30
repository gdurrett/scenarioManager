//
//  CharacterViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/27/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class CharacterViewModel: NSObject {
    var dataModel: DataModel
    var characters: Dynamic<[String:Character]>
    
    // MARK: Init
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.characters = Dynamic(dataModel.characters)
    }
    
    func updateAvailableCharacters() {
        self.characters.value = dataModel.characters
    }
}
