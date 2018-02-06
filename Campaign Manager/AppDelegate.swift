//
//  AppDelegate.swift
//  Campaign Manager
//
//  Created by Greg Durrett on 6/28/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataModel = DataModel.sharedInstance
    let globalButtonFont = UIFont(name: "Nyala", size: 24.0)!
    let colorDefinitions = ColorDefinitions()
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") != nil{
            print("Already launched?")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("Not launched yet?")
            return false
        }
    }

    // Setup redirect back into app after Dropbox auth
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
                launchAuthorizationController()
            case .cancel:
                print("Authorization flow was manually canceled by user! Proceeding to campaign creation")
                if isAppAlreadyLaunchedOnce() {
                    print("User cancelled Dropbox authentication.")
                    loadCurrentCampaign()
                } else {
                    launchCampaignCreation()
                }
            case .error(_, let description):
                print("Error: \(description)")
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize Dropbox
        //DropboxClientsManager.unlinkClients()
        if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.setupWithAppKey("s1p4qomjhi3011j")
        }


        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: globalButtonFont], for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes([NSAttributedStringKey.foregroundColor: colorDefinitions.mainTextColor, NSAttributedStringKey.font: UIFont(name: "Nyala", size: 24.0)!], for: .normal)
        UINavigationBar.appearance().tintColor = colorDefinitions.mainTextColor
        if isAppAlreadyLaunchedOnce() {
            loadCurrentCampaign()
//            let scenarioViewModel = ScenarioViewModelFromModel(withDataModel: dataModel)
//
//            let campaignDetailViewModel = CampaignDetailViewModel(withCampaign: dataModel.currentCampaign)
//            let partyDetailViewModel = PartyDetailViewModel(withParty: dataModel.currentParty)
//            // Set to first character that matches current party assignment
//            let currentPartyCharacters = dataModel.characters.values.filter { $0.assignedTo == dataModel.currentParty.name }.isEmpty ? Array(dataModel.characters.values) : dataModel.characters.values.filter { $0.assignedTo == dataModel.currentParty.name }
//
//            let characterDetailViewModel = CharacterDetailViewModel(withCharacter: currentPartyCharacters.first!)
//
//            if let tabBarController: UITabBarController = self.window!.rootViewController as? CampaignManagerTabBarController { // Set up top-level controller
//
//                let navController1 = tabBarController.viewControllers?[1] as! UINavigationController
//                let controller1 = navController1.viewControllers[0] as! PartyDetailViewController
//                controller1.viewModel = partyDetailViewModel
//                controller1.delegate = partyDetailViewModel
//                controller1.pickerDelegate = partyDetailViewModel
//
//                // Set up Campaign Detail view controller
//                let navController2 = tabBarController.viewControllers?[0] as? UINavigationController
//                let controller2 = navController2?.viewControllers[0] as! CampaignDetailViewController
//                controller2.viewModel = campaignDetailViewModel
//                controller2.delegate = campaignDetailViewModel
//                // See if we can set reload
//                campaignDetailViewModel.partyReloadDelegate = controller1
//
//
//                // Set up Character Detail view controller
//                let navController3 = tabBarController.viewControllers?[2] as? UINavigationController
//                let controller3 = navController3?.viewControllers[0] as! SelectCharacterViewController
//                controller3.viewModel = characterDetailViewModel
//                controller3.actionDelegate = characterDetailViewModel
//                //controller3.delegate = characterDetailViewModel
//
//                // Set up Scenario view controller
//                let navController4 = tabBarController.viewControllers?[3] as? UINavigationController
//                let controller4 = navController4?.viewControllers[0] as! ScenarioViewController
//                controller4.viewModel = scenarioViewModel
//            }
        } else {
            // Spawn dedicated VC to authenticate to Dropbox and load plist
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "CreateCampaignViewController") as! CreateCampaignViewController
//            let navCon = UINavigationController(rootViewController: createCampaignVC)
//            let viewModel = CampaignDetailViewModel(withCampaign: dataModel.currentCampaign)
//            let createCampaignVCViewModel = CreateCampaignViewModelFromModel(withDataModel: viewModel.dataModel)
//            createCampaignVC.viewModel = createCampaignVCViewModel
//            createCampaignVC.delegate = createCampaignVCViewModel
//            createCampaignVC.isFirstLoad = true
//            createCampaignVCViewModel.isFirstLoad = true
//            self.window?.rootViewController = navCon
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let authenticationControllerVC = storyboard.instantiateViewController(withIdentifier: "AuthenticationController") as! AuthenticationController
//            authenticationControllerVC.firstLoad = true
//            let navCon = UINavigationController(rootViewController: authenticationControllerVC)
//            self.window?.rootViewController = navCon
            // Need to reset this in case user cancels during initial auth
