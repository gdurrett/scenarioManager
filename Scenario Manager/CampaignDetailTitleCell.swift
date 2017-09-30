//
//  CampaignDetailTitleCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CampaignDetailTitleCellDelegate {
    func setCampaignActive()
}

class CampaignDetailTitleCell: UITableViewCell {

    @IBOutlet weak var campaignDetailTitleLabel: UILabel!
    
    @IBOutlet weak var campaignDetailTitleTextField: UITextField!
    
    @IBOutlet weak var setCampaignActiveButtonOutlet: UIButton!
    
    @IBAction func setCampaignActiveAction(_ sender: Any) {
        setCampaignActiveButtonOutlet.isEnabled = false
        setCampaignActiveButtonOutlet.setTitle("Active", for: .disabled)
        setCampaignActiveButtonOutlet.setTitleColor(UIColor.gray, for: .disabled)
        delegate?.setCampaignActive()
    }
    
    
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    var delegate: CampaignDetailTitleCellDelegate?
    var isActive: Bool?
    
    var item: CampaignPartyDetailViewModelItem? {
        didSet {
            guard let item = item as? CampaignPartyDetailViewModelCampaignTitleItem else {
                return
            }
            campaignDetailTitleLabel?.sizeToFit()
            campaignDetailTitleLabel?.font = fontDefinitions.detailTableViewTitleFont
            campaignDetailTitleLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            campaignDetailTitleLabel?.text = "\(item.title)"
            
            setCampaignActiveButtonOutlet.titleLabel?.font = fontDefinitions.scenarioSwipeFont
            
            updateButtonLabel()
            
        }
    }
    func updateButtonLabel() {
        if isActive! == true {
            setCampaignActiveButtonOutlet.isEnabled = false
            setCampaignActiveButtonOutlet.setTitle("Active", for: .disabled)
        } else {
            setCampaignActiveButtonOutlet.isEnabled = true
            setCampaignActiveButtonOutlet.setTitle("Set Active", for: .normal)
            setCampaignActiveButtonOutlet.setTitleColor(UIColor.gray, for: .selected)
            setCampaignActiveButtonOutlet.setTitleColor(colorDefinitions.mainTextColor, for: .normal)
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
