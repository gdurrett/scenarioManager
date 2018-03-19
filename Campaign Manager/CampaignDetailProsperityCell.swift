//
//  CampaignDetailProsperityCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/17/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CampaignDetailProsperityCellDelegate: class {
    func updateCampaignProsperityCount(value: Int)
}

class CampaignDetailProsperityCell: UITableViewCell {

    @IBOutlet weak var campaignDetailProsperityLabel: UILabel!
    
    @IBOutlet weak var campaignDetailProsperityTextLabel: UILabel!
    
    @IBOutlet weak var myStepperOutlet: UIStepper!
    
    @IBAction func modifyProsperityCountAction(_ sender: Any) {
        let value = Int(myStepperOutlet.value)
        delegate?.updateCampaignProsperityCount(value: value)
        myStepperOutlet.value = 0
    }
    
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    weak var delegate: CampaignDetailProsperityCellDelegate?
    
    var item: CampaignDetailViewModelItem? {
        didSet {
            guard let item = item as? CampaignDetailViewModelCampaignProsperityItem else {
                return
            }
            campaignDetailProsperityLabel?.sizeToFit()
            campaignDetailProsperityLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            campaignDetailProsperityLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            let checksText = item.remainingChecksUntilNextLevel == 1 ? "check" : "checks"
            // campaignDetailProsperityLabel?.text = "\(item.level)      \(item.remainingChecksUntilNextLevel) \(checksText) to next level"
            campaignDetailProsperityLabel?.text = "\(item.level)"
            campaignDetailProsperityTextLabel?.sizeToFit()
            campaignDetailProsperityTextLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            campaignDetailProsperityTextLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            campaignDetailProsperityTextLabel?.text = "\(item.remainingChecksUntilNextLevel) \(checksText) to next level"
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
