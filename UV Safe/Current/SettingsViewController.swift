//
//  SettingsViewController.swift
//  UV Safe
//
//  Created by Shawn Patel on 6/8/18.
//  Copyright © 2018 Shawn Patel. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var unitController: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let index = UserDefaults.standard.object(forKey: "units") as? Int {
            unitController.selectedSegmentIndex = index
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unitControllerValueChanged(_ sender: UISegmentedControl) {
        if unitController.selectedSegmentIndex != UserDefaults.standard.integer(forKey: "units") {
            UserDefaults.standard.set(unitController.selectedSegmentIndex, forKey: "units")
        }
    }
}
