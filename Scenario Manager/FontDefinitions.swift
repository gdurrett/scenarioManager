//
//  FontDefinitions.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class FontDefinitions {
    
    var scenarioSwipeFont: UIFont {
        get {
            return UIFont(name: "Nyala", size: 20)!
        }
    }
    var detailTableViewTitleFont: UIFont {
        get {
            return UIFont(name: "PirataOne-Regular", size: 30)!
        }
    }
    var detailTableViewNonTitleFont: UIFont {
        get {
            return UIFont(name: "Nyala", size: 24)!
        }
    }
    var detailTableViewHeaderFont: UIFont {
        get {
            return UIFont(name: "Nyala", size: 25)!
        }
    }
}
