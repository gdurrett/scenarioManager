//
//  SelectPartyViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/1/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol SelectPartyViewControllerDelegate: class {
    func selectPartyViewControllerDidCancel(_ controller: SelectPartyViewController)
    func selectPartyViewControllerDidFinishSelecting(_ controller: SelectPartyViewController)
}
class SelectPartyViewController: UIViewController {
    
    @IBOutlet weak var selectPartyTableView: UITableView!
    
    @IBOutlet var selectPartyView: UIView!
    
    @IBAction func selectPartyCancelAction(_ sender: Any) {
        delegate?.selectPartyViewControllerDidCancel(self)
    }
    @IBAction func selectPartyDoneAction(_ sender: Any) {
        if selectedParty == nil {
            selectedParty = currentParty
        }
        delegate?.selectPartyViewControllerDidFinishSelecting(self)
    }
    // MARK: Global variables
    var viewModel: PartyDetailViewModel? {
        didSet {
            fillUI()
            self.currentParty = viewModel!.currentParty.value
        }
    }
    weak var delegate: SelectPartyViewControllerDelegate?
    var assignedParties: [Party]?
    var selectedIndex: Int = -1
    var selectedParty: Party?
    var currentParty: Party!
    let colorDefinitions = ColorDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectPartyTableView.delegate = self
        selectPartyTableView.dataSource = self
        
        selectPartyTableView.register(SelectPartyTableViewCell.nib, forCellReuseIdentifier: SelectPartyTableViewCell.identifier)
        
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
        self.assignedParties = viewModel.assignedParties.value
    }
    fileprivate func styleUI() {
        self.selectPartyView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.selectPartyTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.selectPartyTableView.backgroundView?.alpha = 0.25
        self.selectPartyTableView.separatorInset = .zero
    }
    fileprivate func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "SelectPartyTableViewCell"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    fileprivate func configureTitle(for cell: UITableViewCell, with party: Party) {
        let label = cell.viewWithTag(4000) as! UILabel
        label.text = party.name
        label.sizeToFit()
    }
    fileprivate func configureCheckmark(for cell: UITableViewCell, activeStatus: Bool) {
        if activeStatus == true && selectedIndex == -1 {
            cell.accessoryType = .checkmark
        }
    }
}
extension SelectPartyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assignedParties!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        let myParties = self.assignedParties
        configureTitle(for: cell, with: myParties![indexPath.row])
        if(indexPath.row == selectedIndex)
        {
            cell.accessoryType = .checkmark
            selectedParty = myParties![indexPath.row]
        }
        else
        {
            cell.accessoryType = .none
        }
        configureCheckmark(for: cell, activeStatus: myParties![indexPath.row] == currentParty)
        cell.backgroundColor = UIColor.clear
        return cell as! SelectPartyTableViewCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //
    }
}
