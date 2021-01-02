//
//  ReminderCell.swift
//  UV Safe
//
//  Created by Shawn Patel on 12/31/20.
//  Copyright © 2020 Shawn Patel. All rights reserved.
//

import UIKit

class ReminderCell: SelfSizingCell {

    @IBOutlet weak var reminderParent: UIView!
    @IBOutlet weak var reminderButton: UIButton!
    
    @IBOutlet weak var seperator: UIView!
    
    @IBOutlet weak var intensity: UILabel!
    @IBOutlet weak var protection: UILabel!
    
    @IBOutlet weak var purpleBarParent: UIView!
    @IBOutlet weak var redBarParent: UIView!
    @IBOutlet weak var orangeBarParent: UIView!
    @IBOutlet weak var yellowBarParent: UIView!
    
    @IBOutlet weak var purpleBar: UIView!
    @IBOutlet weak var redBar: UIView!
    @IBOutlet weak var orangeBar: UIView!
    @IBOutlet weak var yellowBar: UIView!
    @IBOutlet weak var greenBar: UIView!
    
    public var remindButtonPressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = Constants.CELL_RADIUS
        self.backgroundColor = Constants.CELL_BACKGROUND
        
        reminderParent.layer.cornerRadius = 8.5
        reminderButton.layer.cornerRadius = 8
        reminderButton.setTitleColor(.white, for: .normal)
        reminderButton.backgroundColor = Constants.UV_SAFE_RED.withAlphaComponent(0.9)
        
        seperator.layer.cornerRadius = seperator.frame.width / 2
        seperator.backgroundColor = .lightGray
        
        purpleBar.layer.cornerRadius = purpleBar.frame.height / 2
        redBar.layer.cornerRadius = redBar.frame.height / 2
        orangeBar.layer.cornerRadius = orangeBar.frame.height / 2
        yellowBar.layer.cornerRadius = yellowBar.frame.height / 2
        greenBar.layer.cornerRadius = greenBar.frame.height / 2
    }
    
    public func updateChart(uvIndex: Int) {
        if uvIndex <= 2 {
            intensity.text = "Mild"
            protection.text = "No Protection Required"
            
            purpleBarParent.isHidden = true
            redBarParent.isHidden = true
            orangeBarParent.isHidden = true
            yellowBarParent.isHidden = true
        } else if uvIndex <= 5 {
            intensity.text = "Moderate"
            protection.text = "Protection Required"
            
            purpleBarParent.isHidden = true
            redBarParent.isHidden = true
            orangeBarParent.isHidden = true
        } else if uvIndex <= 7 {
            intensity.text = "High"
            protection.text = "Protection Required"
            
            purpleBarParent.isHidden = true
            redBarParent.isHidden = true
        } else if uvIndex <= 10 {
            intensity.text = "Very High"
            protection.text = "Extra Protection"
            
            purpleBarParent.isHidden = true
        } else {
            intensity.text = "Intense"
            protection.text = "Extra Protection"
        }
    }
    
    @IBAction func remindButtonPressed(_ sender: Any) {
        remindButtonPressed?()
    }
}
