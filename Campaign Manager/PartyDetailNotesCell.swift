//
//  PartyDetailNotesCell.swift
//  Campaign Manager
//
//  Created by Greg Durrett on 1/3/18.
//  Copyright © 2018 AppHazard Productions. All rights reserved.
//

import UIKit

class PartyDetailNotesCell: UITableViewCell {
    
    @IBOutlet weak var NotesField: UITextView!
    
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var item: PartyDetailViewModelItem? {
        didSet {
            guard let item = item as? PartyDetailViewModelPartyNotesItem else {
                return
            }
            NotesField.text = "\(item.notes)"
            NotesField.backgroundColor = UIColor.clear
            NotesField.font = UIFont(name: "Nyala", size: 22.0)
            NotesField.textColor = colorDefinitions.mainTextColor
            NotesField.isScrollEnabled = true
        }
    }
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:))))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
