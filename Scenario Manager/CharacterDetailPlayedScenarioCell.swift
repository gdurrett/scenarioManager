//
//  CharacterDetailPlayedScenarioCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/8/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CharacterDetailPlayedScenarioCell: UITableViewCell {

    @IBOutlet weak var characterDetailPlayedScenarioTitleLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var title: String? {
        didSet {
            characterDetailPlayedScenarioTitleLabel?.sizeToFit()
            characterDetailPlayedScenarioTitleLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            characterDetailPlayedScenarioTitleLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            characterDetailPlayedScenarioTitleLabel?.text = "\(title!)"
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
