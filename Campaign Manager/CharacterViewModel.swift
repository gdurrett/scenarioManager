//
//  CharacterViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/13/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

class CharacterViewModel: NSObject {
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    let dataModel: DataModel
    
    var activeCharacters: Dynamic<[Character]>
    var inactiveCharacters: Dynamic<[Character]>
    var retiredCharacters: Dynamic<[Character]>
    var character: Character!
    
    var selectedIndex = Int()
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.activeCharacters = Dynamic(dataModel.assignedCharacters.filter { $0.isActive == true })
        self.inactiveCharacters = Dynamic(dataModel.assignedCharacters.filter { $0.isActive == false })
        self.retiredCharacters = Dynamic(dataModel.assignedCharacters.filter { $0.isRetired == true })
        super.init()
    }
}
extension CharacterViewModel: UITableViewDataSource, UITableViewDelegate, CharacterViewControllerSegmentedControlDelegate {
    var characterFilterOutletSelectedIndex: Int {
        get {
            return selectedIndex
        }
        set {
             selectedIndex = newValue
            print(newValue)
        }
    }
    // Helper methods
    func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Character"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue: Int
        switch(selectedIndex) {
        case 0:
            returnValue = self.inactiveCharacters.value.count
            print(self.inactiveCharacters.value.count)
        case 1:
            returnValue = self.activeCharacters.value.count
            print("Active \(self.activeCharacters.value.count)")
        case 2:
            returnValue = self.retiredCharacters.value.count
        default:
            returnValue = 1
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = makeCell(for: tableView)
        switch(characterFilterOutletSelectedIndex) {
        case 0:
            character = self.inactiveCharacters.value[indexPath.row]
        case 1:
            character = self.activeCharacters.value[indexPath.row]
        case 2:
            character = self.retiredCharacters.value[indexPath.row]
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCharacterTitleCell.identifier, for: indexPath) as! SelectCharacterTitleCell
        print("Getting in here?")
        //cell.backgroundView = UIImageView(image: UIImage(named: scenario.mainCellBGImage))
        cell.backgroundView?.alpha = 0.25
        //cell.selectedBackgroundView = UIImageView(image: UIImage(named: scenario.mainCellBGImage))
        cell.selectedBackgroundView?.alpha = 0.65
        cell.selectCharacterTitleCellTitleLabel.text = character.name
        return cell
    }
}
