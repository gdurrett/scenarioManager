//
//  UnlocksInfoCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/26/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class UnlocksInfoCell: UITableViewCell, LockOrUnlockCellType {

    @IBOutlet weak var unlocksInfoLabel: UILabel?
    
    var item: ScenarioNumberAndTitle? {
        didSet {
            guard let item = item else {
                return
            }
            
            unlocksInfoLabel?.text = "\(item.number!) - \(item.title!)"
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
