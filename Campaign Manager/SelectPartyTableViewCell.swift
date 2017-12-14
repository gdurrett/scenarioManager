//
//  SelectPartyTableViewCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/1/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class SelectPartyTableViewCell: UITableViewCell {

    @IBOutlet weak var selectPartyNameLabel: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    func styleCell() {
        self.selectPartyNameLabel.sizeToFit()
        self.selectPartyNameLabel.font = fontDefinitions.detailTableViewTitleFont
        self.selectPartyNameLabel.textColor = colorDefinitions.scenarioTitleFontColor
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
        styleCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
