//
//  PartyDetailNotesCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 1/3/18.
//  Copyright © 2018 AppHazard Productions. All rights reserved.
//

import UIKit

class PartyDetailNotesCell: UITableViewCell {

    @IBOutlet weak var PartyNotes: UITextView!
    
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
