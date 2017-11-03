//
//  CreateCampaignPartyCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/3/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CreateCampaignPartyCell: UITableViewCell {

    @IBOutlet weak var createCampaignPartyNameTextField: UITextField!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    func configure(withViewModel viewModel: CreateCampaignPartyNameCellViewModel) {
        createCampaignPartyNameTextField.sizeToFit()
        createCampaignPartyNameTextField?.font = fontDefinitions.detailTableViewTitleFont
        createCampaignPartyNameTextField?.textColor = colorDefinitions.scenarioTitleFontColor
        createCampaignPartyNameTextField.placeholder = viewModel.createCampaignPartyNameTextFieldPlaceholder
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //createCampaignPartyNameTextField.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
