//
//  RewardsInfoCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/30/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class RewardsInfoCell: UITableViewCell {
    
    @IBOutlet weak var rewardsInfoLabel: UILabel!
    
    var item: SeparatedAttributedStrings? {
        didSet {
            guard let item = item else {
                return
            }
            rewardsInfoLabel?.font = UIFont(name: "Nyala", size: 22)
            rewardsInfoLabel?.attributedText = (item.rowString!)
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
