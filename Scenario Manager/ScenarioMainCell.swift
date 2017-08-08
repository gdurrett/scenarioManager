//
//  ScenarioMainCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 7/31/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class ScenarioMainCell: UITableViewCell {

    @IBOutlet weak var scenarioRowIcon: UIImageView!
    

    // Test custom text color for SwipeAction buttons
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        for subview in self.subviews {
            
            for subview2 in subview.subviews {
                
                if (String(describing: subview2).range(of: "UITableViewCellActionButton") != nil) {
                    
                    for view in subview2.subviews {
                        
                        if (String(describing: view).range(of: "UIButtonLabel") != nil) {
                            
                            if let label = view as? UILabel {
                                
                                label.textColor = UIColor.black
                            }
                            
                        }
                    }
                }
            }
        }
        
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
