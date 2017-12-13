//
//  CampaignDetailAvailableTypeCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 12/11/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailAvailableTypeCell: UITableViewCell {

    @IBOutlet weak var campaignDetailAvailableTypeLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: SeparatedAttributedStrings? {
        didSet {
            guard let item = item else {
                return
            }
            campaignDetailAvailableTypeLabel?.sizeToFit()
            campaignDetailAvailableTypeLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            campaignDetailAvailableTypeLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            campaignDetailAvailableTypeLabel.attributedText = (item.rowString!)
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
