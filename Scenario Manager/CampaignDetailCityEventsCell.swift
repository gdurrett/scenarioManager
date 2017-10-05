//
//  CampaignDetailCityEventsCell.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 10/4/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

class CampaignDetailCityEventsCell: UITableViewCell {
    
    @IBOutlet weak var campaignDetailCityEventsCollectionView: UICollectionView!
    let colorDefinitions = ColorDefinitions()
    let fontDefinitions = FontDefinitions()
    
    var items: CampaignDetailViewModelCityEventsItem? {
        didSet {
            campaignDetailCityEventsCollectionView.backgroundColor = UIColor.clear
        }
    }
    var dataSource: UICollectionViewDataSource? {
        didSet {
            campaignDetailCityEventsCollectionView.dataSource = self.dataSource
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

        // Register collection view events cell
        campaignDetailCityEventsCollectionView.register(CampaignDetailEventCollectionCell.nib, forCellWithReuseIdentifier: CampaignDetailEventCollectionCell.identifier)
        //campaignDetailCityEventsCollectionView.register(CampaignDetailCityEventsCell.self, forCellWithReuseIdentifier: CampaignDetailCityEventsCell.identifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
