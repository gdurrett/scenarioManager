//
//  CreateCampaignCharacterViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/9/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CreateCampaignCharacterViewControllerDelegate: class {
    func createCampaignCharacterViewControllerDidCancel(_ controller: CreateCampaignCharacterViewController)
    func createCampaignCharacterViewControllerDidFinishAdding(_ controller: CreateCampaignCharacterViewController)
}
protocol CreateCampaignCharacterPickerDelegate: class {
    func setCharacterType()
    var characterTypePickerDidPick: Bool { get set }
}
class CreateCampaignCharacterViewController: UIViewController, CreateCampaignCharacterViewModelDelegate {
    

    @IBOutlet var createCampaignCharacterView: UIView!
    
    @IBOutlet weak var createCampaignCharacterTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.createCampaignCharacterViewControllerDidCancel(self)
    }
    
    @IBAction func save(_ sender: UIStoryboardSegue) {
        delegate?.createCampaignCharacterViewControllerDidFinishAdding(self)
        //performSegue(withIdentifier: "unwindToCreateCampaignVC", sender: self)
    }
    
    var viewModel: CreateCampaignCharacterViewModel? {
        didSet {
            //
            viewModel!.delegate = self
        }
    }
    weak var delegate: CreateCampaignCharacterViewControllerDelegate?
    weak var pickerDelegate: CreateCampaignCharacterPickerDelegate!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var characterTypePicker = UIPickerView()
    var characterTypePickerData = [String]()
    var characterTypePickerInputView = UIView()
    var characterTypePickerDummyTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel!.reloadSection = { [weak self] (section: Int) in
            self?.createCampaignCharacterTableView.reloadData()
        }
        // For dismissing keyboard
        createCampaignCharacterTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((handleTap(sender:)))))
        // Set up Notification Center listeners
        NotificationCenter.default.addObserver(self, selector: #selector(self.showCampaignCharacterTypePicker), name: NSNotification.Name(rawValue: "showCampaignCharacterTypePicker"), object: nil)
        createCampaignCharacterTableView.dataSource = viewModel
        createCampaignCharacterTableView.delegate = viewModel
        
        characterTypePicker.dataSource = viewModel
        characterTypePicker.delegate = viewModel
        
        // Register cells
        createCampaignCharacterTableView?.register(CreateCharacterCharacterNameCell.nib, forCellReuseIdentifier: CreateCharacterCharacterNameCell.identifier)
        createCampaignCharacterTableView?.register(CharacterDetailCharacterLevelCell.nib, forCellReuseIdentifier: CharacterDetailCharacterLevelCell.identifier)
        
        createCampaignCharacterTableView?.register(CharacterDetailCharacterTypeCell.nib, forCellReuseIdentifier: CharacterDetailCharacterTypeCell.identifier)
        // Rename CreatePartyPartyNameCell to something more generic.
        createCampaignCharacterTableView?.register(CreatePartyPartyNameCell.nib, forCellReuseIdentifier: CreatePartyPartyNameCell.identifier)
        
        styleUI()
    }
    
    // Helper methods
    fileprivate func styleUI() {
        self.createCampaignCharacterTableView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.createCampaignCharacterTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.createCampaignCharacterTableView.backgroundView?.alpha = 0.25
        //self.createPartyTableView.separatorInset = .zero // Get rid of offset to left for tableview!
        self.createCampaignCharacterTableView.separatorStyle = .none
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    // Called via notification
    @objc func showCampaignCharacterTypePicker() {
        characterTypePicker.tag = 10
        characterTypePicker.layer.cornerRadius = 10
        characterTypePicker.layer.masksToBounds = true
        characterTypePicker.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        characterTypePicker.showsSelectionIndicator = true
        
        // Try to set up toolbar
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 40, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.layer.cornerRadius = 10
        toolBar.layer.masksToBounds = true
        toolBar.tintColor = colorDefinitions.scenarioTitleFontColor
        toolBar.barTintColor = colorDefinitions.scenarioSwipeFontColor
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(setCharacterType))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(characterTypePickerDidTapCancel))
        doneButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        cancelButton.setTitleTextAttributes([.font: UIFont(name: "Nyala", size: 24.0)!, .foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        characterTypePicker.reloadAllComponents()
        characterTypePicker.addSubview(toolBar)
        characterTypePickerInputView = UIView.init(frame: CGRect(x: 20, y: 310, width: self.view.frame.width - 40, height: characterTypePicker.frame.size.height + 44))
        characterTypePicker.frame = CGRect(x: 0, y: 0, width: characterTypePickerInputView.frame.width, height: 200)
        characterTypePicker.selectRow(0, inComponent: 0, animated: true) // Set to first row
        pickerDelegate?.characterTypePickerDidPick = false // Reset this after initial selection setting
        characterTypePickerInputView.addSubview(characterTypePicker)
        characterTypePickerInputView.addSubview(toolBar)
        characterTypePickerDummyTextField.inputView = characterTypePickerInputView
        characterTypePickerDummyTextField.isHidden = true
        self.view.addSubview(characterTypePickerDummyTextField)
        self.view.addSubview(characterTypePickerInputView)
    }
    @objc func setCharacterType() {
        pickerDelegate?.setCharacterType()
        self.characterTypePickerInputView.removeFromSuperview()
        self.characterTypePicker.removeFromSuperview()
        characterTypePickerData.removeAll()
    }
    @objc func characterTypePickerDidTapCancel() {
        self.characterTypePickerInputView.removeFromSuperview()
        self.characterTypePicker.removeFromSuperview()
        characterTypePickerData.removeAll()
    }
    // For CreateCampaignCharacterViewModelDelegate
    func showFormAlert(alertText: String, message: String) {
        let alertView = UIAlertController(
            title: alertText,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
    }
    // For CreateCampaignCharacterViewModelDelegate
    func doSegue() {
        performSegue(withIdentifier: "unwindToCreateCampaignVC", sender: self)
    }
}
