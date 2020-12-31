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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = Constants.CELL_RADIUS
    }
    
    private func setLocation(to location: CLLocationCoordinate2D) {
        let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: false)
    }
}
