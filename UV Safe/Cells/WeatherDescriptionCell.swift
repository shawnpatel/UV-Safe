//
//  WeatherDescriptionCell.swift
//  UV Safe
//
//  Created by Shawn Patel on 12/31/20.
//  Copyright © 2020 Shawn Patel. All rights reserved.
//

import UIKit

class WeatherDescriptionCell: SelfSizingCell {

    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = Constants.CELL_RADIUS
        self.backgroundColor = Constants.CELL_BACKGROUND
    }

}
