//
//  CreateCampaignCharacter1Cell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/28/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CreateCampaignCharacterCell: UITableViewCell {
    
    @IBOutlet weak var createCampaignCharacterLabel: UILabel!
    
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
        createCampaignCharacterLabel.sizeToFit()
        createCampaignCharacterLabel.font = fontDefinitions.detailTableViewNonTitleFont
        createCampaignCharacterLabel.textColor = UIColor.lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
