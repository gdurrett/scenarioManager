//
//  CreatePartyViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/31/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CreatePartyViewControllerDelegate: class {
    func createPartyViewControllerDidCancel(_ controller: CreatePartyViewController)
    func createPartyViewControllerDidFinishAdding(_ controller: CreatePartyViewController)
}
class CreatePartyViewController: UIViewController, CreatePartyViewModelDelegate {
    
    @IBOutlet var createPartyView: UIView!
    
    @IBOutlet weak var createPartyTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.createPartyViewControllerDidCancel(self)
    }
    
    @IBAction func save(_ sender: Any) {
        delegate?.createPartyViewControllerDidFinishAdding(self)
    }
    @IBAction func unwindToCreatePartyVC(segue: UIStoryboardSegue) {
        self.createPartyTableView.reloadData()
    }
    var selectedCharacter: Character {
        get {
            return currentCharacter!
        }
        set {
            currentCharacter = newValue
        }
    }
    var viewModel: CreatePartyViewModel? {
        didSet {
            viewModel!.delegate = self
        }
    }
    weak var delegate: CreatePartyViewControllerDelegate?
    
    var campaignName: String?
    var currentCharacter: Character?
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel!.reloadSection = { [weak self] (section: Int) in
            self?.createPartyTableView.reloadData()
        }
        
        // Register Cells
        createPartyTableView.register(CreatePartyPartyNameCell.nib, forCellReuseIdentifier: CreatePartyPartyNameCell.identifier)
        createPartyTableView.register(CreateCampaignCharacterCell.nib, forCellReuseIdentifier: CreateCampaignCharacterCell.identifier)
        
        createPartyTableView.delegate = viewModel
        createPartyTableView.dataSource = viewModel
        
        styleUI()
        
    }
    
    // Helper methods
    fileprivate func styleUI() {
//        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
//        backgroundImage.image = UIImage(named: "campaignDetailTableViewBG")
//        backgroundImage.alpha = 0.25
//        self.createPartyTableView.insertSubview(backgroundImage, at: 0)
        self.createPartyTableView.backgroundColor = colorDefinitions.mainBGColor
        let leftBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel(_:)))
        self.navigationItem.title = "Create Party"
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hue: 46/360, saturation: 8/100, brightness: 100/100, alpha: 1.0)
        self.navigationItem.leftBarButtonItem = leftBarButton
        leftBarButton.tintColor = colorDefinitions.mainTextColor
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save(_:)))
        rightBarButton.tintColor = colorDefinitions.mainTextColor
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreatePartyCharacterVC" {
            let destinationVC = segue.destination as! CreatePartyCharacterViewController
            let destinationVM = CreatePartyCharacterViewModel(withDataModel: viewModel!.dataModel)
            destinationVC.viewModel = destinationVM
            destinationVC.pickerDelegate = destinationVM as CreatePartyCharacterPickerDelegate
            destinationVC.delegate = destinationVM
            destinationVM.selectedCharacterRow = self.viewModel!.selectedCharacterRow
        }
    }
    // For CreatePartyViewModelDelegate
    func showFormAlert(alertText: String, message: String) {
        let alertView = UIAlertController(
            title: alertText,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertView.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertView.addAction(action)
        alertView.popoverPresentationController?.sourceView = self.view

        present(alertView, animated: true, completion: nil)
    }
}
