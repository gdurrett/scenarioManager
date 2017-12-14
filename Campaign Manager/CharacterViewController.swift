//
//  CharacterViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/13/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol CharacterViewControllerSegmentedControlDelegate: class {
    var characterFilterOutletSelectedIndex: Int { get set }
}

class CharacterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var characterTableView: UITableView!
    
    @IBAction func characterFilterAction(_ sender: Any) {
        filterDelegate.characterFilterOutletSelectedIndex = characterFilterOutlet.selectedSegmentIndex
    }
    
    @IBOutlet weak var characterFilterOutlet: UISegmentedControl!
    
    weak var filterDelegate: CharacterViewModel!
    
    var viewModel: CharacterViewModel? {
        didSet {
            print("Did viewModel get assigned?")
            //fillUI()
        }
    }
    var character: Character!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    // Temp

    override func viewDidLoad() {
        super.viewDidLoad()

        characterTableView?.dataSource = self
        characterTableView?.delegate = self
        
        characterTableView?.register(SelectCharacterTitleCell.nib, forCellReuseIdentifier: SelectCharacterTitleCell.identifier)
        styleUI()
    }

    fileprivate func styleUI() {
        self.characterTableView.estimatedRowHeight = 80
        self.characterTableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.navigationBar.tintColor = colorDefinitions.mainTextColor
        self.navigationController?.navigationBar.barTintColor = UIColor(hue: 46/360, saturation: 8/100, brightness: 100/100, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Nyala", size: 26.0)!, .foregroundColor: colorDefinitions.mainTextColor]
        //self.navigationItem.title = ("\(self.viewModel.campaignTitle.value) Detail")
        self.navigationItem.title = "Characters"
        self.characterTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.characterTableView.backgroundView?.alpha = 0.25
    }

    // Helper methods
    func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Character"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var returnValue: Int
        switch(characterFilterOutlet.selectedSegmentIndex) {
        case 0:
            returnValue = viewModel!.inactiveCharacters.value.count
            print(viewModel!.inactiveCharacters.value.count)
        case 1:
            returnValue = viewModel!.activeCharacters.value.count
            print("Active \(viewModel!.activeCharacters.value.count)")
        case 2:
            returnValue = viewModel!.retiredCharacters.value.count
        default:
            returnValue = 1
        }
        return returnValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = makeCell(for: tableView)
        switch(characterFilterOutlet.selectedSegmentIndex) {
        case 0:
            character = viewModel!.inactiveCharacters.value[indexPath.row]
        case 1:
            character = viewModel!.activeCharacters.value[indexPath.row]
        case 2:
            character = viewModel!.retiredCharacters.value[indexPath.row]
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCharacterTitleCell.identifier, for: indexPath) as! SelectCharacterTitleCell
        print("Getting in here?")
        //cell.backgroundView = UIImageView(image: UIImage(named: scenario.mainCellBGImage))
        cell.backgroundView?.alpha = 0.25
        //cell.selectedBackgroundView = UIImageView(image: UIImage(named: scenario.mainCellBGImage))
        cell.selectedBackgroundView?.alpha = 0.65
        cell.selectCharacterTitleCellTitleLabel.text = character.name
        return cell
    }
}
