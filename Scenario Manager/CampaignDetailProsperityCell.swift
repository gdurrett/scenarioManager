//
//  CampaignDetailProsperityCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/17/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CampaignDetailProsperityCellDelegate {
    func updateCampaignProsperityCount(value: Int)
}

class CampaignDetailProsperityCell: UITableViewCell {

    @IBOutlet weak var campaignDetailProsperityLabel: UILabel! {
        didSet {
            guard let item = item as? CampaignDetailViewModelCampaignProsperityItem else {
                return
            }
            let checksText = item.remainingChecksUntilNextLevel == 1 ? "check" : "checks"
            campaignDetailProsperityLabel?.text = "\(item.level)  (\(item.remainingChecksUntilNextLevel) \(checksText) to next level)"
        }
    }
    
    @IBOutlet weak var myStepperOutlet: UIStepper!
    
    @IBAction func modifyProsperityCountAction(_ sender: Any) {
        let value = Int(myStepperOutlet.value)
        delegate?.updateCampaignProsperityCount(value: value)
        myStepperOutlet.value = 0
    }
    
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var delegate: CampaignDetailProsperityCellDelegate?
    
    var item: CampaignDetailViewModelItem? {
        didSet {
            guard let item = item as? CampaignDetailViewModelCampaignProsperityItem else {
                return
            }
            campaignDetailProsperityLabel?.sizeToFit()
            campaignDetailProsperityLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            campaignDetailProsperityLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            let checksText = item.remainingChecksUntilNextLevel == 1 ? "check" : "checks"
            campaignDetailProsperityLabel?.text = "\(item.level)  (\(item.remainingChecksUntilNextLevel) \(checksText) to next level)"
            
        }
    }
    var isActive: Bool? {
        didSet {
        //modifyProsperityCountStepperOutlet.setBackgroundImage(UIImage(named: "stepperBG.png"), for: .normal)
//            if isActive == true {
//                modifyProsperityCountStepperOutlet.isHidden = false
//                modifyProsperityCountStepperOutlet.isEnabled = true
//                modifyProsperityCountStepperOutlet.tintColor = colorDefinitions.mainTextColor
//            } else {
//                modifyProsperityCountStepperOutlet.isEnabled = false
//                modifyProsperityCountStepperOutlet.isHidden = true
//            }
        }
        
    }
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        myStepperOutlet.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
