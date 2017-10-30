//
//  PartyDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/22/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol PartyDetailViewControllerDelegate: class {
    
}
class PartyDetailViewController: UIViewController {

    @IBOutlet weak var partyDetailTableView: UITableView!
    
    @IBAction func selectPartyAction(_ sender: Any) {
    }
    
    @IBAction func deletePartyAction(_ sender: Any) {
    }
    
    @IBAction func createPartyAction(_ sender: Any) {
        
    }
    
    //weak var delegate: PartyDetailViewControllerDelegate!
    
    var viewModel: PartyDetailViewModel!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()

    override func viewDidLoad() {
        super.viewDidLoad()

        // var for toggleSection in viewModel
//        viewModel.reloadSection = { [weak self] (section: Int) in
//            if section == 4 {
//                self?.refreshCurrentParty()
//            } else if section == 5 {
//                self?.refreshEvents()
//            }
//        }
        // Set up observers
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadSelectCharacterViewController), name: NSNotification.Name(rawValue: "showSelectCharacterVC"), object: nil)
        // Set up UITableViewDelegate
        partyDetailTableView?.dataSource = viewModel
        partyDetailTableView?.delegate = viewModel
        
        // Register cells
        partyDetailTableView?.register(PartyDetailNameCell.nib, forCellReuseIdentifier: PartyDetailNameCell.identifier)
        partyDetailTableView?.register(PartyDetailReputationCell.nib, forCellReuseIdentifier: PartyDetailReputationCell.identifier)
        partyDetailTableView?.register(PartyDetailAssignedCampaignCell.nib, forCellReuseIdentifier: PartyDetailAssignedCampaignCell.identifier)
        partyDetailTableView?.register(PartyDetailAssignedCharactersCell.nib, forCellReuseIdentifier: PartyDetailAssignedCharactersCell.identifier)
        partyDetailTableView?.register(PartyDetailAchievementsCell.nib, forCellReuseIdentifier: PartyDetailAchievementsCell.identifier)
        
        // Register headers
        partyDetailTableView?.register(PartyDetailAssignedCampaignHeader.nib, forCellReuseIdentifier: PartyDetailAssignedCampaignHeader.identifier)
        styleUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension PartyDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let item = viewModel.items[indexPath!.section]
        switch item.type {
        case .partyName:
            break
        case .reputation:
            break
        case .assignedCampaign:
            break
        case .characters:
            break
        case .achievements:
            break
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Call updates and refreshes here
        viewModel.updateCurrentParty()
        viewModel.updateReputationValue()
        viewModel.updateAssignedCampaign()
        viewModel.updateAssignedCharacters()
        viewModel.updateAchievements()

        //refreshCurrentParty()
        //refreshReputation()
        //refreshAssignedCharacters()
        //refreshAchievements()
        //refreshAssignedCampaign()
        self.partyDetailTableView.reloadData()
    }
    
    func refreshCurrentParty() {
        DispatchQueue.main.async {
            self.partyDetailTableView.reloadSections([0], with: .none)
        }
    }
    func refreshReputation() {
        DispatchQueue.main.async {
            self.partyDetailTableView.reloadSections([1], with: .none)
        }
    }
    func refreshAssignedCharacters() {
        DispatchQueue.main.async {
            self.partyDetailTableView.reloadSections([3], with: .none)
        }
    }
    func refreshAchievements() {
        DispatchQueue.main.async {
            self.partyDetailTableView.reloadSections([4], with: .none)
        }
    }
    fileprivate func styleUI() {
        self.partyDetailTableView.estimatedRowHeight = 80
        self.partyDetailTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hue: 46/360, saturation: 8/100, brightness: 100/100, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        self.navigationItem.title = "Current Party"
        self.partyDetailTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.partyDetailTableView.backgroundView?.alpha = 0.25
    }
    // MARK: Action Methods
    @objc func loadSelectCharacterViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectCharacterVC = storyboard.instantiateViewController(withIdentifier: "SelectCharacterViewController") as! SelectCharacterViewController
        selectCharacterVC.delegate = viewModel
        selectCharacterVC.availableCharacters = self.viewModel.availableCharacters.value
        selectCharacterVC.viewModel = self.viewModel
        selectCharacterVC.hidesBottomBarWhenPushed = true
        self.navigationController!.present(selectCharacterVC, animated: true, completion: nil)
    }
}
extension PartyDetailViewController: CampaignDetailPartyUpdaterDelegate {
    func reloadTableAfterSetPartyCurrent() {
        if let myTableView = self.partyDetailTableView {
            myTableView.reloadData()
        }
    }
}
extension PartyDetailViewController: SelectCharacterViewControllerReloadDelegate {
    func reloadAfterDidFinishSelecting() {
        if let myTableView = self.partyDetailTableView {
            //self.viewModel.updateAssignedCharacters()
            print("Calling reload?")
            myTableView.reloadData()
        }
    }
}
