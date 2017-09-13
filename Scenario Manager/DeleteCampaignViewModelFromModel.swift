//
//  DeleteCampaignViewModelFromModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/12/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

class DeleteCampaignViewModelFromModel: NSObject, CampaignViewControllerViewModel {
    
    let dataModel: DataModel
    var campaigns: [String:Campaign]
    //let currentCampaign: Campaign
    
    init(withDataModel dataModel: DataModel) {
        self.dataModel = dataModel
        self.campaigns = dataModel.campaigns
        //self.currentCampaign = dataModel.currentCampaign!
    }
    
    func deleteCampaign(campaign: String) {
        dataModel.campaigns.removeValue(forKey: campaign)
    }
    
    
}
