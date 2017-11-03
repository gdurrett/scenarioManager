//
//  CreatePartyViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/31/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import UIKit

struct CreatePartyPartyNameCellViewModel {
    let createPartyNameTextFieldPlaceholder: String
    
    init() {
        self.createPartyNameTextFieldPlaceholder = "Enter Party Name"
    }
}

class CreatePartyViewModel: NSObject {
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    let dataModel: DataModel
    let currentCampaign: Campaign? // Need to assign when we load this from PartyDetailVM
    var newParty = Party(name: "", characters: [], location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: "")
    var nameCell: CreatePartyPartyNameCell?
    var newPartyName: String?

    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.currentCampaign = dataModel.currentCampaign
    }
    
    fileprivate func createParty(name: String) {
        dataModel.createParty(name: name, characters: [], location: "Gloomhaven", achievements: [:], reputation: 0, isCurrent: true, assignedTo: (currentCampaign!.title))
        dataModel.currentParty = dataModel.parties[name]
        dataModel.currentCampaign.parties!.append(dataModel.parties[name]!)
        dataModel.saveCampaignsLocally()
    }

}
extension CreatePartyViewModel: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = CreatePartyPartyNameCellViewModel()
        let cell = tableView.dequeueReusableCell(withIdentifier: CreatePartyPartyNameCell.identifier) as! CreatePartyPartyNameCell
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
        return "Name new party"
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
    }
}
extension CreatePartyViewModel: CreatePartyViewControllerDelegate {
    func createPartyViewControllerDidCancel(_ controller: CreatePartyViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func createPartyViewControllerDidFinishAdding(_ controller: CreatePartyViewController) {
        newPartyName = nameCell?.createPartyNameTextField.text
        if newPartyName != "" {
            self.createParty(name: newPartyName!)
            controller.dismiss(animated: true, completion: nil)
        } else {
            // Present alert
        }
    }
}
