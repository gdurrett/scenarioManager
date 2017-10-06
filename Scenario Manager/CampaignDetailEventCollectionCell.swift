//
//  CampaignDetailEventCollectionCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/4/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailEventCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var campaignDetailEventCollectionCellLabel: UILabel!
    
    @IBOutlet weak var campaignDetailEventCollectionCellTextField: UITextField!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: String? {
        didSet {
            campaignDetailEventCollectionCellLabel.font = fontDefinitions.detailTableViewNonTitleFont
            campaignDetailEventCollectionCellLabel.textColor = colorDefinitions.mainTextColor
            campaignDetailEventCollectionCellLabel.backgroundColor = UIColor.clear
            campaignDetailEventCollectionCellLabel.text = (item)
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
        //self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:))))
    }
}
