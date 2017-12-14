//
//  CharacterDetailCharacterTypeCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/5/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CharacterDetailCharacterTypeCell: UITableViewCell {

    @IBOutlet weak var characterDetailCharacterTypeLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: SeparatedAttributedStrings? {
        didSet {
            guard let item = item else {
                return
            }
            characterDetailCharacterTypeLabel?.sizeToFit()
            characterDetailCharacterTypeLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            characterDetailCharacterTypeLabel?.textColor = colorDefinitions.scenarioTitleFontColor
//            characterDetailCharacterTypeLabel.text = ("\(item.characterType)")
            characterDetailCharacterTypeLabel.attributedText = (item.rowString!)
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
