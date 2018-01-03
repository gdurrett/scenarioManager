//
//  PartyDetailReputationCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/23/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol PartyDetailReputationCellDelegate: class {
    func updatePartyReputationCount(value: Int)
}
class PartyDetailReputationCell: UITableViewCell {

    @IBOutlet weak var partyDetailReputationLabel: UILabel! {
        didSet {
//            guard let item = item as? PartyDetailViewModelPartyReputationItem else {
//                return
//            }
//            partyDetailReputationLabel?.text = "\(item.reputation)"
        }
    }
    
    @IBOutlet weak var myStepperOutlet: UIStepper!
    
    @IBAction func modifyReputationAction(_ sender: Any) {
        let value = Int(myStepperOutlet.value)
        delegate?.updatePartyReputationCount(value: value)
        myStepperOutlet.value = 0
    }
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    weak var delegate: PartyDetailReputationCellDelegate?
    
    var item: PartyDetailViewModelItem? {
        didSet {
            guard let item = item as? PartyDetailViewModelPartyReputationItem else {
                return
            }
            partyDetailReputationLabel?.sizeToFit()
            partyDetailReputationLabel?.font = fontDefinitions.detailTableViewNonTitleFont
            partyDetailReputationLabel?.textColor = colorDefinitions.scenarioTitleFontColor
            partyDetailReputationLabel?.text = "\(item.reputation)    shop price modifier: \(item.modifier)"
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
        myStepperOutlet.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
