//
//  AuthenticationController.swift
//  Campaign Manager
//
//  Created by Greg Durrett on 1/22/18.
//  Copyright © 2018 AppHazard Productions. All rights reserved.
//

import UIKit
import SwiftyDropbox

class AuthenticationController: UIViewController {

    let colorDefinitions = ColorDefinitions()
    let dataModel = DataModel.sharedInstance
    let window = UIWindow()
    var firstLoad: Bool?
    var campaignsFilePresent: Bool?
    var dropBoxFileDate: NSDate?
    var localFileDate: NSDate?
    
    override func viewDidLoad() {
        //self.campaignsFilePresent = false
        super.viewDidLoad()
        
        if firstLoad == true {
            print("FirstLoad?")
            checkForCampaignsFile()
            //firstLoad = false
            //showAuthenticationAlert()
        } else {
            checkForCampaignsFile()
            getDropboxFileDate()
            getPlistDate()
        }
        //showAuthenticationAlert()
        // Do any additional setup after loading the view.
    }

    fileprivate func showUploadAlert() {
        let alertController = UIAlertController(title: "Save file to Dropbox?", message: "Click Save to upload your campaign to Dropbox", preferredStyle: .alert)
        let uploadAction = UIAlertAction(title: "Save File", style: .default) { (action:UIAlertAction!) in
            self.uploadCampaignsFile()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertController.addAction(uploadAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = self.view

        self.present(alertController, animated: true, completion:nil)
    }
    fileprivate func showAuthenticationAlert () {
        let alertController = UIAlertController(title: "Found a save file in dropbox", message: "If you would like to load your save file from Dropbox, click 'Load Save File'. Otherwise, click 'Create New Campaign' to start a new campaign.", preferredStyle: .actionSheet)
        let loadAction = UIAlertAction(title: "Load Save File", style: .default) { (action:UIAlertAction!) in
            self.authenticateToDropBox()
        }
        let saveAction = UIAlertAction(title: "Save Campaign", style: .default)
        {
            (action:UIAlertAction!) in
            self.uploadCampaignsFile()
        }
        let createAction = UIAlertAction(title: "Create New Campaign", style: .default) { (action:UIAlertAction!) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "CreateCampaignViewController") as! CreateCampaignViewController
            let navCon = UINavigationController(rootViewController: createCampaignVC)
            let viewModel = CampaignDetailViewModel(withCampaign: self.dataModel.currentCampaign)
            let createCampaignVCViewModel = CreateCampaignViewModelFromModel(withDataModel: viewModel.dataModel)
            createCampaignVC.viewModel = createCampaignVCViewModel
            createCampaignVC.delegate = createCampaignVCViewModel
            createCampaignVC.isFirstLoad = true
            createCampaignVCViewModel.isFirstLoad = true
            //self.present(navCon, animated: true, completion: nil)
            self.show(navCon, sender: self)
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
//        if dataModel.campaigns.isEmpty == true {
//            alertController.addAction(createAction)
//        }
        if dataModel.campaigns.isEmpty != true || dataModel.campaigns["MyCampaign"]?.isCurrent != nil {
            print(dataModel.campaigns.isEmpty)
            alertController.addAction(saveAction)
        } else {
            alertController.addAction(createAction)
        }
        alertController.addAction(loadAction)
        alertController.popoverPresentationController?.sourceView = self.view
        
        self.present(alertController, animated: true, completion:nil)
    }
    fileprivate func authenticateToDropBox() {
        if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                //controller: UIApplication.shared.keyWindow?.rootViewController,
                                                          openURL: { (url: URL) -> Void in
                                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
            if DropboxClientsManager.authorizedClient == nil {
                loadCreateCampaignController()
            } else {
                downloadCampaignsFile()
            }
        } else {
            downloadCampaignsFile()
        }
    }
    fileprivate func checkDropboxAuthStatus() -> Bool {
        if DropboxClientsManager.authorizedClient != nil {
            return true
        } else {
            return false
        }
    }
    func loadCreateCampaignController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "CreateCampaignViewController") as! CreateCampaignViewController
        let navCon = UINavigationController(rootViewController: createCampaignVC)
        let viewModel = CampaignDetailViewModel(withCampaign: self.dataModel.currentCampaign)
        let createCampaignVCViewModel = CreateCampaignViewModelFromModel(withDataModel: viewModel.dataModel)
        createCampaignVC.viewModel = createCampaignVCViewModel
        createCampaignVC.delegate = createCampaignVCViewModel
        createCampaignVC.isFirstLoad = true
        createCampaignVCViewModel.isFirstLoad = true
        //self.present(navCon, animated: true, completion: nil)
        firstLoad = false
        self.show(navCon, sender: self)
    }
    func launchTabBarController() {
        dataModel.loadCampaignsFromLocal()
        
        let scenarioViewModel = ScenarioViewModelFromModel(withDataModel: dataModel)
        
        let campaignDetailViewModel = CampaignDetailViewModel(withCampaign: dataModel.currentCampaign)
        let partyDetailViewModel = PartyDetailViewModel(withParty: dataModel.currentParty)
        // Set to first character that matches current party assignment
        let currentPartyCharacters = dataModel.characters.values.filter { $0.assignedTo == dataModel.currentParty.name }.isEmpty ? Array(dataModel.characters.values) : dataModel.characters.values.filter { $0.assignedTo == dataModel.currentParty.name }
        
        let characterDetailViewModel = CharacterDetailViewModel(withCharacter: currentPartyCharacters.first!)
        
        //if let tabBarController: UITabBarController = self.window.rootViewController as? CampaignManagerTabBarController { // Set up top-level controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "CampaignManagerTabBarController") as! CampaignManagerTabBarController
        
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
        
            self.window.rootViewController = tabBarController
            self.present(tabBarController, animated: true, completion: nil)
        }
    fileprivate func checkForCampaignsFile() {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.listFolder(path: "").response {
                response, error in
                if let result = response {
                    for entry in result.entries {
                        if entry.name == "Campaigns.plist" {
                            if self.firstLoad == true {
                                self.firstLoad = false
                                self.showAuthenticationAlert()
                            } else {
                                self.showDownloadUploadActionSheet()
                            }
                        } else {
                            //self.getFileDate()
                            if self.firstLoad == true {
                                self.firstLoad = false
                                self.loadCreateCampaignController()
                            } else {
                                self.showUploadAlert()
                            }
                        }
                    }
                } else if let error = error {
                    print(error)
                }
            }
        } else {
            // alert to ask if user wants to auth to dropbox or create new campaign
            showInitialAuthenticationAlert()
        }
    }
    func downloadCampaignsFile() {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.listFolder(path: "").response {
                response, error in
                if let result = response {
                    for entry in result.entries {
                        if entry.name == "Campaigns.plist" {
                            let destination: (URL, HTTPURLResponse) -> URL = { tempURL, response in
                                return self.dataModel.dataFilePath()
                            }
                            if self.checkForPlist() == false {
                                client.files.download(path: "/Campaigns.plist", overwrite: true, destination: destination)
                                    .response { response, error in
                                        if let _ = response {
                                            self.launchTabBarController()
                                        } else if let _ = error {
                                            print("Didn't find a save file - continuing to campaign creation.")
                                        }
                                }
                            } else {
                                if self.dropBoxFileDate!.compare(self.localFileDate! as Date) == ComparisonResult.orderedDescending {
                                    client.files.download(path: "/Campaigns.plist", overwrite: true, destination: destination)
                                        .response { response, error in
                                            if let _ = response {
                                                self.launchTabBarController()
                                            } else if let _ = error {
                                                print("Didn't find a save file - continuing to campaign creation.")
                                            }
                                    }
                                } else if self.dropBoxFileDate!.compare(self.localFileDate! as Date) == ComparisonResult.orderedAscending {
                                    let alertController = UIAlertController(title: "Local campaign file is newer than Dropbox save file!", message: "The local campaign save file is newer than the Dropbox save file. If you would still like to download the Dropbox campaign state to your device, click OK. Otherwise, click Cancel.", preferredStyle: .alert)
                                    let downloadAction = UIAlertAction(title: "OK", style: .default)
                                    {
                                        (action:UIAlertAction!) in
                                        client.files.download(path: "/Campaigns.plist", overwrite: true, destination: destination)
                                            .response { response, error in
                                                if let _ = response {
                                                    self.launchTabBarController()
                                                } else if let _ = error {
                                                    print("Didn't find a save file - continuing to campaign creation.")
                                                }
                                        }
                                    }
                                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                                        (action:UIAlertAction!) in self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                    alertController.view.tintColor = self.colorDefinitions.scenarioAlertViewTintColor
                                    alertController.addAction(downloadAction)
                                    alertController.addAction(cancelAction)
                                    
                                    alertController.popoverPresentationController?.sourceView = self.view
                                    
                                    self.present(alertController, animated: true, completion:nil)
                                    
                                }
                            }
                        }
                    }
                } else if let error = error {
                    print(error)
                }
            }
            print("Did get a client though.")
        }
    }
    func uploadCampaignsFile() {
        dataModel.saveCampaignsLocally()
        if let client = DropboxClientsManager.authorizedClient {
            /// Start
            if self.dropBoxFileDate!.compare(self.localFileDate! as Date) == ComparisonResult.orderedAscending {
                let _ = client.files.upload(path: "/Campaigns.plist", mode: .overwrite, input: self.dataModel.dataFilePath())
                    .response { response, error in
                        if let response = response {
                            print(response)
                        } else if let error = error {
                            print(error)
                        }
                    }
                    .progress { progressData in
                        print(progressData)
                }
            } else if self.dropBoxFileDate!.compare(self.localFileDate! as Date) == ComparisonResult.orderedDescending {
                let alertController = UIAlertController(title: "Dropbox save file is newer than local save file!", message: "The Dropbox save file is newer than the local save file. If you still wish to upload the local save file, click OK, otherwise click Cancel", preferredStyle: .alert)
                let uploadAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action:UIAlertAction!) in
                    let _ = client.files.upload(path: "/Campaigns.plist", mode: .overwrite, input: self.dataModel.dataFilePath())
                        .response { response, error in
                            if let response = response {
                                print(response)
                            } else if let error = error {
                                print(error)
                            }
                        }
                        .progress { progressData in
                            print(progressData)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                    (action:UIAlertAction!) in self.dismiss(animated: true, completion: nil)
                }
                
                alertController.view.tintColor = self.colorDefinitions.scenarioAlertViewTintColor
                alertController.addAction(uploadAction)
                alertController.addAction(cancelAction)
                
                alertController.popoverPresentationController?.sourceView = self.view
                
                self.present(alertController, animated: true, completion:nil)
            }
            self.dismiss(animated: true, completion: nil)
            /// End
        }
        //self.dismiss(animated: true, completion: nil)
    }
    func showDownloadUploadActionSheet() {
        if let _ = DropboxClientsManager.authorizedClient {
            let alertController = UIAlertController(title: "Campaign Manager is authenticated to Dropbox and has found a save file!", message: "Choose an option", preferredStyle: .alert)
            let saveButton = UIAlertAction(title: "Save campaign to Dropbox", style: .default, handler: {
                (action) -> () in
                self.uploadCampaignsFile()
                //self.dismiss(animated: true, completion: nil)
            })
            let loadButton = UIAlertAction(title: "Load campaign from Dropbox", style: .default, handler: {
                (action) -> () in
                self.downloadCampaignsFile()
                self.dataModel.loadCampaignsFromLocal()
                self.dataModel.setCampaignsAndParties()
            })
            let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: {
                (action) -> () in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
            alertController.addAction(loadButton)
            alertController.addAction(saveButton)
            alertController.addAction(cancelButton)
            
            alertController.popoverPresentationController?.sourceView = self.view

            self.present(alertController, animated: true, completion: nil)
        } else {
            authenticateToDropBox()
        }
    }
    fileprivate func showInitialAuthenticationAlert () {
        let alertController = UIAlertController(title: "Load save file from Dropbox?", message: "If you have a save file in Dropbox, click 'Load Save File' to sign in to Dropbox and download your save file. Otherwise, click 'Create New Campaign' to start a new campaign.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Load Save File", style: .default) { (action:UIAlertAction!) in
            self.authenticateToDropBox()
        }
        let _ = UIAlertAction(title: "Save Campaign", style: .default)
        {
            (action:UIAlertAction!) in
            self.uploadCampaignsFile()
        }
        let cancelAction = UIAlertAction(title: "Create New Campaign", style: .cancel) { (action:UIAlertAction!) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let createCampaignVC = storyboard.instantiateViewController(withIdentifier: "CreateCampaignViewController") as! CreateCampaignViewController
            let navCon = UINavigationController(rootViewController: createCampaignVC)
            let viewModel = CampaignDetailViewModel(withCampaign: self.dataModel.currentCampaign)
            let createCampaignVCViewModel = CreateCampaignViewModelFromModel(withDataModel: viewModel.dataModel)
            createCampaignVC.viewModel = createCampaignVCViewModel
            createCampaignVC.delegate = createCampaignVCViewModel
            createCampaignVC.isFirstLoad = true
            createCampaignVCViewModel.isFirstLoad = true
            //self.present(navCon, animated: true, completion: nil)
            self.show(navCon, sender: self)
        }
        alertController.view.tintColor = colorDefinitions.scenarioAlertViewTintColor
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)

        alertController.popoverPresentationController?.sourceView = self.view

        self.present(alertController, animated: true, completion:nil)
    }
    fileprivate func getDropboxFileDate() {
        if let client = DropboxClientsManager.authorizedClient {
            client.files.getMetadata(path: "/Campaigns.plist", includeMediaInfo: true).response { response, error in
                if let result = response as? Files.FileMetadata {
                    self.dropBoxFileDate = result.serverModified as NSDate
                }
            }
        }
    }
    fileprivate func getPlistDate() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let fileManager = FileManager.default
        let filePath = url.appendingPathComponent("Campaigns.plist")?.path
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: filePath!)
            //print(attributes[FileAttributeKey.modificationDate] as! NSDate)
            self.localFileDate = attributes[FileAttributeKey.modificationDate] as? NSDate
        }
        catch let error as NSError {
            print("There was a problem accessing the plist file: \(error)")
        }
    }
    fileprivate func checkForPlist() -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let fileManager = FileManager.default
        let filePath = url.appendingPathComponent("Campaigns.plist")?.path
        if fileManager.fileExists(atPath: filePath!) {
            return true
        } else {
            return false
        }
    }
}
