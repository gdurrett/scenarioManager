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
    
    var item: ScenarioDetailViewModelItem? {
        didSet {
            guard let item = item as? ScenarioDetailViewModelScenarioTitleItem else {
                return
            }
            scenarioTitleLabel?.sizeToFit()
            scenarioTitleLabel?.text = item.title
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
