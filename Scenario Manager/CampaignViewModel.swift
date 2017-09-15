//
//  CampaignViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/7/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

protocol CampaignViewControllerViewModel {
    var dataModel: DataModel { get }
    var campaigns: Dynamic<[String:Campaign]> { get }
    //var createCampaignViewModel: CreateCampaignViewModelFromModel { get }
}
