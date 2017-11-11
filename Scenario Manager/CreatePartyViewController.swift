//
//  CreatePartyViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/31/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CreatePartyViewControllerDelegate: class {
    func createPartyViewControllerDidCancel(_ controller: CreatePartyViewController)
    func createPartyViewControllerDidFinishAdding(_ controller: CreatePartyViewController)
}
class CreatePartyViewController: UIViewController {
    
    @IBOutlet var createPartyView: UIView!
    
    @IBOutlet weak var createPartyPartyNameTextField: UITextField!
    
    @IBOutlet weak var createPartyCharacter1NameTextField: UITextField!
    
    @IBOutlet weak var createPartyCharacter2NameTextField: UITextField!
    
    @IBOutlet weak var createPartyCharacter3NameTextField: UITextField!
    
    @IBOutlet weak var createPartyCharacter4NameTextField: UITextField!
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.createPartyViewControllerDidCancel(self)
    }
    
    @IBAction func save(_ sender: Any) {
        if createPartyPartyNameTextField.text != "" && createPartyCharacter1NameTextField.text != "" {
            delegate?.createPartyViewControllerDidFinishAdding(self)
            // Test Test!
            //reloadDelegate?.reloadAfterDidFinishAdding()
        } else {
            print("Fill all required fields!")
        }
    }
    
    var viewModel: CreatePartyViewModel? {
        didSet {
            //
        }
    }
    weak var delegate: CreatePartyViewControllerDelegate?
    
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleUI()
        
    }
    
    // Helper methods
    fileprivate func styleUI() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "campaignDetailTableViewBG")
        backgroundImage.alpha = 0.25
        self.createPartyView.insertSubview(backgroundImage, at: 0)
        self.createPartyView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
    }

}
