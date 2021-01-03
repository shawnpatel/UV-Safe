//
//  InfoCell.swift
//  UV Safe
//
//  Created by Shawn Patel on 1/2/21.
//  Copyright © 2021 Shawn Patel. All rights reserved.
//

import UIKit

class InfoCell: SelfSizingCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var details: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = Constants.CELL_RADIUS
        self.backgroundColor = Constants.CELL_BACKGROUND
    }

}
