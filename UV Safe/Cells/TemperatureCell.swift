//
//  TemperatureCell.swift
//  UV Safe
//
//  Created by Shawn Patel on 12/31/20.
//  Copyright © 2020 Shawn Patel. All rights reserved.
//

import UIKit

class TemperatureCell: SelfSizingCell {

    @IBOutlet weak var currentTempTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var highTemp: UILabel!
    @IBOutlet weak var lowTemp: UILabel!
    @IBOutlet weak var unitSegment: UISegmentedControl!
    
    public var unitsChanged: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = Constants.CELL_RADIUS
        self.backgroundColor = Constants.CELL_BACKGROUND
        
        unitSegment?.backgroundColor = Constants.UV_SAFE_RED
        unitSegment?.setTitleTextAttributes([
            .foregroundColor: UIColor.black
        ], for: .normal)
    }

    @IBAction func unitsChanged(_ sender: Any) {
        if unitSegment.selectedSegmentIndex != UserDefaults.standard.integer(forKey: "units") {
            UserDefaults.standard.set(unitSegment.selectedSegmentIndex, forKey: "units")
            unitsChanged?()
        }
    }
}
