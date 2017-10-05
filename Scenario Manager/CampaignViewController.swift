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
    @IBOutlet weak var campaignTableViewOutlet: UITableView!
    
    @IBAction func createCampaignAction(_ sender: Any) {
        loadCreateCampaignViewController()
    }
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
        fillUI()

        campaignTableViewOutlet.delegate = self
        campaignTableViewOutlet.dataSource = self
        
        campaignTableViewOutlet.reloadData()
        styleUI()
        
        // Test notification
        NotificationCenter.default.addObserver(self, selector: #selector(triggerSegue), name: NSNotification.Name(rawValue: "triggerSegue"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel!.updateAvailableCampaigns()
        campaignTableViewOutlet.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        //UIView.setAnimationsEnabled(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCampaignDetail" {
            let destinationVC = segue.destination as! CampaignDetailViewController
            let viewModel = CampaignDetailViewModel(withCampaign: (self.viewModel?.selectedCampaign!)!)
            destinationVC.viewModel = viewModel
        }
    }
    
    // Perform segue (Show Campaign Detail when row is tapped)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Extract campaigns from Dictionary into an array
        let myCampaigns = Array(self.campaigns.values)
        // Them we can subscript them
        viewModel?.selectedCampaign = myCampaigns[indexPath.row]
        performSegue(withIdentifier: "ShowCampaignDetail", sender: myCampaigns[indexPath.row])
        campaignTableViewOutlet.deselectRow(at: indexPath, animated: true)
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
        //campaigns = viewModel.campaigns
        viewModel.campaigns.bindAndFire { [unowned self] in self.campaigns = $0 }
    }
    fileprivate func styleUI() {
        //self.navigationItem.title = "Campaigns"
        self.campaignTableViewOutlet.estimatedRowHeight = 100
        self.campaignTableViewOutlet.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
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
    // Action methods
    fileprivate func loadCreateCampaignViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "createCampaignViewController") as! CreateCampaignViewController
        createCampaignVC.delegate = self
        createCampaignVC.viewModel = self.viewModel!.createCampaignViewModel
        createCampaignVC.hidesBottomBarWhenPushed = true
        self.navigationController!.pushViewController(createCampaignVC, animated: true)
    }
    // Notification method
    @objc func triggerSegue() {
        //UIView.setAnimationsEnabled(false)
        performSegue(withIdentifier: "ShowCampaignDetail", sender: viewModel?.selectedCampaign)
    }
}

extension CampaignViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return campaigns!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let myCampaigns = Array(self.campaigns.values)
        configureTitle(for: cell, with: myCampaigns[indexPath.row])
        
        cell.backgroundView?.alpha = 0.25
        cell.selectedBackgroundView?.alpha = 0.65
        return cell as! CampaignMainCell
    }
}

extension CampaignViewController: CreateCampaignViewControllerDelegate {
    // Delegate methods for CreateCampaignViewController
    func createCampaignViewControllerDidCancel(_ controller: CreateCampaignViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    func createCampaignViewControllerDidFinishAdding(_ controller: CreateCampaignViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
}
