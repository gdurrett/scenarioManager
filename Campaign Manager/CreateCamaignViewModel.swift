//
//  AddCamaignViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/11/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

protocol CreateCampaignViewControllerViewModel {
    var dataModel: DataModel { get }
    var campaign: [String:Campaign] { get }
}
