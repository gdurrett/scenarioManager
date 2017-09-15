//
//  DeleteCampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/12/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol DeleteCampaignViewControllerDelegate: class {
    func deleteCampaignViewControllerDidCancel(_ controller: DeleteCampaignViewController)
    func deleteCampaignViewControllerDidFinishDeleting(_ controller: DeleteCampaignViewController)
}
class DeleteCampaignViewController: UIViewController {

    var viewModel: DeleteCampaignViewModelFromModel? {
        didSet {
            //
        }
    }
    var campaigns: [String:Campaign]?
    var campaignsToDelete: [String]?
    
    weak var delegate: DeleteCampaignViewControllerDelegate?
    
    @IBOutlet weak var deleteCampaignView: UIView!
    
    @IBOutlet weak var deleteCampaignTableView: UITableView!
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.deleteCampaignViewControllerDidCancel(self)
    }
    
    @IBAction func done(_ sender: Any) {
        print("Would be removing: \(campaignsToDelete?.minimalDescription)")
        for campaignString in campaignsToDelete! {
            viewModel?.deleteCampaign(campaign: campaignString)
        }
        delegate?.deleteCampaignViewControllerDidFinishDeleting(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        deleteCampaignTableView?.dataSource = self
        deleteCampaignTableView?.delegate = self
        
        //self.campaigns = viewModel!.campaigns
        self.campaignsToDelete = []
        self.deleteCampaignTableView.allowsMultipleSelection = true
        self.deleteCampaignTableView.tableFooterView = UIView(frame: .zero)
        //self.deleteCampaignTableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Helper Methods
    func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Campaign"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    func configureTitle(for cell: UITableViewCell, with campaign: Campaign) {
        let label = cell.viewWithTag(2500) as! UILabel
        if campaign.isCurrent {
            label.text = "\(campaign.title) - (cannot delete current)"
        } else {
            label.text = "\(campaign.title)"
        }
        label.sizeToFit()
    }
}

extension DeleteCampaignViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return (viewModel?.campaigns.count)!
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let myCampaigns = Array(self.campaigns!.values)
        
        configureTitle(for: cell, with: myCampaigns[indexPath.row])
        
        // Don't allow selection of current campaign!!
        if myCampaigns[indexPath.row].isCurrent {
            cell.isUserInteractionEnabled = false
        }
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let myCampaigns = Array(self.campaigns!.values)
        let campaignToDelete = myCampaigns[indexPath.row]
        campaignsToDelete!.append(campaignToDelete.title)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        campaignsToDelete!.remove(at: indexPath.row)
    }
}
