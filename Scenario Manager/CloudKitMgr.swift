//
//  CloudKitMgr.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 9/1/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitMgr {

    var myContainer: CKContainer
    var privateDatabase: CKDatabase
    
    init() {
        myContainer = CKContainer(identifier: "iCloud.com.apphazard.ScenarioManager")
        privateDatabase = myContainer.privateCloudDatabase
    }
}
