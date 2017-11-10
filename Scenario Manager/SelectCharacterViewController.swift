//
//  SelectCharacterViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 11/8/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol SelectCharacterViewControllerDelegate: class {
    func selectCharacterViewControllerDidCancel(_ controller: SelectCharacterViewController)
    func selectCharacterViewControllerDidFinishSelecting(_ controller: SelectCharacterViewController)
}

class SelectCharacterViewController: UIViewController {
    
    @IBOutlet var selectCharacterView: UIView!
    
    @IBOutlet weak var selectCharacterTableView: UITableView!
    
    @IBAction func selectCharacterViewControllerDidCancel(_ sender: Any) {
        delegate?.selectCharacterViewControllerDidCancel(self)
    }
    
    @IBAction func selectCharacterViewControllerDoneAction(_ sender: Any) {
        if selectedCharacter == nil { selectedCharacter = viewModel!.character } // Just return current character if nothing was tapped
        delegate?.selectCharacterViewControllerDidFinishSelecting(self)
    }
    // MARK: Global Variables
    var viewModel: CharacterDetailViewModel? {
        didSet {
            fillUI()
            self.characters = viewModel!.characters.value
        }
    }
    weak var delegate: SelectCharacterViewControllerDelegate?
    var characters: [String:Character]?
    var selectedCharacter: Character?
    var selectedIndex: Int = -1
    let colorDefinitions = ColorDefinitions()
    var keyList: [String] {
        get {
            return [String](characters!.keys)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        selectCharacterTableView.delegate = self
        selectCharacterTableView.dataSource = self
        selectCharacterTableView?.register(SelectCharacterTitleCell.nib, forCellReuseIdentifier: SelectCharacterTitleCell.identifier)
        selectCharacterTableView.allowsMultipleSelection = false
        
        fillUI()
        styleUI()
        
    }
    // Helper methods
    fileprivate func fillUI() {
        if !isViewLoaded {
            return
        }
        guard let viewModel = viewModel else {
            return
        }
        
        // We definitely have setup done now
        self.characters = viewModel.characters.value
    }
    fileprivate func styleUI() {
        self.selectCharacterView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.selectCharacterTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.selectCharacterTableView.backgroundView?.alpha = 0.25
        self.selectCharacterTableView.separatorInset = .zero
    }
    fileprivate func makeCell(for tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "SelectCharacterTitleCell"
        if let cell =
            tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle,reuseIdentifier: cellIdentifier)
        }
    }
    fileprivate func configureTitle(for cell: UITableViewCell, with character: Character) {
        let label = cell.viewWithTag(3500) as! UILabel
        label.text = character.name
        label.sizeToFit()
    }
    fileprivate func configureCharacterInfo(for cell: UITableViewCell, with character: Character) {
        let label = cell.viewWithTag(3600) as! UILabel
        label.text = ("level \(Int(character.level)) \(character.type)")
    }
}
extension SelectCharacterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.characters!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myRowkey = keyList[indexPath.row]
        let cell = makeCell(for: tableView)
        cell.backgroundColor = UIColor.clear
        configureTitle(for: cell, with: characters![myRowkey]!)
        configureCharacterInfo(for: cell, with: characters![myRowkey]!)
        if self.characters![myRowkey]!.name == viewModel!.character.name {
            cell.accessoryType = .checkmark
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        let myRowkey = keyList[indexPath.row]
        selectedCharacter = self.characters![myRowkey]!
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let myRowkey = keyList[indexPath.row]
        if self.characters![myRowkey]!.name == viewModel!.character.name {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}