//            let defaults = UserDefaults.standard
//            defaults.set(nil, forKey: "isAppAlreadyLaunchedOnce")
            launchAuthorizationController()
        }

        return true
    }

    func saveData() {
        dataModel.saveCampaignsLocally()
    }
    func launchAuthorizationController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let authenticationControllerVC = storyboard.instantiateViewController(withIdentifier: "AuthenticationController") as! AuthenticationController
        authenticationControllerVC.firstLoad = true
        let navCon = UINavigationController(rootViewController: authenticationControllerVC)
        self.window?.rootViewController = navCon
    }
    func launchCampaignCreation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "CreateCampaignViewController") as! CreateCampaignViewController
        let navCon = UINavigationController(rootViewController: createCampaignVC)
        let viewModel = CampaignDetailViewModel(withCampaign: dataModel.currentCampaign)
        let createCampaignVCViewModel = CreateCampaignViewModelFromModel(withDataModel: viewModel.dataModel)
        createCampaignVC.viewModel = createCampaignVCViewModel
        createCampaignVC.delegate = createCampaignVCViewModel
//        createCampaignVC.isFirstLoad = true
//        createCampaignVCViewModel.isFirstLoad = true
        self.window?.rootViewController = navCon
    }
    func loadCurrentCampaign() {
        let scenarioViewModel = ScenarioViewModelFromModel(withDataModel: dataModel)
        
        let campaignDetailViewModel = CampaignDetailViewModel(withCampaign: dataModel.currentCampaign)
        let partyDetailViewModel = PartyDetailViewModel(withParty: dataModel.currentParty)
        // Set to first character that matches current party assignment
        let currentPartyCharacters = dataModel.characters.values.filter { $0.assignedTo == dataModel.currentParty.name }.isEmpty ? Array(dataModel.characters.values) : dataModel.characters.values.filter { $0.assignedTo == dataModel.currentParty.name }
        
        let characterDetailViewModel = CharacterDetailViewModel(withCharacter: currentPartyCharacters.first!)
        
        if let tabBarController: UITabBarController = self.window!.rootViewController as? CampaignManagerTabBarController { // Set up top-level controller
            
            let navController1 = tabBarController.viewControllers?[1] as! UINavigationController
            let controller1 = navController1.viewControllers[0] as! PartyDetailViewController
            controller1.viewModel = partyDetailViewModel
            controller1.delegate = partyDetailViewModel
            controller1.pickerDelegate = partyDetailViewModel
            
            // Set up Campaign Detail view controller
            let navController2 = tabBarController.viewControllers?[0] as? UINavigationController
            let controller2 = navController2?.viewControllers[0] as! CampaignDetailViewController
            controller2.viewModel = campaignDetailViewModel
            controller2.delegate = campaignDetailViewModel
            // See if we can set reload
            campaignDetailViewModel.partyReloadDelegate = controller1
            
            
            // Set up Character Detail view controller
            let navController3 = tabBarController.viewControllers?[2] as? UINavigationController
            let controller3 = navController3?.viewControllers[0] as! SelectCharacterViewController
            controller3.viewModel = characterDetailViewModel
            controller3.actionDelegate = characterDetailViewModel
            //controller3.delegate = characterDetailViewModel
            
            // Set up Scenario view controller
            let navController4 = tabBarController.viewControllers?[3] as? UINavigationController
            let controller4 = navController4?.viewControllers[0] as! ScenarioViewController
            controller4.viewModel = scenarioViewModel
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveData()
        // Implement automatic CloudKit update when I have a better handle on error handling
        //dataModel.updateScenarioStatusRecords(scenarios: dataModel.allScenarios)
        //dataModel.updateAchievementsStatusRecords(achievementsToUpdate: dataModel.achievements)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveData()
        // Implement automatic CloudKit update when I have a better handle on error handling
//        dataModel.updateScenarioStatusRecords(scenarios: dataModel.allScenarios)
//        dataModel.updateAchievementsStatusRecords(achievementsToUpdate: dataModel.achievements)
    }


}

