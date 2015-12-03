//
//  FlickrTableViewCell.swift
//  GastrofixCodeChallenge
//
//  Created by Rabbot on 02/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

import UIKit

class FlickrTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flickrImage: UIImageView!
    @IBOutlet weak var flickrTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
