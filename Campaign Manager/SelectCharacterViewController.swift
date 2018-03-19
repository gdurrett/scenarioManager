//
//  SelectCharacterViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/8/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol SelectCharacterViewControllerDelegate: class {
    func deleteCharacter(character: Character, controller: SelectCharacterViewController)
    func retireCharacter(character: Character)
    func updateCharacters()
    func updateActiveStatus()
    func triggerSave()
}

class SelectCharacterViewController: UIViewController {
    
    @IBOutlet var selectCharacterView: UIView!
    
    @IBOutlet weak var selectCharacterTableView: UITableView!
    
    @IBAction func selectCharacterFilterAction(_ sender: Any) {
        //self.navigationItem.title = "\(viewModel!.assignedParty.value)"
        self.navigationItem.title = "Characters"
        selectCharacterTableView.reloadData()
    }
    
    @IBAction func createCharacterAction(_ sender: Any) {
        loadCreateCharacterViewController()
    }
    @IBOutlet weak var selectCharacterFilterOutlet: UISegmentedControl!
    
    // MARK: Global Variables
    var viewModel: CharacterDetailViewModel? {
        didSet {
            fillUI()
            self.characters = viewModel!.characters.value
        }
    }
    weak var actionDelegate: SelectCharacterViewControllerDelegate?

    var characters: [Character]?
    var character: Character!
    var myCharacterAssignment: String?
    var myCharacterRetirement: String?
    var disableCharacterSwipe = false
    let colorDefinitions = ColorDefinitions()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel!.reloadSection = { [weak self] (section: Int) in
            if section == 0 {
                self?.selectCharacterTableView!.reloadData()
            }
        }
        
        selectCharacterTableView.delegate = self
        selectCharacterTableView.dataSource = self
        selectCharacterTableView?.register(SelectCharacterTitleCell.nib, forCellReuseIdentifier: SelectCharacterTitleCell.identifier)
        selectCharacterTableView.allowsMultipleSelection = false
        
