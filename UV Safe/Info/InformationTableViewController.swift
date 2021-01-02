//
//  InformationTableViewController.swift
//  UV Safe
//
//  Created by Sapna Patel on 7/24/17.
//  Copyright © 2017 Sapna Patel. All rights reserved.
//

import UIKit

class InformationTableViewCellController: UITableViewCell {
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var details: UILabel!
}

class InformationTableViewController: UITableViewController {

    @IBOutlet var informationTableView: UITableView!
    let imageArray = ["UVChart", "SPF", "Water", "Sunglasses", "Clothes"]
    let detailsArray = [nil, "Use SPF 30+ Sunscreen", "Stay Hydrated", "Wear Polarized Sunglasses", "Cover Skin with Clothes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.overrideUserInterfaceStyle = .dark
        
        informationTableView.delegate = self
        informationTableView.dataSource = self
        informationTableView.allowsSelection = false
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        if screenWidth == 414 && screenHeight == 736 {
            informationTableView.rowHeight = 266
        } else {
            informationTableView.rowHeight = (250 * (screenWidth - 16)) / 398
        }
        
        addEasterEgg()
    }

    private func addEasterEgg() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(performEasterEgg))
        longPress.minimumPressDuration = 5
        navigationController?.navigationBar.addGestureRecognizer(longPress)
    }
    
    @objc private func performEasterEgg() {
        let alert = UIAlertController(title: nil, message: "Designed by Mandy ™", preferredStyle: .alert)
        alert.view.tintColor = .black
        self.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            alert.dismiss(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomCell", for: indexPath) as! InformationTableViewCellController
        
        let image = imageArray[indexPath.row]
        let details = detailsArray[indexPath.row]
        
        cell.customImageView.image = UIImage(named: image)
        
        if let details = details {
            cell.details.text = details
            cell.details.isHidden = false
        } else {
            cell.details.isHidden = true
        }
        
        return cell
    }
}
