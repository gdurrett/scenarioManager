//
//  CreateCharacterCharacterNameCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/9/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CreateCharacterCharacterNameCell: UITableViewCell {

    @IBOutlet weak var createCharacterNameTextField: UITextField!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    func configure(withViewModel viewModel: CreateCharacterCharacterNameCellViewModel) {
        createCharacterNameTextField.sizeToFit()
        createCharacterNameTextField?.font = fontDefinitions.detailTableViewTitleFont
        createCharacterNameTextField?.textColor = colorDefinitions.scenarioTitleFontColor
        createCharacterNameTextField.placeholder = viewModel.createCharacterNameTextFieldPlaceholder
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
