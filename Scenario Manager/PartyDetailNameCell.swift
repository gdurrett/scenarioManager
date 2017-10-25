//
//  PartyDetailNameCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/23/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class PartyDetailNameCell: UITableViewCell {

 
    @IBOutlet weak var partyDetailNameLabel: UILabel!
    
    @IBOutlet weak var partyDetailNameTextField: UITextField!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: PartyDetailViewModelItem? {
        didSet {
            guard let item = item as? PartyDetailViewModelPartyNameItem else {
                return
            }
            partyDetailNameLabel?.sizeToFit()
            partyDetailNameLabel?.font = fontDefinitions.detailTableViewTitleFont
            partyDetailNameLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            partyDetailNameLabel?.text = "\(item.name)"
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
