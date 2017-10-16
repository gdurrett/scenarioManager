//
//  CampaignDetailPartiesHeader.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailPartiesHeader: UITableViewCell {

    @IBOutlet weak var campaignDetailPartiesHeaderBG: UIView!
    
    @IBOutlet weak var campaignDetailPartiesHeaderTitle: UILabel!
    
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
        campaignDetailPartiesHeaderBG.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        campaignDetailPartiesHeaderTitle.font = fontDefinitions.detailTableViewHeaderFont
        campaignDetailPartiesHeaderTitle.textColor = colorDefinitions.scenarioTitleFontColor
        
        getSegment.layer.borderWidth = 1.2
        getSegment.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Nyala", size: 20.0)!, NSAttributedStringKey.foregroundColor: colorDefinitions.mainTextColor], for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
