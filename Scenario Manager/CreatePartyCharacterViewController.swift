//
//  CreatePartyCharacterViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 12/2/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CreatePartyCharacterViewControllerDelegate: class {
    func createPartyCharacterViewControllerDidCancel(_ controller: CreatePartyCharacterViewController)
    func createPartyCharacterViewControllerDidFinishAdding(_ controller: CreatePartyCharacterViewController)
}
protocol CreatePartyCharacterPickerDelegate: class {
    func setCharacterType()
    var characterTypePickerDidPick: Bool { get set }
}

class CreatePartyCharacterViewController: UIViewController {
  
    @IBOutlet var createPartyCharacterView: UIView!
    
    @IBOutlet weak var createPartyCharacterTableView: UITableView!
    
    @IBAction func save(_ sender: UIStoryboardSegue) {
        delegate!.createPartyCharacterViewControllerDidFinishAdding(self)
        performSegue(withIdentifier: "unwindToCreatePartyVC", sender: self)
    }
    var viewModel: CreatePartyCharacterViewModel? {
        didSet {
            //
        }
    }
    weak var delegate: CreatePartyCharacterViewControllerDelegate?
    weak var pickerDelegate: CreatePartyCharacterPickerDelegate!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var characterTypePicker = UIPickerView()
    var characterTypePickerData = [String]()
    var characterTypePickerInputView = UIView()
    var characterTypePickerDummyTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel!.reloadSection = { [weak self] (section: Int) in
            self?.createPartyCharacterTableView.reloadData()
        }
        // For dismissing keyboard
        createPartyCharacterTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector((handleTap(sender:)))))
        
        // Set up Notification Center listeners
        NotificationCenter.default.addObserver(self, selector: #selector(self.showCharacterTypePicker), name: NSNotification.Name(rawValue: "showCharacterTypePicker"), object: nil)
        createPartyCharacterTableView.dataSource = viewModel
        createPartyCharacterTableView.delegate = viewModel
        
        characterTypePicker.dataSource = viewModel
        characterTypePicker.delegate = viewModel
        
        // Register cells
        createPartyCharacterTableView?.register(CreateCharacterCharacterNameCell.nib, forCellReuseIdentifier: CreateCharacterCharacterNameCell.identifier)
        createPartyCharacterTableView?.register(CharacterDetailCharacterLevelCell.nib, forCellReuseIdentifier: CharacterDetailCharacterLevelCell.identifier)
        
        createPartyCharacterTableView?.register(CharacterDetailCharacterTypeCell.nib, forCellReuseIdentifier: CharacterDetailCharacterTypeCell.identifier)
        // Rename CreatePartyPartyNameCell to something more generic.
        createPartyCharacterTableView?.register(CreatePartyPartyNameCell.nib, forCellReuseIdentifier: CreatePartyPartyNameCell.identifier)
        
        styleUI()
    }
    
    // Helper methods
    fileprivate func styleUI() {
        self.createPartyCharacterTableView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.createPartyCharacterTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.createPartyCharacterTableView.backgroundView?.alpha = 0.25
        //self.createPartyTableView.separatorInset = .zero // Get rid of offset to left for tableview!
        self.createPartyCharacterTableView.separatorStyle = .none
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    // Called via notification
    @objc func showCharacterTypePicker() {
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
        pickerDelegate!.setCharacterType()
        self.characterTypePickerInputView.removeFromSuperview()
        self.characterTypePicker.removeFromSuperview()
        characterTypePickerData.removeAll()
    }
    @objc func characterTypePickerDidTapCancel() {
        self.characterTypePickerInputView.removeFromSuperview()
        self.characterTypePicker.removeFromSuperview()
        characterTypePickerData.removeAll()
    }
}
