//
//  SelectCharacterViewController.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/27/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

protocol SelectCharacterViewControllerDelegate: class {
    func selectCharacterViewControllerDidCancel(_ controller: SelectCharacterViewController)
    func selectCharacterViewControllerDidFinishSelecting(_ controller: SelectCharacterViewController)
}
protocol SelectCharacterViewControllerReloadDelegate: class {
    func reloadAfterDidFinishSelecting()
}

class SelectCharacterViewController: UIViewController {

    @IBOutlet weak var selectCharacterTableView: UITableView!
    
    @IBOutlet var selectCharacterView: UIView!
    
    @IBAction func selectCharacterCancelAction(_ sender: Any) {
        delegate?.selectCharacterViewControllerDidCancel(self)
    }
    
    @IBAction func selectCharacterDoneAction(_ sender: Any) {
        if let selectedCharacterRows = selectCharacterTableView.indexPathsForSelectedRows {
            for index in selectedCharacterRows {
                let char = index.row
                selectedCharacters.append(combinedCharacters![char])
            }
        }
        for character in combinedCharacters! {
            if !selectedCharacters.contains(character) {
                unassignedCharacters.append(character)
            }
        }
        delegate?.selectCharacterViewControllerDidFinishSelecting(self)
        reloadDelegate?.reloadAfterDidFinishSelecting()
    }
    
    // MARK: Global Variables
    var viewModel: PartyDetailViewModel? {
        didSet {
            fillUI()
        }
    }
    var selectedIndices = [Int]()
    var selectedCharacters = [Character]()
    var availableCharacters: [Character]?
    var assignedCharacters: [Character]?
    var combinedCharacters: [Character]?
    var unassignedCharacters = [Character]()
    
    weak var delegate: SelectCharacterViewControllerDelegate?
    weak var reloadDelegate: SelectCharacterViewControllerReloadDelegate?
    
    var characters: [String]!
    let colorDefinitions = ColorDefinitions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectCharacterTableView.delegate = self
        selectCharacterTableView.dataSource = self
        selectCharacterTableView?.register(SelectCharacterTitleCell.nib, forCellReuseIdentifier: SelectCharacterTitleCell.identifier)
        
        // viewModel?.updateCharacters() - Test removal!
        viewModel?.updateAssignedCharacters()
        viewModel?.updateAvailableCharacters()
        
        fillUI()
        styleUI()
        
        if assignedCharacters == nil && availableCharacters == nil {
            // Shouldn't get this far with alert in PartyDetailVM
        } else if assignedCharacters == nil {
            combinedCharacters = availableCharacters
        } else if availableCharacters == nil {
            combinedCharacters = assignedCharacters
        } else {
            combinedCharacters = availableCharacters! + assignedCharacters!
        }

    }

    fileprivate func fillUI() {
        if !isViewLoaded {
            return
        }
        guard let viewModel = viewModel else {
            return
        }
        
        self.availableCharacters = viewModel.availableCharacters.value
        self.assignedCharacters = viewModel.assignedCharacters.value
    }
    fileprivate func styleUI() {
        self.selectCharacterView.backgroundColor = colorDefinitions.scenarioTableViewNavBarBarTintColor
        self.selectCharacterTableView.backgroundView = UIImageView(image: UIImage(named: "campaignDetailTableViewBG"))
        self.selectCharacterTableView.backgroundView?.alpha = 0.25
        self.selectCharacterTableView.allowsMultipleSelection = true
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
extension SelectCharacterViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.combinedCharacters!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeCell(for: tableView)
        cell.backgroundColor = UIColor.clear
        configureTitle(for: cell, with: combinedCharacters![indexPath.row])
        configureCharacterInfo(for: cell, with: combinedCharacters![indexPath.row])
        if self.combinedCharacters![indexPath.row].assignedTo == viewModel!.partyName.value {
            cell.accessoryType = .checkmark
        }
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selectedRowCount = tableView.indexPathsForSelectedRows?.count {
            if selectedRowCount > 3 {
                return nil
            } else {
                return indexPath
            }
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.combinedCharacters![indexPath.row].assignedTo != viewModel!.partyName.value {
         } else {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView.delegate?.tableView!(selectCharacterTableView, didSelectRowAt: indexPath)
        }
    }
}

