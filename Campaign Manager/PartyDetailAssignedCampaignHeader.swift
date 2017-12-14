//
//  PartyDetailAssignedCampaignHeader.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/23/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class PartyDetailAssignedCampaignHeader: UITableViewCell {

    @IBOutlet weak var partyDetailAssignedCampaignHeaderTitle: UILabel!
    
    @IBOutlet weak var partyDetailAssignedCampaignHeaderBG: UIView!
    
    @IBOutlet weak var getSegment: UISegmentedControl!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        partyDetailAssignedCampaignHeaderBG.backgroundColor = UIColor(hue: 46/360, saturation: 8/100, brightness: 100/100, alpha: 1.0)
        partyDetailAssignedCampaignHeaderTitle.font = fontDefinitions.detailTableViewHeaderFont
        partyDetailAssignedCampaignHeaderTitle.textColor = colorDefinitions.scenarioTitleFontColor
        
        getSegment.layer.borderWidth = 0.0
        getSegment.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Nyala", size: 20.0)!, NSAttributedStringKey.foregroundColor: colorDefinitions.mainTextColor], for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
