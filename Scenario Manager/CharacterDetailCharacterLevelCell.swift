//
//  CharacterDetailCharacterLevelCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/6/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CharacterDetailCharacterLevelCellDelegate: class {
    func incrementCharacterLevel(value: Int)
}
class CharacterDetailCharacterLevelCell: UITableViewCell {

    @IBOutlet weak var characterDetailCharacterLevelLabel: UILabel!
    
    @IBOutlet weak var myStepperOutlet: UIStepper!
    
    @IBAction func modifyLevelAction(_ sender: Any) {
        let value = Int(myStepperOutlet.value)
        print("In cell, steppervalue is: \(value)")
        delegate?.incrementCharacterLevel(value: value)
        myStepperOutlet.value = 0
    }
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    weak var delegate: CharacterDetailCharacterLevelCellDelegate?
    
    var item: CharacterDetailViewModelItem? {
        didSet {
            guard let item = item as? CharacterDetailViewModelCharacterLevelItem else {
                return
            }
            characterDetailCharacterLevelLabel?.sizeToFit()
            characterDetailCharacterLevelLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            characterDetailCharacterLevelLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            characterDetailCharacterLevelLabel.text = ("\(item.level)")
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
        myStepperOutlet.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
