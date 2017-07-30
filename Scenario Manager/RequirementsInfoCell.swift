//
//  RequirementsInfoCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/30/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class RequirementsInfoCell: UITableViewCell {

    @IBOutlet weak var requirementsInfoLabel: UILabel!
    var item: SeparatedStrings? {
        didSet {
            guard let item = item else {
                return
            }
            
            requirementsInfoLabel?.text = "\(item.rowString!)"
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
