//
//  PlaceCell.swift
//  Scouting Bird
//
//  Created by Hasan S. Al-Bukhari on 2/19/17.
//  Copyright © 2017 IMENA. All rights reserved.
//

import UIKit

class PlaceCell: UITableViewCell {

    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placePhoneLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    
    @IBOutlet weak var roundedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundedView.layer.cornerRadius = 6.0
    }
}
