//
//  CharacterDetailNameCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/5/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CharacterDetailCharacterNameCell: UITableViewCell {

    @IBOutlet weak var characterDetailNameLabel: UILabel!
    
    @IBOutlet weak var characterDetailStatusLabel: UILabel!
    
    @IBOutlet weak var characterDetailNameTextField: UITextField!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    //var delegate: CharacterDetailNameCellDelegate?
    
    var item: CharacterDetailViewModelItem? {
        didSet {
            guard let item = item as? CharacterDetailViewModelCharacterNameItem else {
                return
            }
            characterDetailNameLabel?.sizeToFit()
            characterDetailNameLabel?.font = fontDefinitions.detailTableViewTitleFont
            characterDetailNameLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            characterDetailNameLabel?.text = "\(item.name)"
            characterDetailStatusLabel?.sizeToFit()
            characterDetailStatusLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            characterDetailStatusLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            characterDetailStatusLabel?.text = "\(item.status)"
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
