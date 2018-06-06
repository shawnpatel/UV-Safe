//
//  DetailsViewController.swift
//  UV Safe
//
//  Created by Shawn Patel on 11/21/17.
//  Copyright © 2017 Shawn Patel. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var skinCancer: UILabel!
    @IBOutlet weak var riskLevel: UILabel!
    
    var className = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let savedPercentage = UserDefaults.standard.object(forKey: "percentage") as? Double {
            let percentage = String(round(100 * (savedPercentage * 100)) / 100)
            if let savedName = UserDefaults.standard.object(forKey: "tag") as? String {
                className = savedName
                
                DispatchQueue.main.async {
                    self.skinCancer.text = percentage + "% " + self.className + "*"
                    
                    if savedPercentage <= 0.25 {
                        self.riskLevel.text = "Minimal Risk!*"
                    } else if savedPercentage <= 0.50 {
                        self.riskLevel.text = "Medium Risk!*"
                    } else if savedPercentage <= 0.75 {
                        self.riskLevel.text = "High Risk!*"
                    } else {
                        self.riskLevel.text = "Very High Risk!*"
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func aboutButton(_ sender: UIButton) {
        if className == "Melanoma" {
            openURL(url: "https://www.cancer.org/cancer/melanoma-skin-cancer/about.html")
        } else if className == "Basal Cell" || className == "Squamous Cell" {
            openURL(url: "https://www.cancer.org/cancer/basal-and-squamous-cell-skin-cancer/about.html")
        }
    }
    
    @IBAction func causesButton(_ sender: UIButton) {
        if className == "Melanoma" {
            openURL(url: "https://www.cancer.org/cancer/melanoma-skin-cancer/causes-risks-prevention.html")
        } else if className == "Basal Cell" || className == "Squamous Cell" {
            openURL(url: "https://www.cancer.org/cancer/basal-and-squamous-cell-skin-cancer/causes-risks-prevention.html")
        }
    }
    
    @IBAction func diagnosisButton(_ sender: UIButton) {
        if className == "Melanoma" {
            openURL(url: "https://www.cancer.org/cancer/melanoma-skin-cancer/detection-diagnosis-staging.html")
        } else if className == "Basal Cell" || className == "Squamous Cell" {
            openURL(url: "https://www.cancer.org/cancer/basal-and-squamous-cell-skin-cancer/detection-diagnosis-staging.html")
        }
    }
    
    @IBAction func treatmentButton(_ sender: UIButton) {
        if className == "Melanoma" {
            openURL(url: "https://www.cancer.org/cancer/melanoma-skin-cancer/treating.html")
        } else if className == "Basal Cell" || className == "Squamous Cell" {
            openURL(url: "https://www.cancer.org/cancer/basal-and-squamous-cell-skin-cancer/treating.html")
        }
    }
    
    func openURL(url: String) {
        if let url = NSURL(string: url) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
}
