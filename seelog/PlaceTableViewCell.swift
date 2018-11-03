//
//  PlaceTableViewCell.swift
//  seelog
//
//  Created by Matus Tomlein on 02/11/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var placeNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
