//
//  CharacterDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/5/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CharacterDetailViewControllerPickerDelegate: class {
    func setCharacterType()
    var characterTypePickerDidPick: Bool { get set }
}
protocol CharacterDetailViewControllerDelegate: class {
    func deleteCharacter(character: Character, controller: CharacterDetailViewController)
    func retireCharacter(character: Character)
}
class CharacterDetailViewController: UIViewController {

    @IBOutlet var characterDetailView: UIView!
    
    @IBOutlet weak var characterDetailTableView: UITableView!
    
    @IBAction func selectCharacterAction(_ sender: Any) {
        loadSelectCharacterViewController()
    }
    
    @IBAction func deleteCharacterAction(_ sender: Any) {
        showDeleteRetireCharacterActionSheet()
    }
    
    @IBAction func addCharacterAction(_ sender: Any) {
        loadCreateCharacterViewController()
    }
    weak var pickerDelegate: CharacterDetailViewControllerPickerDelegate!
    weak var delegate: CharacterDetailViewControllerDelegate!

    var viewModel: CharacterDetailViewModel!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var characterTypePicker = UIPickerView()
    var characterTypePickerData = [String]()
    var characterTypePickerInputView = UIView()
    var characterTypePickerDummyTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.reloadSection = { [weak self] (section: Int) in
//            if section == 0 {
//                self?.refreshCharacterStatus()
//            } else if section == 2 {
//                self?.refreshCharacterType()
//            }
//            if section == 3 {
//                self?.refreshCharacterAssignedParty()
//            }
            self?.characterDetailTableView.reloadData()
        }
        
        characterDetailTableView?.dataSource = viewModel
        characterDetailTableView?.delegate = viewModel
        characterTypePicker.delegate = viewModel
        characterTypePicker.dataSource = viewModel
        
        characterDetailTableView.separatorInset = .zero
        
        // Register cells
        characterDetailTableView?.register(CharacterDetailCharacterNameCell.nib, forCellReuseIdentifier: CharacterDetailCharacterNameCell.identifier)
        characterDetailTableView?.register(CharacterDetailCharacterLevelCell.nib, forCellReuseIdentifier: CharacterDetailCharacterLevelCell.identifier)
        characterDetailTableView?.register(CharacterDetailCharacterTypeCell.nib, forCellReuseIdentifier: CharacterDetailCharacterTypeCell.identifier)
        characterDetailTableView?.register(CharacterDetailAssignedPartyCell.nib, forCellReuseIdentifier: CharacterDetailAssignedPartyCell.identifier)
        characterDetailTableView?.register(CharacterDetailPlayedScenarioCell.nib, forCellReuseIdentifier: CharacterDetailPlayedScenarioCell.identifier)
        
        // Set up Notification Center listeners
        NotificationCenter.default.addObserver(self, selector: #selector(self.showCharacterTypePicker), name: NSNotification.Name(rawValue: "showCharacterTypePicker"), object: nil)

        styleUI()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        viewModel.updateAssignedParty()
        viewModel.updateCharacterLevel()
        viewModel.updateCharacters()
        
        self.characterDetailTableView.reloadData()
    }
    // Helper methods
    fileprivate func styleUI() {
        self.characterDetailTableView.estimatedRowHeight = 80
        self.characterDetailTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hue: 46/360, saturation: 8/100, brightness: 100/100, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        //self.navigationItem.title = ("\(self.viewModel.campaignTitle.value) Detail")
        self.navigationItem.title = "Character Detail"
        self.characterDetailTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.characterDetailTableView.backgroundView?.alpha = 0.25
    }
    func refreshCharacterStatus() {
        DispatchQueue.main.async {
            self.characterDetailTableView.reloadSections([0], with: .none)
        }
    }
    func refreshCharacterType() {
        DispatchQueue.main.async {
            self.characterDetailTableView.reloadSections([2], with: .none)
        }
    }
    func refreshCharacterAssignedParty() {
        DispatchQueue.main.async {
            self.characterDetailTableView.reloadSections([3], with: .none)
        }
    }
    // Called by action button
    @objc func loadSelectCharacterViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectCharacterVC = storyboard.instantiateViewController(withIdentifier: "SelectCharacterViewController") as! SelectCharacterViewController
        selectCharacterVC.delegate = viewModel
        selectCharacterVC.viewModel = viewModel
        selectCharacterVC.hidesBottomBarWhenPushed = true
        self.navigationController!.present(selectCharacterVC, animated: true, completion: nil)
    }
    fileprivate func loadCreateCharacterViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createCharacterVC = storyboard.instantiateViewController(withIdentifier: "CreateCharacterViewController") as! CreateCharacterViewController
        createCharacterVC.viewModel = CreateCharacterViewModel(withDataModel: viewModel!.dataModel)
        createCharacterVC.viewModel!.delegate = self.viewModel // So we can call back to our VM to set new character
        createCharacterVC.delegate = createCharacterVC.viewModel
        createCharacterVC.hidesBottomBarWhenPushed = true
        self.navigationController!.present(createCharacterVC, animated: true, completion: nil)
    }
    fileprivate func showDeleteRetireCharacterActionSheet() {
        // Raise action sheet here with option to delete, retire, or cancel
        let alertController = UIAlertController(title: "Retire or Delete Character?", message: "Choose an option below", preferredStyle: .actionSheet)
        let retireButton = UIAlertAction(title: "Retire character", style: .default, handler: { (action) -> Void in
            self.delegate.retireCharacter(character: self.viewModel.character)
        })
        let deleteButton = UIAlertAction(title: "Delete character", style: .default, handler: { (action) -> Void in
            self.delegate.deleteCharacter(character: self.viewModel.character, controller: self)
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        
        alertController.addAction(retireButton)
        alertController.addAction(deleteButton)
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    func showDisallowDeletionAlert() {
        let alertTitle = "Cannot delete only remaining character!"
        let alertView = UIAlertController(
            title: alertTitle,
            message: "Create a new character before deleting this one.",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        present(alertView, animated: true, completion: nil)
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
        pickerDelegate.setCharacterType()
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
