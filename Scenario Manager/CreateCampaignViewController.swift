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
class CreateCampaignViewController: UIViewController {

    var viewModel: CreateCampaignViewModelFromModel? {
        didSet {
            //
        }
    }
    weak var delegate: CreateCampaignViewControllerDelegate?
    var cellsArray = [UITableViewCell]()
    var newCampaign = Campaign(title: "", parties: [], achievements: [:], prosperityCount: 0, sanctuaryDonations: 0, events: [], isUnlocked: [], requirementsMet: [], isCompleted: [], isCurrent: true)
    var chosenCharactersSoFar = [String]()
    
    @IBOutlet weak var createCampaignView: UIView!
    
    @IBOutlet weak var createCampaignTableView: UITableView!

    @IBAction func save(_ sender: Any) {
        for cell in cellsArray {
            if let myCell = cell as? CreateCampaignTitleCell {
                 newCampaign.title = myCell.campaignTitleTextField.text!
            }
            if let myCell = cell as? CreateCampaignCharacterCell {
                if myCell.createCampaignCharacterTextField.text != "" {
                    newCampaign.parties?.append ((viewModel?.parties[myCell.createCampaignCharacterTextField.text!])!)
                }
            }
        }
        //Don't return duplicates
        newCampaign.parties? = Array(Set(newCampaign.parties!))
        // Code to give new campaign data back to viewModel
        print("Would be giving back \(newCampaign.parties!) to viewModel")
        viewModel?.createCampaign(title: newCampaign.title, parties: newCampaign.parties!)
        delegate?.createCampaignViewControllerDidFinishAdding(self)
    }
    @IBAction func cancel(_ sender: Any) {
        print("Cancel tapped")
        delegate?.createCampaignViewControllerDidCancel(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCampaignTableView?.dataSource = self
        createCampaignTableView?.delegate = self
        createCampaignTableView?.estimatedRowHeight = 100
        createCampaignTableView?.rowHeight = UITableViewAutomaticDimension
        
        createCampaignTableView?.register(CreateCampaignTitleCell.nib, forCellReuseIdentifier: CreateCampaignTitleCell.identifier)
        createCampaignTableView?.register(CreateCampaignCharacterCell.nib, forCellReuseIdentifier: CreateCampaignCharacterCell.identifier)
        
        createCampaignTableView?.tableFooterView = UIView(frame: .zero)
        createCampaignTableView?.separatorStyle = .none
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CreateCampaignViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Temporary
        return (viewModel?.numberOfSections)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Temporary
        let sectionType = viewModel!.sections[section]
        switch sectionType {
        case .Title:
            return 1
        case .Parties:
            return (viewModel?.parties.count)! == 0 ? 1 : (viewModel?.parties.count)!
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = viewModel!.sections[indexPath.section]
        var tableViewCell: UITableViewCell
        
        switch sectionType {
        case .Title:
            let viewModel = CreateCampaignTitleCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignTitleCell.identifier) as! CreateCampaignTitleCell
            cell.configure(withViewModel: viewModel)
            tableViewCell = cell
            cellsArray.append(cell)
        case .Parties:
            let viewModel = self.viewModel
            let cell = tableView.dequeueReusableCell(withIdentifier: CreateCampaignCharacterCell.identifier) as! CreateCampaignCharacterCell
            cell.configure(withViewModel: viewModel!)
            tableViewCell = cell
            cellsArray.append(cell)
            //cell.addSubview(cell.createCampaignCharacterPicker)
            cell.createCampaignCharacterPicker.reloadAllComponents()
        }
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = viewModel!.sections[section]
        switch sectionType {
        case .Title:
            return "Name your new campaign"
        case .Parties:
            return "Add parties"
        }
    }
}
