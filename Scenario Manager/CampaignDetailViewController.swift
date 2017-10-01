//
//  CampaignDetailViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailViewController: UIViewController {
    
    var viewModel: CampaignDetailViewModel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var currentProsperityCell = UITableViewCell()
    var currentDonationsCell = UITableViewCell()
    var currentTitleCell = UITableViewCell()
    // Dynamics
    var completedGlobalAchievements = [String:Bool]()
    var campaignTitle = String()
    var prosperityLevel = Int()
    var checksToNextLevel = Int()
    
    var headersToUpdate = [Int:UITableViewHeaderFooterView]()
    
    var didSelectNewCampaign = false
    
    @IBOutlet weak var campaignDetailTableView: UITableView!

    @IBAction func selectCampaignAction(_ sender: Any) {
        loadSelectCampaignViewController()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewModel.updateAchievements()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: NSNotification.Name(rawValue: "reloadData"), object: nil)
        
        campaignDetailTableView?.dataSource = self
        campaignDetailTableView?.delegate = self
        
        // Register Cells
        campaignDetailTableView?.register(CampaignDetailTitleCell.nib, forCellReuseIdentifier: CampaignDetailTitleCell.identifier)
        campaignDetailTableView?.register(CampaignDetailProsperityCell.nib, forCellReuseIdentifier: CampaignDetailProsperityCell.identifier)
        campaignDetailTableView?.register(CampaignDetailDonationsCell.nib, forCellReuseIdentifier: CampaignDetailDonationsCell.identifier)
        campaignDetailTableView?.register(CampaignDetailPartyCell.nib, forCellReuseIdentifier: CampaignDetailPartyCell.identifier)
        campaignDetailTableView?.register(CampaignDetailAchievementsCell.nib, forCellReuseIdentifier: CampaignDetailAchievementsCell.identifier)
        
        styleUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CampaignDetailViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CampaignDetailTitleCellDelegate, CampaignDetailProsperityCellDelegate, CampaignDetailDonationsCellDelegate {
    func setCampaignActive() {
        //Nothing
    }
    

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
            if let item = item as? CampaignDetailViewModelCampaignTitleItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailTitleCell.identifier, for: indexPath) as? CampaignDetailTitleCell {
                item.title = campaignTitle
                // Set global title cell to this cell
                currentTitleCell = cell
                // Set text field to hidden until edit is requested
                cell.campaignDetailTitleTextField.isHidden = true
                
                //viewModel?.campaignTitle =
                cell.selectionStyle = .none
                cell.delegate = self
                // Give proper status to isActive button in this cell
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                cell.item = item
                return cell
            }
        case .prosperity:
            if let item = item as? CampaignDetailViewModelCampaignProsperityItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailProsperityCell.identifier, for: indexPath) as? CampaignDetailProsperityCell {
                // Give proper status to isActive button in this cell
                item.level = prosperityLevel
                item.remainingChecksUntilNextLevel = checksToNextLevel
                cell.delegate = self
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                print("I think prosperity is: \(item.level)")
                cell.item = item
                currentProsperityCell = cell
                return cell
            }
        case .donations:
            if let item = item as? CampaignDetailViewModelCampaignDonationsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailDonationsCell.identifier, for: indexPath) as? CampaignDetailDonationsCell {
                // Give proper status to isActive button in this cell
                cell.delegate = self
                cell.isActive = (viewModel.isActiveCampaign == true ? true : false)
                cell.item = item
                currentDonationsCell = cell
                return cell
            }
        case .parties:
            if let item = item as? CampaignDetailViewModelCampaignPartyItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailPartyCell.identifier, for: indexPath) as? CampaignDetailPartyCell {
                //cell.delegate = self
                cell.selectionStyle = .none
                let party = item.names[indexPath.row]
                cell.item = party
                return cell
            }
        case .achievements:
            if let item = item as? CampaignDetailViewModelCampaignAchievementsItem, let cell = tableView.dequeueReusableCell(withIdentifier: CampaignDetailAchievementsCell.identifier, for: indexPath) as? CampaignDetailAchievementsCell {
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
        refreshAchievements()
        viewModel.updateCampaignTitle()
        viewModel.campaignTitle.bindAndFire { [unowned self] in
            self.campaignTitle = $0 }
        refreshCampaignTitle()
        
        viewModel.updateChecksToNextLevel()
        viewModel.checksToNextLevel.bindAndFire { [unowned self] in
            self.checksToNextLevel = $0 }

        viewModel.updateProsperityLevel()
        viewModel.prosperityLevel.bindAndFire { [unowned self] in
            self.prosperityLevel = $0 }
        refreshProsperityLevel()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //refreshAchievements()
        //campaignDetailTableView.reloadData()
    }
    func refreshAchievements() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([4], with: .fade)
        }
    }
    func refreshCampaignTitle() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([0], with: .fade)
        }
    }
    func refreshProsperityLevel() {
        DispatchQueue.main.async {
            self.campaignDetailTableView.reloadSections([1], with: .fade)
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
    // Helper methods
    fileprivate func styleUI() {
        self.campaignDetailTableView.estimatedRowHeight = 80
        self.campaignDetailTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        self.navigationItem.title = ("Campaign Detail")
    }
    // Action methods
    // Need to emulate method from old CampaignViewController, and need to create this selectCampaignVC file (tableview with some selection method)
    fileprivate func loadSelectCampaignViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let selectCampaignVC = storyboard.instantiateViewController(withIdentifier: "SelectCampaignViewController") as! SelectCampaignViewController
        selectCampaignVC.delegate = self
        // Give VC the current campaign so it can set checkmark.
        selectCampaignVC.currentCampaign = viewModel.campaignTitle.value
        selectCampaignVC.viewModel = CampaignViewModelFromModel(withDataModel: viewModel!.dataModel)
        selectCampaignVC.hidesBottomBarWhenPushed = true
        //self.navigationController!.pushViewController(selectCampaignVC, animated: true)
        self.navigationController!.present(selectCampaignVC, animated: true, completion: nil)
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
        self.campaignDetailTableView.reloadData()
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
    func setCampaignActive(campaign: String) {
        self.viewModel.setCampaignActive(campaign: campaign)
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
extension CampaignDetailViewController: SelectCampaignViewControllerDelegate {
    func selectCampaignViewControllerDidCancel(_ controller: SelectCampaignViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func selectCampaignViewControllerDidFinishSelecting(_ controller: SelectCampaignViewController) {
        didSelectNewCampaign = true
        let campaignTitle = controller.selectedCampaign!
        //viewModel.setCampaignActive(campaign: campaignTitle)
        setCampaignActive(campaign: campaignTitle)
        controller.dismiss(animated: true, completion: nil)
    }
}
