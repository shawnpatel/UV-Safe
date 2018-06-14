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
}

class InformationTableViewController: UITableViewController {

    @IBOutlet var informationTableView: UITableView!
    let imageArray = ["UVChart", "SPF", "Water", "Sunglasses", "Clothes"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor(red: 243/255, green: 178/255, blue: 41/255, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 243/255, green: 178/255, blue: 41/255, alpha: 1)
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.isTranslucent = false
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCustomCell", for: indexPath) as! InformationTableViewCellController
        cell.customImageView.image = UIImage(named: imageArray[indexPath.row])
        return cell
    }
}