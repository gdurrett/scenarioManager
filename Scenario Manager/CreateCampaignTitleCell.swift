//
//  CreateCampaignTitleCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/8/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CreateCampaignTitleCell: UITableViewCell {
    
    @IBOutlet weak var campaignTitleTextField: UITextField!
    
    func configure(withViewModel viewModel: CreateCampaignTitleCellViewModel) {
        campaignTitleTextField.placeholder = viewModel.campaignTitleTextFieldPlaceholder
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
