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
class CreatePartyViewController: UIViewController {

    @IBOutlet weak var createPartyTableView: UITableView!
    
    @IBOutlet var createPartyView: UIView!
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.createPartyViewControllerDidCancel(self)
    }
    
    @IBAction func save(_ sender: Any) {
        delegate?.createPartyViewControllerDidFinishAdding(self)
    }
    
    var viewModel: CreatePartyViewModel? {
        didSet {
            //
        }
    }
    weak var delegate: CreatePartyViewControllerDelegate?
    
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createPartyTableView?.dataSource = viewModel
        createPartyTableView?.delegate = viewModel
        
        createPartyTableView?.register(CreatePartyPartyNameCell.nib, forCellReuseIdentifier: CreatePartyPartyNameCell.identifier)
        
        styleUI()
        
    }
    
    // Helper methods
    fileprivate func styleUI() {
        self.createPartyView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.createPartyTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.createPartyTableView.backgroundView?.alpha = 0.25
        //self.createPartyTableView.separatorInset = .zero // Get rid of offset to left for tableview!
        self.createPartyTableView.separatorStyle = .none
    }

}
