//
//  CharacterDetailCharacterGoalCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 12/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CharacterDetailCharacterGoalCell: UITableViewCell {

    @IBOutlet weak var characterDetailCharacterGoalLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: CharacterDetailViewModelItem? {
        didSet {
            guard let item = item as? CharacterDetailViewModelCharacterGoalItem else {
                return
            }
            characterDetailCharacterGoalLabel?.sizeToFit()
            characterDetailCharacterGoalLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            characterDetailCharacterGoalLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            characterDetailCharacterGoalLabel.text = ("\(item.characterGoal)")
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
