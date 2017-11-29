//
//  CreateCharacterViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/9/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CreateCharacterViewControllerDelegate: class {
    func createCharacterViewControllerDidCancel(_ controller: CreateCharacterViewController)
    func createCharacterViewControllerDidFinishAdding(_ controller: CreateCharacterViewController)
}
class CreateCharacterViewController: UIViewController {

    @IBOutlet var createCharacterView: UIView!
    
    @IBOutlet weak var createCharacterTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.createCharacterViewControllerDidCancel(self)
    }
    
    @IBAction func save(_ sender: Any) {
        delegate?.createCharacterViewControllerDidFinishAdding(self)
    }
    
    var viewModel: CreateCharacterViewModel? {
        didSet {
            //
        }
    }
    weak var delegate: CreateCharacterViewControllerDelegate?
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCharacterTableView?.dataSource = viewModel
        createCharacterTableView?.delegate = viewModel
        
        // Register cells
        createCharacterTableView?.register(CreateCharacterCharacterNameCell.nib, forCellReuseIdentifier: CreateCharacterCharacterNameCell.identifier)
        
        // Rename CreatePartyPartyNameCell to something more generic.
        createCharacterTableView?.register(CreatePartyPartyNameCell.nib, forCellReuseIdentifier: CreatePartyPartyNameCell.identifier)
        
        styleUI()
    }
    
    // Helper methods
    fileprivate func styleUI() {
        self.createCharacterTableView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.createCharacterTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.createCharacterTableView.backgroundView?.alpha = 0.25
        //self.createPartyTableView.separatorInset = .zero // Get rid of offset to left for tableview!
        self.createCharacterTableView.separatorStyle = .none
    }
    
}
