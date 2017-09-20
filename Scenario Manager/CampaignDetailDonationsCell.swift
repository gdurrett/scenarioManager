//
//  CampaignDetailDonationsCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/17/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CampaignDetailDonationsCellDelegate {
    func updateCampaignDonationsCount(value: Int)
}

class CampaignDetailDonationsCell: UITableViewCell {

    @IBOutlet weak var campaignDetailDonationsLabel: UILabel! {
        didSet {
            guard let item = item as? CampaignDetailViewModelCampaignDonationsItem else {
                return
            }
            campaignDetailDonationsLabel?.text = "\(item.amount)"
        }
    }
    
    @IBOutlet weak var modifyDonationsCountStepperOutlet: UIStepper!
    
    @IBAction func modifyDonationsCountAction(_ sender: Any) {
        let value = Int(modifyDonationsCountStepperOutlet.value)
        delegate?.updateCampaignDonationsCount(value: value)
        modifyDonationsCountStepperOutlet.value = 0
    }
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var delegate: CampaignDetailDonationsCellDelegate?
    
    var item: CampaignDetailViewModelItem? {
        didSet {
            guard let item = item as? CampaignDetailViewModelCampaignDonationsItem else {
                return
            }
            campaignDetailDonationsLabel?.sizeToFit()
            campaignDetailDonationsLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            campaignDetailDonationsLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            campaignDetailDonationsLabel?.text = "\(item.amount)"
        }
    }
    var isActive: Bool? {
        didSet {
            if isActive == true {
                modifyDonationsCountStepperOutlet.isHidden = false
                modifyDonationsCountStepperOutlet.isEnabled = true
                modifyDonationsCountStepperOutlet.tintColor = colorDefinitions.mainTextColor
            } else {
                modifyDonationsCountStepperOutlet.isEnabled = false
                modifyDonationsCountStepperOutlet.isHidden = true
            }
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}