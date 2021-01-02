//
//  ReminderCell.swift
//  UV Safe
//
//  Created by Shawn Patel on 12/31/20.
//  Copyright © 2020 Shawn Patel. All rights reserved.
//

import UIKit

class ReminderCell: SelfSizingCell {

    @IBOutlet weak var purpleBar: UIView!
    @IBOutlet weak var redBar: UIView!
    @IBOutlet weak var orangeBar: UIView!
    @IBOutlet weak var yellowBar: UIView!
    @IBOutlet weak var greenBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = Constants.CELL_RADIUS
        self.backgroundColor = Constants.CELL_BACKGROUND
        
        purpleBar.layer.cornerRadius = purpleBar.frame.height / 2
        redBar.layer.cornerRadius = redBar.frame.height / 2
        orangeBar.layer.cornerRadius = orangeBar.frame.height / 2
        yellowBar.layer.cornerRadius = yellowBar.frame.height / 2
        greenBar.layer.cornerRadius = greenBar.frame.height / 2
    }
}
