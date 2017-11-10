//
//  CreateCharacterViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/9/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

struct CreateCharacterCharacterNameCellViewModel {
    let createCharacterNameTextFieldPlaceholder: String
    
    init() {
        self.createCharacterNameTextFieldPlaceholder = "Enter Character Name"
    }
}
protocol CreateCharacterViewModelDelegate: class {
    func setCurrentCharacter(character: Character)
}

class CreateCharacterViewModel: NSObject {
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    let dataModel: DataModel
    var nameCell: CreateCharacterCharacterNameCell?
    var newCharacterName: String?
    var newCharacter: Character?
    
    weak var delegate: CreateCharacterViewModelDelegate?
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
    }
    
    fileprivate func createCharacter(name: String) {
        dataModel.createCharacter(name: name)
        if dataModel.characters[name] != nil {
            newCharacter = dataModel.characters[name]
        }
        dataModel.saveCampaignsLocally()
    }
}
extension CreateCharacterViewModel: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = CreateCharacterCharacterNameCellViewModel()
        let cell = tableView.dequeueReusableCell(withIdentifier: CreateCharacterCharacterNameCell.identifier, for: indexPath) as! CreateCharacterCharacterNameCell
        cell.configure(withViewModel: viewModel)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.backgroundColor = UIColor.clear
        nameCell = cell
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Name new character"
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
    }
}
extension CreateCharacterViewModel: CreateCharacterViewControllerDelegate {
    func createCharacterViewControllerDidCancel(_ controller: CreateCharacterViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createCharacterViewControllerDidFinishAdding(_ controller: CreateCharacterViewController) {
        newCharacterName = nameCell?.createCharacterNameTextField.text
        if newCharacterName != "" {
            self.createCharacter(name: newCharacterName!)
            delegate?.setCurrentCharacter(character: newCharacter!)
            controller.dismiss(animated: true, completion: nil)
        } else {
            // Present alert
        }
    }
}
