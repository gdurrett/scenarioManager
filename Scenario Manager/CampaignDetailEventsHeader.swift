//
//  CampaignDetailEventsHeader.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/9/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

// Protocol to let viewModel know segmentedControl state
protocol CampaignDetailEventsHeaderDelegate: class {
    func pressedRoadButton()
    func pressedCityButton()
}
import UIKit

class CampaignDetailEventsHeader: UITableViewCell {

    @IBOutlet weak var campaignDetailEventsHeaderBG: UIView!
    @IBOutlet weak var campaignDetailEventsHeaderTitle: UILabel!

    @IBOutlet weak var getSegment: UISegmentedControl!
    
    @IBAction func pressedRoadButton(_ sender: UIButton) {
    }
    
    @IBAction func pressedCityButton(_ sender: Any) {
    }
    @IBOutlet weak var roadButton: UIButton!
    @IBOutlet weak var cityButton: UIButton!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    func setButtonColorOn(button: UIButton) {
        button.setTitleColor(colorDefinitions.scenarioTitleFontColor, for: .normal)
    }
    func setButtonColorOff(button: UIButton) {
        button.setTitleColor(colorDefinitions.tabBarUnselectedItemTintColor, for: .normal)
    }
    //weak var delegate: CampaignDetailEventsHeaderDelegate?
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        campaignDetailEventsHeaderBG.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        campaignDetailEventsHeaderTitle.font = fontDefinitions.detailTableViewHeaderFont
        campaignDetailEventsHeaderTitle.textColor = colorDefinitions.scenarioTitleFontColor
        
        getSegment.layer.borderWidth = 1.2
        getSegment.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Nyala", size: 20.0)!, NSAttributedStringKey.foregroundColor: colorDefinitions.mainTextColor], for: .normal)
        
        roadButton.titleLabel?.font = fontDefinitions.detailTableViewNonTitleFont
        roadButton.sizeToFit()
        
        cityButton.titleLabel?.font = fontDefinitions.detailTableViewNonTitleFont
        cityButton.sizeToFit()
    }

}
