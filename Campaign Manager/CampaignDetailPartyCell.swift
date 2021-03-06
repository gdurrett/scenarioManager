//
//  CampaignDetailPartyCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/17/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailPartyCell: UITableViewCell {
    
    @IBOutlet weak var campaignDetailPartyLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: SeparatedStrings? {
        didSet {
            guard let item = item else {
                return
            }
            campaignDetailPartyLabel?.sizeToFit()
            campaignDetailPartyLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            campaignDetailPartyLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            campaignDetailPartyLabel?.text = "\(item.rowString!)"
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
