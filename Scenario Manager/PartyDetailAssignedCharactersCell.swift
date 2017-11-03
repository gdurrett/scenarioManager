//
//  PartyDetailAssignedCharactersCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/30/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class PartyDetailAssignedCharactersCell: UITableViewCell {
    
    @IBOutlet weak var partyDetailAssignedCharacterLabel: UILabel!
    
    @IBOutlet weak var partyDetailAssignedCharacterInfo: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: SeparatedStrings? {
        didSet {
            guard let item = item else {
                return
            }
            partyDetailAssignedCharacterLabel?.sizeToFit()
            partyDetailAssignedCharacterLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            partyDetailAssignedCharacterLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            partyDetailAssignedCharacterLabel?.text = "\(item.rowString!)"
            partyDetailAssignedCharacterInfo?.sizeToFit()
            partyDetailAssignedCharacterInfo?.font = fontDefinitions.scenarioSwipeFont
            partyDetailAssignedCharacterInfo?.textColor = colorDefinitions.scenarioTitleFontColor
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
