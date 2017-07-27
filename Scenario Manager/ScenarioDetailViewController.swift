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
    
    @IBOutlet weak var tableView: UITableView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.dataSource = viewModel
        tableView?.estimatedRowHeight = 100
        tableView?.rowHeight = UITableViewAutomaticDimension
        tableView?.register(ScenarioTitleCell.nib, forCellReuseIdentifier: ScenarioTitleCell.identifier)
        tableView?.register(UnlocksInfoCell.nib, forCellReuseIdentifier: UnlocksInfoCell.identifier)
        tableView?.register(UnlockedByInfoCell.nib, forCellReuseIdentifier: UnlockedByInfoCell.identifier)
        tableView?.register(AchievesInfoCell.nib, forCellReuseIdentifier: AchievesInfoCell.identifier)
    }
    
}
