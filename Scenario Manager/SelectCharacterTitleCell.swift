//
//  SelectCharacterTitleCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/27/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class SelectCharacterTitleCell: UITableViewCell {
    @IBOutlet weak var selectCharacterTitleCellTitleLabel: UILabel!
    
    @IBOutlet weak var selectCharacterTitleCellCharacterInfo: UILabel!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    // Test custom text color for SwipeAction buttons
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        for subview in self.subviews {
            
            for subview2 in subview.subviews {
                
                if (String(describing: subview2).range(of: "UITableViewCellActionButton") != nil) {
                    
                    for view in subview2.subviews {
                        
                        if (String(describing: view).range(of: "UIButtonLabel") != nil) {
                            
                            if let label = view as? UILabel {
                                
                                label.textColor = colorDefinitions.scenarioSwipeFontColor
                                label.font = fontDefinitions.scenarioSwipeFont
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func styleCell() {
        self.selectCharacterTitleCellTitleLabel.sizeToFit()
        self.selectCharacterTitleCellTitleLabel.font = fontDefinitions.detailTableViewTitleFont
        self.selectCharacterTitleCellTitleLabel.textColor = colorDefinitions.scenarioTitleFontColor
        self.selectCharacterTitleCellCharacterInfo.sizeToFit()
        self.selectCharacterTitleCellCharacterInfo.font = fontDefinitions.scenarioSwipeFont
        self.selectCharacterTitleCellCharacterInfo.textColor = colorDefinitions.scenarioTitleFontColor
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