        fillUI()
        styleUI()
        setSegmentTitles()
    }
    override func viewWillAppear(_ animated: Bool) {
        viewModel!.updateCharacters()
        viewModel!.updateActiveStatus()
        viewModel!.updateCurrentParty()
        setSegmentTitles()
        selectCharacterTableView.reloadData()
    }
    // Helper methods
    fileprivate func fillUI() {
        if !isViewLoaded {
            return
        }
        guard let viewModel = viewModel else {
            return
        }
        // We definitely have setup done now
        self.characters = viewModel.characters.value
    }
    fileprivate func styleUI() {
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        self.selectCharacterTableView.backgroundColor = colorDefinitions.mainBGColor
//        self.selectCharacterTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
//        self.selectCharacterTableView.backgroundView?.alpha = 0.25
        self.selectCharacterTableView.separatorInset = .zero
    }
    fileprivate func setSegmentTitles() {
        selectCharacterFilterOutlet.setTitle("Active (\(viewModel!.activeCharacters.value.count))", forSegmentAt: 0)
        selectCharacterFilterOutlet.setTitle("Inactive (\(viewModel!.inactiveCharacters.value.count))", forSegmentAt: 1)
        selectCharacterFilterOutlet.setTitle("Retired (\(viewModel!.retiredCharacters.value.count))", forSegmentAt: 2)
        selectCharacterFilterOutlet.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Nyala", size: 20.0)!, NSAttributedStringKey.foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        selectCharacterFilterOutlet.backgroundColor = colorDefinitions.scenarioSegmentedControlBGColor
        self.navigationItem.title = "\(viewModel!.currentParty.value)"
        self.navigationItem.title = "Characters"
        selectCharacterTableView.reloadData()
    }
    fileprivate func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "SelectCharacterTitleCell"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    fileprivate func configureTitle(for cell: UITableViewCell, with character: Character) {
        let label = cell.viewWithTag(3500) as! UILabel
            label.text = character.name
            label.sizeToFit()
    }
    fileprivate func configureCharacterInfo(for cell: UITableViewCell, with character: Character) {            let label = cell.viewWithTag(3600) as! UILabel
        if character.level != 0 {
            label.isHidden = false
            label.text = ("level \(Int(character.level)) \(character.type)")
        } else {
            label.isHidden = true
        }
    }
    fileprivate func configureCharacterPartyInfo(for cell: UITableViewCell, with character: Character) {
        let label = cell.viewWithTag(3700) as! UILabel
        if character.assignedTo != "None" {
            label.isHidden = false
            label.text = ("party: \(character.assignedTo!)")
        } else {
            label.isHidden = true
        }
    }
    fileprivate func configureSwipeButton(for character: Character) {
        if character.isActive == true && viewModel!.activeCharacters.value.count == 1 {
            myCharacterAssignment = "Cannot set inactive"
            myCharacterRetirement = "Cannot set retired"
        } else if character.isActive == true {
            myCharacterAssignment = "Set inactive"
            myCharacterRetirement = "Set retired"
        } else if character.isActive == false && character.isRetired != true && viewModel!.activeCharacters.value.count < 4 {
            myCharacterAssignment = "Set active"
            myCharacterRetirement = "Set retired"
        } else if character.isActive == false && character.isRetired != true && viewModel!.activeCharacters.value.count > 3 {
            myCharacterAssignment = "Cannot set active"
            myCharacterRetirement = "Set retired"
        } else {
            myCharacterRetirement = "Delete"
        }
    }
    func showSelectionAlert(status: String) {
        var alertTitle = String()
        if status == "disallowSetInactive" {
            alertTitle = "Cannot set last active party member inactive!"
        } else if status == "disallowSetRetired" {
            alertTitle = "Cannot set last active party member retired!"
        } else if status == "disallowSetActive" {
            alertTitle = "Cannot have more than four active party members!"
        } else if status == "disallowUncompletion" {
            alertTitle = "Cannot set to Uncompleted with more than one party in campaign!"
        } else if status == "disallowStatusChange" {
            alertTitle = "Cannot change scenario status without active characters!"
        } else {
            alertTitle = "Cannot set to Uncompleted due to a subsequent scenario being completed!"
        }
        let alertView = UIAlertController(
            title: alertTitle,
            message: nil,
            preferredStyle: .actionSheet)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        alertView.popoverPresentationController?.sourceView = self.view

        present(alertView, animated: true, completion: nil)
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
        alertView.popoverPresentationController?.sourceView = self.view

        present(alertView, animated: true, completion: nil)
    }
    fileprivate func showConfirmDeletionAlert () {
        let alertController = UIAlertController(title: "Delete this character?", message: "Clicking OK will delete the current character.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Delete", style: .default) { (action:UIAlertAction!) in
            self.actionDelegate?.deleteCharacter(character: self.character, controller: self)
            self.actionDelegate?.updateCharacters()
            self.actionDelegate?.updateActiveStatus()
            self.setSegmentTitles()
            self.actionDelegate?.triggerSave()
            self.selectCharacterTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        alertController.popoverPresentationController?.sourceView = self.view

        self.present(alertController, animated: true, completion:nil)
    }
    fileprivate func showConfirmRetirementAlert () {
        let alertController = UIAlertController(title: "Retire this character?", message: "Clicking OK will retire the current character.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Retire", style: .default) { (action:UIAlertAction!) in
            self.character.isActive = false
            self.character.isRetired = true
            //self.character.assignedTo = "None" // Test 18/03/13
            self.viewModel!.updateCharacters()
            self.viewModel!.updateActiveStatus()
            self.setSegmentTitles()
            self.viewModel!.triggerSave()
            self.selectCharacterTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        alertController.popoverPresentationController?.sourceView = self.view
        
        self.present(alertController, animated: true, completion:nil)
    }
    // Action Methods
    fileprivate func loadCreateCharacterViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createCharacterVC = storyboard.instantiateViewController(withIdentifier: "CreateCharacterViewController") as! CreateCharacterViewController
        let createCharacterVM = CreateCharacterViewModel(withDataModel: viewModel!.dataModel)
        createCharacterVC.viewModel = createCharacterVM
        createCharacterVM.delegate = self.viewModel // So we can call back to our VM to set new character
        createCharacterVC.delegate = createCharacterVM
        createCharacterVC.hidesBottomBarWhenPushed = true
        createCharacterVC.pickerDelegate = createCharacterVM as CreateCharacterPickerDelegate
        self.navigationController!.present(createCharacterVC, animated: true, completion: nil)
    }
}
extension SelectCharacterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue = 0
        switch selectCharacterFilterOutlet.selectedSegmentIndex {
        case 0:
            disableCharacterSwipe = false
            returnValue = viewModel!.activeCharacters.value.count
        case 1:
            if viewModel!.inactiveCharacters.value.count == 0 {
                disableCharacterSwipe = true // Don't allow swipe action on this cell
                return 1
            } else {
                disableCharacterSwipe = false
                returnValue = viewModel!.inactiveCharacters.value.count
            }
        case 2:
            if viewModel!.retiredCharacters.value.count == 0 {
                disableCharacterSwipe = true
                return 1
            } else {
                disableCharacterSwipe = false
                returnValue = viewModel!.retiredCharacters.value.count
            }
        default:
            break
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        cell.backgroundColor = UIColor.clear
        switch selectCharacterFilterOutlet.selectedSegmentIndex {
        case 0:
            character = viewModel!.activeCharacters.value[indexPath.row]
        case 1:
            if viewModel!.inactiveCharacters.value.count == 0 {
                character = Character(name: "No inactive characters", goal: "None", type: "None", level: 0, isActive: true, isRetired: true, assignedTo: "None", playedScenarios: ["None"])
            } else {
                character = viewModel!.inactiveCharacters.value[indexPath.row]
            }
        case 2:
            if viewModel!.retiredCharacters.value.count == 0 {
                character = Character(name: "No retired characters", goal: "None", type: "None", level: 0, isActive: true, isRetired: true, assignedTo: "None", playedScenarios: ["None"])
            } else {
                character = viewModel!.retiredCharacters.value[indexPath.row]
            }
        default:
            break
        }
        configureTitle(for: cell, with: character)
        configureCharacterInfo(for: cell, with: character)
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        
        return cell
    }
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCharacterDetail" {
            let destinationVC = segue.destination as! CharacterDetailViewController
            let viewModel = CharacterDetailViewModel(withCharacter: character)
            destinationVC.viewModel = viewModel
            //destinationVC.pickerDelegate = viewModel
        }
    }
    // didSelect triggers segue (Show Character Detail when cell is tapped)
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        if disableCharacterSwipe == false {
            switch(selectCharacterFilterOutlet.selectedSegmentIndex) {
                case 0:
                    character = viewModel!.activeCharacters.value[indexPath.row]
                case 1:
                    character = viewModel!.inactiveCharacters.value[indexPath.row]
                case 2:
                    character = viewModel!.retiredCharacters.value[indexPath.row]
                default:
                    break
                }
            performSegue(withIdentifier: "ShowCharacterDetail", sender: character)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch(selectCharacterFilterOutlet.selectedSegmentIndex) {
        case 0:
            character = viewModel!.activeCharacters.value[indexPath.row]
        case 1:
            character = viewModel!.inactiveCharacters.value[indexPath.row]
        case 2:
            character = viewModel!.retiredCharacters.value[indexPath.row]
        default:
            break
        }
        configureSwipeButton(for: character)
        let swipeToggleActive = UITableViewRowAction(style: .normal, title: self.myCharacterAssignment) { action, index in
            if self.myCharacterAssignment == "Cannot set inactive" {
                self.showSelectionAlert(status: "disallowSetInactive")
            } else if self.myCharacterAssignment == "Cannot set active" {
                self.showSelectionAlert(status: "disallowSetActive")
            } else if self.myCharacterAssignment == "Set inactive" {
                self.character.isActive = false
                self.viewModel!.updateCharacters()
                self.viewModel!.updateActiveStatus()
                self.setSegmentTitles()
                self.viewModel!.triggerSave()
                tableView.reloadData()
            } else if self.myCharacterAssignment == "Set active" {
                self.character.isActive = true
                self.viewModel!.updateCharacters()
                self.viewModel!.updateActiveStatus()
                self.setSegmentTitles()
                self.viewModel!.triggerSave()
                tableView.reloadData()
            }
        }
        let swipeToggleRetire = UITableViewRowAction(style: .normal, title: self.myCharacterRetirement) { action, index in
            if self.myCharacterRetirement == "Cannot set retired" {
                self.showSelectionAlert(status: "disallowSetRetired")
            } else if self.myCharacterRetirement == "Set retired" {
                self.showConfirmRetirementAlert()
            } else if self.myCharacterRetirement == "Delete" {
                self.showConfirmDeletionAlert()
            }
        }
        swipeToggleActive.backgroundColor = colorDefinitions.scenarioSwipeBGColor
        swipeToggleRetire.backgroundColor = UIColor.darkGray
        if myCharacterRetirement == "Delete" {
            return [swipeToggleRetire]
        } else if myCharacterAssignment == "Set inactive" {
            return [swipeToggleActive, swipeToggleRetire]
        } else {
            return [swipeToggleActive, swipeToggleRetire]
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var returnValue: Bool
        if disableCharacterSwipe == false {
            returnValue = true
        } else {
            returnValue = false
        }
        return returnValue
    }
}
