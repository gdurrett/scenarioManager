//
//  LocationInfoCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/31/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class LocationInfoCell: UITableViewCell {
    
    @IBOutlet weak var locationInfoLabel: UILabel!
    
    var item: ScenarioDetailViewModelItem? {
        didSet {
            guard let item = item as? ScenarioDetailViewModelScenarioLocationItem else {
                return
            }
            locationInfoLabel?.font = UIFont(name: "Nyala", size: 22)
            locationInfoLabel?.text = item.location
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
