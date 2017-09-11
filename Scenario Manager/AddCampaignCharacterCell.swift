//
//  AddCampaignCharacterCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/9/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class AddCampaignCharacterCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {


    @IBOutlet weak var addCampaignCharacterTextField: UITextField!
    
    var pickerData = [String]()
    weak var delegate: UIPickerViewDelegate?
    var addCampaignCharacterPicker = UIPickerView()
    
    func configure(withViewModel viewModel: AddCampaignViewModelFromModel) {
        addCampaignCharacterTextField.placeholder = viewModel.returnTextFieldPlaceholderText()
        for character in viewModel.characters {
            pickerData.append(character.name)
        }
    }
    // Delegate methods for picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (pickerData.count)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        addCampaignCharacterTextField.text = pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
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
        let addCampaignCharacterPicker = UIPickerView(frame: CGRect(x: 10, y: 140, width: self.frame.width - 20, height: 200))
        addCampaignCharacterPicker.layer.cornerRadius = 10
        addCampaignCharacterPicker.layer.masksToBounds = true
        addCampaignCharacterPicker.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        addCampaignCharacterPicker.showsSelectionIndicator = true
        addCampaignCharacterPicker.delegate = self
        addCampaignCharacterPicker.dataSource = self
        addCampaignCharacterTextField.inputView = addCampaignCharacterPicker
        //self.addSubview(addCampaignCharacterPicker)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
