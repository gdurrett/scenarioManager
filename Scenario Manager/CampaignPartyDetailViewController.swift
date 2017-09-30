//
//  CampaignPartyDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/30/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignPartyDetailViewController: UIViewController {

    var viewModel: CampaignPartyDetailViewModel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var currentProsperityCell = UITableViewCell()
    var currentDonationsCell = UITableViewCell()
    var currentTitleCell = UITableViewCell()
    var completedGlobalAchievements = [String:Bool]()
    var headersToUpdate = [Int:UITableViewHeaderFooterView]()
    
    @IBOutlet weak var campaignPartyDetailTableView: UITableView!
    
    @IBAction func createCampaignAction(_ sender: Any) {
        loadCreateCampaignViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        campaignPartyDetailTableView?.dataSource = self
        campaignPartyDetailTableView?.delegate = self
        campaignPartyDetailTableView?.estimatedRowHeight = 80
        campaignPartyDetailTableView?.rowHeight = UITableViewAutomaticDimension
        // Register Cells
        campaignPartyDetailTableView?.register(CampaignDetailTitleCell.nib, forCellReuseIdentifier: CampaignDetailTitleCell.identifier)
        campaignPartyDetailTableView?.register(CampaignDetailProsperityCell.nib, forCellReuseIdentifier: CampaignDetailProsperityCell.identifier)
        campaignPartyDetailTableView?.register(CampaignDetailDonationsCell.nib, forCellReuseIdentifier: CampaignDetailDonationsCell.identifier)
        campaignPartyDetailTableView?.register(CampaignDetailPartyCell.nib, forCellReuseIdentifier: CampaignDetailPartyCell.identifier)
        campaignPartyDetailTableView?.register(CampaignDetailAchievementsCell.nib, forCellReuseIdentifier: CampaignDetailAchievementsCell.identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
extension CampaignPartyDetailViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CampaignDetailTitleCellDelegate, CampaignDetailProsperityCellDelegate, CampaignDetailDonationsCellDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Got to numberOfRowsInSection:\(viewModel.items[section].rowCount)")
        viewModel.updateAchievements()
        if viewModel.items[section].type == .achievements {
            return self.completedGlobalAchievements.count
        } else {
            return viewModel.items[section].rowCount
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.section]
        
        switch item.type {
        case .campaignTitle:
            if let item = item as? CampaignPartyDetailViewModelCampaignTitleItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailTitleCell.identifier, for: indexPath) as? CampaignDetailTitleCell {
                // Set global title cell to this cell
                currentTitleCell = cell
                // Set text field to hidden until edit is requested
                cell.campaignDetailTitleTextField.isHidden = true
                
                viewModel?.campaignTitle = item.title
                cell.selectionStyle = .none
                cell.delegate = self
                // Give proper status to isActive button in this cell
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                cell.item = item
                return cell
            }
        case .prosperity:
            if let item = item as? CampaignPartyDetailViewModelCampaignProsperityItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailProsperityCell.identifier, for: indexPath) as? CampaignDetailProsperityCell {
                // Give proper status to isActive button in this cell
                cell.delegate = self
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                print("I think prosperity is: \(item.level)")
                cell.item = item
                currentProsperityCell = cell
                return cell
            }
        case .donations:
            if let item = item as? CampaignPartyDetailViewModelCampaignDonationsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailDonationsCell.identifier, for: indexPath) as? CampaignDetailDonationsCell {
                // Give proper status to isActive button in this cell
                cell.delegate = self
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                cell.item = item
                currentDonationsCell = cell
                return cell
            }
        case .parties:
            if let item = item as? CampaignPartyDetailViewModelCampaignPartyItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailPartyCell.identifier, for: indexPath) as? CampaignDetailPartyCell {
                //cell.delegate = self
                cell.selectionStyle = .none
                let party = item.names[indexPath.row]
                cell.item = party
                return cell
            }
        case .achievements:
            if let item = item as? CampaignPartyDetailViewModelCampaignAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailAchievementsCell.identifier, for: indexPath) as? CampaignDetailAchievementsCell {
                var achievement = SeparatedStrings(rowString: "")
                if viewModel.isActiveCampaign == true {
                    print("Showing active")
                    let tempAch = Array(self.completedGlobalAchievements.keys)
                    var achNames = [SeparatedStrings]()
                    for ach in tempAch {
                        achNames.append(SeparatedStrings(rowString: ach))
                    }
                    achievement = achNames[indexPath.row]
                } else {
                    print("Showing inactive")
                    achievement = item.achievements[indexPath.row]
                }
                cell.selectionStyle = .none
                cell.item = achievement
                return cell
            }
            //        case .events:
            //            break
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        let item = viewModel.items[indexPath!.section]
        
        switch item.type {
            
        case .prosperity:
            print("I selected a prosperity row")
        case .donations:
            print("I selected a donations row")
        case .achievements:
            break
        case .campaignTitle:
            break
        case .parties:
            break
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        //UIView.setAnimationsEnabled(true)
        
        //self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.updateAchievements()
        viewModel.completedGlobalAchievements.bindAndFire { [unowned self] in self.completedGlobalAchievements = $0 }
        print(completedGlobalAchievements) //.filter { $0.value != false && $0.key != "None" && $0.key != "OR" })
        refreshAchievements()
        //let indexes = (0..<completedGlobalAchievements.count).map { IndexPath(row: $0, section: 4) }
        //let sectionIndex = IndexSet(integer: 4)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //refreshAchievements()
        //campaignDetailTableView.reloadData()
    }
    func refreshAchievements() {
        DispatchQueue.main.async {
            self.campaignPartyDetailTableView.reloadSections([4], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.items[section].sectionTitle
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.textLabel?.font = fontDefinitions.detailTableViewHeaderFont
        header?.textLabel?.textColor = colorDefinitions.mainTextColor
        header?.tintColor = colorDefinitions.detailTableViewHeaderTintColor
        headersToUpdate[section] = header
        // Test custom edit button in header view (if active campaign)
        createSectionButton(forSection: section, inHeader: header!)
    }
    // Create section button
    func createSectionButton(forSection section: Int, inHeader header: UITableViewHeaderFooterView) {
        
        let myCell = currentTitleCell as! CampaignDetailTitleCell
        
        if myCell.isActive == true {
            print("We are active")
            let button = UIButton(frame: CGRect(x: 330, y: 14, width: 25, height: 25))  // create button
            button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
            
            let itemType = viewModel.items[section].type
            
            switch itemType {
                
            case .prosperity:
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .donations:
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.showUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .achievements:
                break
            case .campaignTitle:
                button.isEnabled = true
                button.addTarget(self, action: #selector(self.enableTitleTextField(_:)), for: .touchUpInside)
                header.addSubview(button)
            case .parties:
                break
            }
        }
    }
    // Test function for section button
    @objc func enableTitleTextField(_ sender: UIButton) {
        let myCell = currentTitleCell as! CampaignDetailTitleCell
        let myTextField = myCell.campaignDetailTitleTextField!
        myTextField.delegate = self
        let oldText = myCell.campaignDetailTitleLabel.text
        myTextField.text = oldText
        myTextField.font = fontDefinitions.detailTableViewTitleFont
        myTextField.becomeFirstResponder()
        myTextField.selectedTextRange = myCell.campaignDetailTitleTextField.textRange(from: myCell.campaignDetailTitleTextField.beginningOfDocument, to: myCell.campaignDetailTitleTextField.endOfDocument)
        myCell.campaignDetailTitleLabel.isHidden = true
        myTextField.isHidden = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let myCell = currentTitleCell as! CampaignDetailTitleCell
        let myTextField = myCell.campaignDetailTitleTextField!
        myTextField.delegate = self
        myTextField.isHidden = true
        myCell.campaignDetailTitleLabel.isHidden = false
    }
    func activateStepper(_ sender: UIButton) {
        
    }
    @objc func showUIStepperInCampaignProsperityCell(_ button: UIButton) {
        button.setImage(UIImage(named: "icons8-Edit-40_selected"), for: .normal)
        let myCell = currentProsperityCell as! CampaignDetailProsperityCell
        myCell.myStepperOutlet.isHidden = false
        myCell.myStepperOutlet.isEnabled = true
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isEnabled = true
        button.addTarget(self, action: #selector(self.hideUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
    }
    @objc func showUIStepperInCampaignDonationsCell(_ button: UIButton) {
        button.setImage(UIImage(named: "icons8-Edit-40_selected"), for: .normal)
        let myCell = currentDonationsCell as! CampaignDetailDonationsCell
        myCell.myStepperOutlet.isHidden = false
        myCell.myStepperOutlet.isEnabled = true
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isEnabled = true
        button.addTarget(self, action: #selector(self.hideUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
    }
    @objc func hideUIStepperInCampaignProsperityCell(_ button: UIButton) {
        let myCell = currentProsperityCell as! CampaignDetailProsperityCell
        myCell.myStepperOutlet.isHidden = true
        myCell.myStepperOutlet.isEnabled = false
        button.isSelected = false
        button.addTarget(self, action: #selector(self.showUIStepperInCampaignProsperityCell(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
    }
    @objc func hideUIStepperInCampaignDonationsCell(_ button: UIButton) {
        let myCell = currentDonationsCell as! CampaignDetailDonationsCell
        myCell.myStepperOutlet.isHidden = true
        myCell.myStepperOutlet.isEnabled = false
        myCell.myStepperOutlet.tintColor = colorDefinitions.mainTextColor
        button.isSelected = false
        button.addTarget(self, action: #selector(self.showUIStepperInCampaignDonationsCell(_:)), for: .touchUpInside)
        button.setImage(UIImage(named: "icons8-Edit-40"), for: .normal)
    }
    // Selector method to reload tableview data when changes made in other VCs: doesn't work
    @objc func reloadData() {
        print("Are we calling reloadData?")
        viewModel.updateAchievements()
        viewModel.completedGlobalAchievements.bindAndFire { [unowned self] in self.completedGlobalAchievements = $0 }
        //self.viewModel = CampaignDetailViewModel(withCampaign: (self.viewModel.campaign))
        self.campaignPartyDetailTableView.reloadData()
    }
    // Delegate methods for textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let myCell = currentTitleCell as! CampaignDetailTitleCell
        let myLabel = myCell.campaignDetailTitleLabel
        let oldTitle = myLabel!.text!
        if textField.text != "" {
            myLabel?.text = textField.text
            textField.isHidden = true
            viewModel.renameCampaignTitle(oldTitle: oldTitle, newTitle: textField.text!)
        }
        myLabel?.isHidden = false
        return true
    }
    
    // Delegate methods for custom campaign cells
    func updateCampaignProsperityCount(value: Int) {
        let (level, count) = (self.viewModel.updateProsperityCount(value: value))
        let remainingChecks = self.viewModel.getRemainingChecksUntilNextLevel(level: level, count: count)
        let checksText = remainingChecks > 1 ? "checks" : "check"
        if let cell = currentProsperityCell as? CampaignDetailProsperityCell {
            cell.campaignDetailProsperityLabel.text = "\(level) (\(remainingChecks) \(checksText) to next level)"
        }
    }
    func updateCampaignDonationsCount(value: Int) {
        let amount = self.viewModel.updateCampaignDonationsCount(value: value)
        if let cell = currentDonationsCell as? CampaignDetailDonationsCell {
            cell.campaignDetailDonationsLabel.text = "\(amount)"
        }
    }
    func setCampaignActive() {
        self.viewModel.setCampaignActive()
        if let cell = currentProsperityCell as? CampaignDetailProsperityCell {
            cell.isActive = true
        }
        if let cell = currentDonationsCell as? CampaignDetailDonationsCell {
            cell.isActive = true
        }
        if let cell = currentTitleCell as? CampaignDetailTitleCell {
            cell.isActive = true
        }
        for (section, header) in headersToUpdate {
            print(section, header.textLabel!.text!)
            createSectionButton(forSection: section, inHeader: header)
        }
    }
}
extension CampaignPartyDetailViewController: CreateCampaignViewControllerDelegate {
    // Delegate methods for CreateCampaignViewController
    func createCampaignViewControllerDidCancel(_ controller: CreateCampaignViewController) {
        print("Did we get back here to cancel?")
        controller.navigationController?.popViewController(animated: true)
    }
    func createCampaignViewControllerDidFinishAdding(_ controller: CreateCampaignViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
}
