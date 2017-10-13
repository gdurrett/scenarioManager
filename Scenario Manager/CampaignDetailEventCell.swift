//
//  CampaignDetailEventCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/9/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailEventCell: UITableViewCell {

    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var eventStatusIcon: UIImageView!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: SeparatedStrings? {
        didSet {
            guard let item = item else {
                return
            }
            eventNameLabel?.sizeToFit()
            eventNameLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            eventNameLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            eventNameLabel?.text = "\(item.rowString!)"
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
