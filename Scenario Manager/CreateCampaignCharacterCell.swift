//
//  CreateCampaignCharacterCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/9/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CreateCampaignCharacterCellDelegate: class {
    func updateAvailableCharacters(characterToRemove: String)
}
class CreateCampaignCharacterCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {


    @IBOutlet weak var createCampaignCharacterTextField: UITextField!
    
    var pickerData = [String]()
    var didPick = false
    weak var delegate: CreateCampaignCharacterCellDelegate?
    var createCampaignCharacterPicker = UIPickerView()
    
    var viewModel: CreateCampaignViewModelFromModel? {
        didSet {
            print("Got viewModel")
        }
    }
    func configure(withViewModel viewModel: CreateCampaignViewModelFromModel) {
        createCampaignCharacterTextField.placeholder = viewModel.returnTextFieldPlaceholderText()
        self.viewModel = viewModel
        self.delegate = viewModel
        for party in viewModel.parties.keys {
            self.pickerData.append(party)
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
        didPick = true
        createCampaignCharacterTextField.text = pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerData.count > 1 { pickerData.removeAll() }
        for party in viewModel!.remainingParties.keys {
            self.pickerData.append(party)
            print("Appending \(party)")
        }
        createCampaignCharacterTextField.text = pickerData[row]
        return pickerData[row]
    }
    
    func donePicker() {
        
        if !didPick {
            createCampaignCharacterPicker.selectRow(0, inComponent: 0, animated: true)
            let row = createCampaignCharacterPicker.selectedRow(inComponent: 0)
            createCampaignCharacterTextField.text = pickerData[row]
        }
        delegate?.updateAvailableCharacters(characterToRemove: createCampaignCharacterTextField.text!)
        createCampaignCharacterTextField.resignFirstResponder()
        createCampaignCharacterPicker.reloadAllComponents()
    }
    func cancelPicker() {
        createCampaignCharacterTextField.resignFirstResponder()
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
        let createCampaignCharacterPicker = UIPickerView(frame: CGRect(x: 10, y: 140, width: self.frame.width - 20, height: 200))
        createCampaignCharacterPicker.layer.cornerRadius = 10
        createCampaignCharacterPicker.layer.masksToBounds = true
        createCampaignCharacterPicker.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        createCampaignCharacterPicker.showsSelectionIndicator = true
        createCampaignCharacterPicker.delegate = self
        createCampaignCharacterPicker.dataSource = self
        
        // Set up toolbar for picker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateCampaignCharacterCell.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateCampaignCharacterCell.cancelPicker))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        createCampaignCharacterTextField.inputView = createCampaignCharacterPicker
        createCampaignCharacterTextField.inputAccessoryView = toolBar
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
