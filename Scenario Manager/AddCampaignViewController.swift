//
//  AddCampaignViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol AddCampaignViewControllerDelegate: class {
    func addCampaignViewControllerDidCancel(_ controller: AddCampaignViewController)
    func addCampaignViewControllerDidFinishAdding(_ controller: AddCampaignViewController)
}
class AddCampaignViewController: UIViewController {

    var viewModel: AddCampaignViewModelFromModel? {
        didSet {
            //
        }
    }
    weak var delegate: AddCampaignViewControllerDelegate?
    var cellsArray = [UITableViewCell]()
    var newCampaign = Campaign(title: "", isUnlocked: [], requirementsMet: [], isCompleted: [], achievements: [:], isCurrent: true, characters: [])
    
    @IBOutlet weak var addCampaignView: UIView!
    
    @IBOutlet weak var addCampaignTableView: UITableView!

    @IBAction func save(_ sender: Any) {
        for cell in cellsArray {
            if let myCell = cell as? AddCampaignTitleCell {
                 newCampaign.title = myCell.campaignTitleTextField.text!
            }
//            if let myCell = cell as? AddCampaignCharacterCell {
//                newCampaign.characters?.append(<#T##newElement: Character##Character#>) myCell.campaignCharacterTextField.text!
//            }
        }
        print ("We got \(newCampaign.title) back!")
        // Code to give new campaign data back to viewModel
        //viewModel?.addCampaign(title: ())
    }
    @IBAction func cancel(_ sender: Any) {
        print("Cancel tapped")
        delegate?.addCampaignViewControllerDidCancel(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCampaignTableView?.dataSource = self
        addCampaignTableView?.delegate = self
        addCampaignTableView?.estimatedRowHeight = 100
        addCampaignTableView?.rowHeight = UITableViewAutomaticDimension
        
        addCampaignTableView?.register(AddCampaignTitleCell.nib, forCellReuseIdentifier: AddCampaignTitleCell.identifier)
        addCampaignTableView?.register(AddCampaignCharacterCell.nib, forCellReuseIdentifier: AddCampaignCharacterCell.identifier)
        
        //addCampaignTableView.allowsSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddCampaignViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Temporary
        return (viewModel?.numberOfSections)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Temporary
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = viewModel!.sections[indexPath.section]
        var tableViewCell: UITableViewCell
        
        switch sectionType {
        case .Title:
            let viewModel = AddCampaignTitleCellViewModel()
            let cell = tableView.dequeueReusableCell(withIdentifier: AddCampaignTitleCell.identifier) as! AddCampaignTitleCell
            cell.configure(withViewModel: viewModel)
            tableViewCell = cell
            cellsArray.append(cell)
        case .Characters:
            let viewModel = self.viewModel
            let cell = tableView.dequeueReusableCell(withIdentifier: AddCampaignCharacterCell.identifier) as! AddCampaignCharacterCell
            cell.configure(withViewModel: viewModel!)
            tableViewCell = cell
            cellsArray.append(cell)
            //cell.addSubview(cell.addCampaignCharacterPicker)
            cell.addCampaignCharacterPicker.reloadAllComponents()
        }
        return tableViewCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //
    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let sectionType = viewModel!.sections[indexPath.section]
//
//        switch sectionType {
//        case .Title:
//            let cell = tableView.dequeueReusableCell(withIdentifier: AddCampaignTitleCell.identifier) as! AddCampaignTitleCell
//            campaignTitle = cell.campaignTitleTextField.text!
//            print("Get here?")
//        case .Characters:
//            let cell = tableView.dequeueReusableCell(withIdentifier: AddCampaignCharacterCell.identifier) as! AddCampaignCharacterCell
//            campaignCharacters.append(cell.campaignCharacterTextField.text!)
//            print("Get here too?")
//        }
//    }
}
//}
