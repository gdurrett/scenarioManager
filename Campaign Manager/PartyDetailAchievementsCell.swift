//
//  PartyDetailAchievementsCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/27/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class PartyDetailAchievementsCell: UITableViewCell {

    @IBOutlet weak var partyDetailAchievementsLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: SeparatedStrings? {
        didSet {
            guard let item = item else {
                return
            }
            partyDetailAchievementsLabel?.sizeToFit()
            partyDetailAchievementsLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            partyDetailAchievementsLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            partyDetailAchievementsLabel?.text = "\(item.rowString!)"
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
