//
//  CampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/13/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignViewController: UIViewController {

    // MARK: Outlets and Actions
    @IBOutlet weak var campaignTableView: UITableView!
    
    // MARK: Global variables
    var viewModel: CampaignViewModelFromModel? {
        didSet {
            fillUI()
        }
    }
    
    var campaigns: [String:Campaign]!
    let colorDefinitions = ColorDefinitions()
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()

        campaignTableView.delegate = self
        campaignTableView.dataSource = self
        campaigns = viewModel?.campaigns
        
        fillUI()
        styleUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.campaigns = viewModel.campaigns
    }
    fileprivate func styleUI() {
        self.navigationItem.title = "Campaigns"
        self.campaignTableView.estimatedRowHeight = 100
        self.campaignTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = setTextAttributes(fontName: "Nyala", fontSize: 26.0, textColor: colorDefinitions.mainTextColor)
    }
    fileprivate func setTextAttributes(fontName: String, fontSize: CGFloat, textColor: UIColor) -> [ String : Any ] {
        let fontStyle = UIFont(name: fontName, size: fontSize)
        let fontColor = textColor
        return [ NSFontAttributeName : fontStyle! , NSForegroundColorAttributeName : fontColor ]
    }

    fileprivate func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Campaign"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    fileprivate func configureTitle(for cell: UITableViewCell, with campaign: Campaign) {
        let label = cell.viewWithTag(2600) as! UILabel
        label.text = campaign.title
        label.sizeToFit()
    }
}

extension CampaignViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campaigns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let myCampaigns = Array(self.campaigns.values)
        configureTitle(for: cell, with: myCampaigns[indexPath.row])

        cell.backgroundView?.alpha = 0.25
        cell.selectedBackgroundView?.alpha = 0.65
        return cell
    }
}
