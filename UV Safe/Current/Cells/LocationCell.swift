//
//  LocationCell.swift
//  UV Safe
//
//  Created by Shawn Patel on 12/31/20.
//  Copyright © 2020 Shawn Patel. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: SelfSizingCell {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var country: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = Constants.CELL_RADIUS
    }
    
    public func setLocation(to location: CLLocationCoordinate2D) {
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 25000, longitudinalMeters: 25000)
        mapView.setRegion(viewRegion, animated: false)
    }
}
