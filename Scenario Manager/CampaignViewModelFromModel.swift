//
//  CampaignViewModelFromModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/13/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class CampaignViewModelFromModel: NSObject, CampaignViewControllerViewModel {
    
    var dataModel: DataModel
    var campaigns: Dynamic<[String:Campaign]>
    var createCampaignViewModel: CreateCampaignViewModelFromModel
    var selectedCampaign: Campaign?
    
    // MARK: Init
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.campaigns = Dynamic(dataModel.campaigns)
        self.createCampaignViewModel = CreateCampaignViewModelFromModel(withDataModel: dataModel)
    }

    func updateAvailableCampaigns() {
        self.campaigns.value = dataModel.campaigns
    }
}
