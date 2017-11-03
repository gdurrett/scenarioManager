//
//  CreateCampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CreateCampaignViewControllerDelegate: class {
    func createCampaignViewControllerDidCancel(_ controller: CreateCampaignViewController)
    func createCampaignViewControllerDidFinishAdding(_ controller: CreateCampaignViewController)
}
// Test Test!
protocol CreateCampaignViewControllerReloadDelegate: class {
    func reloadAfterDidFinishAdding()
}
class CreateCampaignViewController: UIViewController {
    
    @IBOutlet weak var createCampaignTableView: UITableView!
    
    @IBOutlet var createCampaignView: UIView!
    
    @IBAction func save(_ sender: Any) {
        delegate?.createCampaignViewControllerDidFinishAdding(self)
        // Test Test!
        reloadDelegate?.reloadAfterDidFinishAdding()
    }
    @IBAction func cancel(_ sender: Any) {
         delegate?.createCampaignViewControllerDidCancel(self)
    }
    
    var viewModel: CreateCampaignViewModelFromModel? {
        didSet {
            //
        }
    }
    weak var delegate: CreateCampaignViewControllerDelegate?
    // Test Test!
    weak var reloadDelegate: CreateCampaignViewControllerReloadDelegate?
    
    var newCampaignTitle: String?
    var selectedParties: [String]?
    
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCampaignTableView.allowsMultipleSelection = true
        
        createCampaignTableView?.dataSource = viewModel
        createCampaignTableView?.delegate = viewModel
        
        createCampaignTableView?.register(CreateCampaignTitleCell.nib, forCellReuseIdentifier: CreateCampaignTitleCell.identifier)
        createCampaignTableView?.register(CreateCampaignPartyCell.nib, forCellReuseIdentifier: CreateCampaignPartyCell.identifier)
        
        styleUI()
        
    }

    // Helper methods
    fileprivate func styleUI() {
        self.createCampaignView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.createCampaignTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.createCampaignTableView.backgroundView?.alpha = 0.25
        self.createCampaignTableView.separatorStyle = .none
    }
}
