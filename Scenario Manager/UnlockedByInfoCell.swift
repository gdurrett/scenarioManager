//
//  UnlockedByInfoCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/26/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class UnlockedByInfoCell: UITableViewCell {

    @IBOutlet weak var unlockedByInfoLabel: UILabel?
    
    var item: ScenarioNumberAndTitle? {
        didSet {
            guard let item = item else {
                return
            }
            unlockedByInfoLabel?.text = "\(item.number!) - \(item.title!)"
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
