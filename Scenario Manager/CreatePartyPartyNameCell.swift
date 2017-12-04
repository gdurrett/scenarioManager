//
//  CreatePartyPartyNameCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/31/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CreatePartyPartyNameCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var createPartyNameTextField: UITextField!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    func configure(withViewModel viewModel: CreatePartyPartyNameCellViewModel) {
        createPartyNameTextField.sizeToFit()
        createPartyNameTextField?.font = fontDefinitions.detailTableViewTitleFont
        createPartyNameTextField?.textColor = colorDefinitions.scenarioTitleFontColor
        createPartyNameTextField.placeholder = viewModel.createPartyNameTextFieldPlaceholder
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
        //self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:))))
        self.createPartyNameTextField.delegate = self
        // For keyboard
        createPartyNameTextField.addTarget(nil, action:Selector(("firstResponderAction:")), for:.editingDidEndOnExit)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
