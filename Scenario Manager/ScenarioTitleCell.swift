//
//  ScenarioTitleCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/26/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class ScenarioTitleCell: UITableViewCell {

    @IBOutlet weak var scenarioTitleLabel: UILabel?
    
    @IBOutlet weak var scenarioStatusIcon: UIImageView!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: ScenarioDetailViewModelItem? {
        didSet {
            guard let item = item as? ScenarioDetailViewModelScenarioTitleItem else {
                return
            }
            scenarioTitleLabel?.sizeToFit()
            scenarioTitleLabel?.font = fontDefinitions.detailTableViewTitleFont
            //scenarioTitleLabel?.font = UIFont(name: "PirataOne-Regular", size: 30)
            scenarioTitleLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            scenarioTitleLabel?.text = "\(item.number)) \(item.title)"
            scenarioStatusIcon.image = item.statusIcon
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
