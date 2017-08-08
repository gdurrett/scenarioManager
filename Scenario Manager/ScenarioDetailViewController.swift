//
//  ScenarioDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/25/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit


class ScenarioDetailViewController: UIViewController {
    
    fileprivate let viewModel = ScenarioDetailViewModel()
    fileprivate let mainVC = ScenarioViewController()
    
    @IBOutlet weak var tableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.backgroundColor = UIColor(hue: 30/360, saturation: 14/100, brightness: 87/100, alpha: 1.0)
        
        tableView?.dataSource = viewModel
        tableView?.delegate = viewModel
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.register(ScenarioTitleCell.nib, forCellReuseIdentifier: ScenarioTitleCell.identifier)
        tableView?.register(SummaryInfoCell.nib, forCellReuseIdentifier: SummaryInfoCell.identifier)
        tableView?.register(LocationInfoCell.nib, forCellReuseIdentifier: LocationInfoCell.identifier)
        tableView?.register(UnlockedByInfoCell.nib, forCellReuseIdentifier: UnlockedByInfoCell.identifier)
        tableView?.register(UnlocksInfoCell.nib, forCellReuseIdentifier: UnlocksInfoCell.identifier)
        tableView?.register(RequirementsInfoCell.nib, forCellReuseIdentifier: RequirementsInfoCell.identifier)
        tableView?.register(RewardsInfoCell.nib, forCellReuseIdentifier: RewardsInfoCell.identifier)
        tableView?.register(AchievesInfoCell.nib, forCellReuseIdentifier: AchievesInfoCell.identifier)
    }

}
