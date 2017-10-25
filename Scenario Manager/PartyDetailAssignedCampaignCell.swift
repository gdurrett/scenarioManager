//
//  PartyDetailAssignedCampaignCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/23/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class PartyDetailAssignedCampaignCell: UITableViewCell {

    @IBOutlet weak var partyDetailAssignedCampaignLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: String? {
        didSet {
            guard let item = item else {
                return
            }
            partyDetailAssignedCampaignLabel?.sizeToFit()
            partyDetailAssignedCampaignLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            partyDetailAssignedCampaignLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            partyDetailAssignedCampaignLabel?.text = "\(item)"
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
