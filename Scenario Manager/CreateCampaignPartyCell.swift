//
//  CreateCampaignPartyCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/3/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CreateCampaignPartyCell: UITableViewCell {

    @IBOutlet weak var createCampaignPartyLabel: UILabel!
    
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        createCampaignPartyLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
