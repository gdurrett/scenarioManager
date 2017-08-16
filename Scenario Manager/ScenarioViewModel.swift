//
//  ScenarioViewModel.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import Foundation

protocol ScenarioViewControllerViewModel {
    var allScenarios: [Scenario] { get }
    var availableScenarios: [Scenario] { get }
    var completedScenarios: [Scenario] { get }
    
}
