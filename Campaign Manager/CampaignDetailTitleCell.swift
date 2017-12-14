//
//  CampaignDetailTitleCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CampaignDetailTitleCellDelegate {
    func setCampaignActive(campaign: String)
}

class CampaignDetailTitleCell: UITableViewCell {

    @IBOutlet weak var campaignDetailTitleLabel: UILabel!
    
    @IBOutlet weak var campaignDetailTitleTextField: UITextField!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var delegate: CampaignDetailTitleCellDelegate?
    var isActive: Bool?
    
    var item: CampaignDetailViewModelItem? {
        didSet {
            guard let item = item as? CampaignDetailViewModelCampaignTitleItem else {
                return
            }
            campaignDetailTitleLabel?.sizeToFit()
            campaignDetailTitleLabel?.font = fontDefinitions.detailTableViewTitleFont
            campaignDetailTitleLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            campaignDetailTitleLabel?.text = "\(item.title)"
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
