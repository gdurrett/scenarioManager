//
//  CampaignDetailDonationsCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/17/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailDonationsCell: UITableViewCell {

    @IBOutlet weak var campaignDetailDonationLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: CampaignDetailViewModelItem? {
        didSet {
            guard let item = item as? CampaignDetailViewModelCampaignDonationsItem else {
                return
            }
            campaignDetailDonationLabel?.sizeToFit()
            campaignDetailDonationLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            campaignDetailDonationLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            campaignDetailDonationLabel?.text = "\(item.amount)"
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
