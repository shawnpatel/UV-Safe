//
//  AlertService.swift
//  UV Safe
//
//  Created by Shawn Patel on 5/12/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import UIKit

class AlertService {
    
    static func alert(message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(action)
        
        return alert
    }
}
