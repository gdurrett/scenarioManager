//
//  SelectCampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/1/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol SelectCampaignViewControllerDelegate: class {
    func selectCampaignViewControllerDidCancel(_ controller: SelectCampaignViewController)
    func selectCampaignViewControllerDidFinishSelecting(_ controller: SelectCampaignViewController)
}
class SelectCampaignViewController: UIViewController {
    
    @IBOutlet weak var selectCampaignTableView: UITableView!
    
    @IBOutlet var selectCampaignView: UIView!
    
    @IBAction func selectCampaignCancelAction(_ sender: Any) {
        delegate?.selectCampaignViewControllerDidCancel(self)
    }
    @IBAction func selectCampaignDoneAction(_ sender: Any) {
        if selectedCampaign == nil {
            selectedCampaign = currentCampaign
        }
        delegate?.selectCampaignViewControllerDidFinishSelecting(self)
        reloadDelegate?.reloadAfterDidFinishAdding()
    }
    
    // MARK: Global variables
    var viewModel: CampaignViewModelFromModel? {
        didSet {
            fillUI()
        }
    }
    var selectedIndex: Int = -1
    var selectedCampaign: String?
    weak var delegate: SelectCampaignViewControllerDelegate?
    weak var reloadDelegate: CreateCampaignViewControllerReloadDelegate?
    
    var campaigns: [String:Campaign]!
    var currentCampaign: String!
    let colorDefinitions = ColorDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectCampaignTableView.delegate = self
        selectCampaignTableView.dataSource = self
        selectCampaignTableView?.register(SelectCampaignTitleCell.nib, forCellReuseIdentifier: SelectCampaignTitleCell.identifier)

        viewModel?.updateAvailableCampaigns()
        fillUI()
        styleUI()
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
        self.campaigns = viewModel.campaigns.value
        viewModel.campaigns.bindAndFire { [unowned self] in self.campaigns = $0 }
    }
    fileprivate func styleUI() {
        self.selectCampaignTableView.backgroundColor = colorDefinitions.mainBGColor
//        self.selectCampaignTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
//        self.selectCampaignTableView.backgroundView?.alpha = 0.25
        self.selectCampaignTableView.separatorInset = .zero
    }
    fileprivate func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "SelectCampaignTitleCell"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    fileprivate func configureTitle(for cell: UITableViewCell, with campaign: Campaign) {
        let label = cell.viewWithTag(3000) as! UILabel
        label.text = campaign.title
        label.sizeToFit()
    }
    fileprivate func configureCheckmark(for cell: UITableViewCell, activeStatus: Bool) {
        if activeStatus == true && selectedIndex == -1 {
            cell.accessoryType = .checkmark
        }
    }
}
extension SelectCampaignViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.campaigns!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let myCampaigns = Array(self.campaigns.values)
        configureTitle(for: cell, with: myCampaigns[indexPath.row])
        if(indexPath.row == selectedIndex)
        {
            cell.accessoryType = .checkmark
            selectedCampaign = myCampaigns[indexPath.row].title
        }
        else
        {
            cell.accessoryType = .none
        }
        configureCheckmark(for: cell, activeStatus: myCampaigns[indexPath.row].title == currentCampaign)
        cell.backgroundColor = UIColor.clear
        return cell as! SelectCampaignTitleCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }
}

