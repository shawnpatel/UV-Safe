//
//  TemperatureCell.swift
//  UV Safe
//
//  Created by Shawn Patel on 12/31/20.
//  Copyright © 2020 Shawn Patel. All rights reserved.
//

import UIKit

class TemperatureCell: SelfSizingCell {

    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var highTemp: UILabel!
    @IBOutlet weak var lowTemp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = Constants.CELL_RADIUS
        self.backgroundColor = Constants.CELL_BACKGROUND
    }

}
