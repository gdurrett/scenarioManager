//
//  CharacterDetailAssignedPartyCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/6/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CharacterDetailAssignedPartyCell: UITableViewCell {

    @IBOutlet weak var characterDetailAssignedPartyLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: CharacterDetailViewModelItem? {
        didSet {
            guard let item = item as? CharacterDetailViewModelAssignedPartyItem else {
                return
            }
            characterDetailAssignedPartyLabel?.sizeToFit()
            characterDetailAssignedPartyLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            characterDetailAssignedPartyLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            characterDetailAssignedPartyLabel.text = ("\(item.partyName)")
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
