//
//  SearchViewController.swift
//  UV Safe
//
//  Created by Sapna Patel on 6/20/17.
//  Copyright © 2017 Sapna Patel. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class SearchViewController: UIViewController {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var UVIndexButton: UIButton!
    @IBOutlet weak var tempButton: UIButton!
    @IBOutlet weak var windButton: UIButton!
    @IBOutlet weak var conditionsImage: UIImageView!
    @IBOutlet weak var conditionsText: UILabel!
    @IBOutlet weak var distanceButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    
    var units: Int!
    
    var latitude = ""
    var longitude = ""
    var searchLatitude = ""
    var searchLongitude = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            if let city = UserDefaults.standard.object(forKey: "savedSearchCityName") as? String {
                self.cityLabel.text = city
            } else {
                self.searchCity()
            }
            self.UVIndexButton.setTitle(UserDefaults.standard.object(forKey: "savedSearchUVIndex") as? String, for: .normal)
            self.tempButton.setTitle(UserDefaults.standard.object(forKey: "savedSearchTemp") as? String, for: .normal)
            self.windButton.setTitle(UserDefaults.standard.object(forKey: "savedSearchWind") as? String, for: .normal)
            self.distanceButton.setTitle(UserDefaults.standard.object(forKey: "savedDistance") as? String, for: .normal)
            self.timeButton.setTitle(UserDefaults.standard.object(forKey: "savedDuration") as? String, for: .normal)
            if let iconString = UserDefaults.standard.object(forKey: "savedSearchIconString") as? String {
                self.conditionsImage.image = UIImage(named: iconString)
            }
            if let lat = UserDefaults.standard.object(forKey: "savedSearchLatitude") as? String {
                self.searchLatitude = lat
            }
            if let long = UserDefaults.standard.object(forKey: "savedSearchLongitude") as? String {
                self.searchLongitude = long
            }
            if let lat = UserDefaults.standard.object(forKey: "savedLatitude") as? String {
                self.latitude = lat
            }
            if let long = UserDefaults.standard.object(forKey: "savedLongitude") as? String {
                self.longitude = long
                self.WeatherUndergroundJSON(distanceJSON: true)
            }
        }
        
        self.UVIndexButton.titleLabel?.numberOfLines = 1
        self.UVIndexButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.UVIndexButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        
        self.tempButton.titleLabel?.numberOfLines = 1
        self.tempButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.tempButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.tempButton.isEnabled = false
        
        self.windButton.titleLabel?.numberOfLines = 1
        self.windButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.windButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.windButton.isEnabled = false
        
        self.distanceButton.titleLabel?.numberOfLines = 1
        self.distanceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.distanceButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.distanceButton.isEnabled = false
        
        self.timeButton.titleLabel?.numberOfLines = 1
        self.timeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.timeButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 243/255, green: 178/255, blue: 41/255, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 243/255, green: 178/255, blue: 41/255, alpha: 1)
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.isTranslucent = false
        
        if let contains = self.tempButton.currentTitle?.contains("F") {
            if contains && self.units == 1 {
                self.WeatherUndergroundJSON(distanceJSON: true)
            }
        }
        
        if let contains = self.tempButton.currentTitle?.contains("C") {
            if contains && self.units == 0 {
                self.WeatherUndergroundJSON(distanceJSON: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        units = UserDefaults.standard.integer(forKey: "units")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func WeatherUndergroundJSON(distanceJSON: Bool) {
        progressBar.progress = 0
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let APIKey = ["05820e2fb2b22bb5", "93388dd4a6741555", "fda9d0342637a7c4", "a7dc316b7726b81f", "5ab2d695e1ee1d89"]
        let randomAPIKey = Int(arc4random_uniform(UInt32(APIKey.count)))
        let url = URL(string: "https://api.wunderground.com/api/" + APIKey[randomAPIKey] + "/conditions/q/" + searchLatitude + "," + searchLongitude + ".json")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.cityLabel.text = "Check internet connection!"
                }
            } else {
                if let content = data {
                    do {
                        let myJSON = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject

                        if let currentObservation = myJSON["current_observation"] as? NSDictionary {
                            if let displayLocation = currentObservation["display_location"] as? NSDictionary {
                                if let cityName = displayLocation["full"] as? String {
                                    UserDefaults.standard.set(cityName, forKey: "savedSearchCityName")
                                    DispatchQueue.main.async {
                                        self.cityLabel.text = cityName
                                    }
                                }
                            }
                            
                            if let UVIndexString = currentObservation["UV"] as? String {
                                if let UVIndexDouble = Double(UVIndexString) {
                                    let UVIndexInt = Int(UVIndexDouble)
                                    var UVIndexStringInt = String(UVIndexInt)
                                    if UVIndexInt < 0 {
                                        UVIndexStringInt = "N/A"
                                    }
                                    UserDefaults.standard.set(UVIndexStringInt + " UV", forKey: "savedSearchUVIndex")
                                    DispatchQueue.main.async {
                                        self.UVIndexButton.setTitle(UVIndexStringInt + " UV", for: .normal)
                                    }
                                }
                            }
                            
                            if self.units == 0 {
                                if let tempF = currentObservation["temp_f"] {
                                    let tempFString = String(format: "%.0f", Double(String(describing: tempF))!)
                                    UserDefaults.standard.set(tempFString + "°F", forKey: "savedTemp")
                                    DispatchQueue.main.async {
                                        self.tempButton.setTitle(String(tempFString) + "°F", for: .normal)
                                    }
                                }
                            } else if self.units == 1 {
                                if let tempC = currentObservation["temp_c"] {
                                    let tempCString = String(format: "%.0f", Double(String(describing: tempC))!)
                                    UserDefaults.standard.set(tempCString + "°C", forKey: "savedTemp")
                                    DispatchQueue.main.async {
                                        self.tempButton.setTitle(tempCString + "°C", for: .normal)
                                    }
                                }
                            }
                            
                            if self.units == 0 {
                                if let windMPH = currentObservation["wind_mph"] {
                                    let windMPHString = String(format: "%.0f", Double(String(describing: windMPH))!)
                                    UserDefaults.standard.set(windMPHString + " MPH", forKey: "savedWind")
                                    DispatchQueue.main.async {
                                        self.windButton.setTitle(windMPHString + " MPH", for: .normal)
                                    }
                                }
                            } else if self.units == 1 {
                                if let windKPH = currentObservation["wind_kph"] {
                                    let windKPHString = String(format: "%.0f", Double(String(describing: windKPH))!)
                                    UserDefaults.standard.set(windKPHString + " KPH", forKey: "savedWind")
                                    DispatchQueue.main.async {
                                        self.windButton.setTitle(windKPHString + " KPH", for: .normal)
                                    }
                                }
                            }
                            
                            if let iconString = currentObservation["icon"] as? String {
                                UserDefaults.standard.set(iconString, forKey: "savedSearchIconString")
                                DispatchQueue.main.async {
                                    self.conditionsImage.image = UIImage(named: iconString)
                                    if distanceJSON {
                                        self.distanceToCityJSON()
                                    } else {
                                        self.progressBar.progress = 1
                                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                    }
                                    
                                    if self.tempButton.currentTitle!.contains("F") && self.units == 1 {
                                        self.WeatherUndergroundJSON(distanceJSON: true)
                                    } else if self.tempButton.currentTitle!.contains("C") && self.units == 0 {
                                        self.WeatherUndergroundJSON(distanceJSON: true)
                                    }
                                }
                            }
                        }
                    } catch {
                        return
                    }
                }
            }
        }
        task.resume()
    }
    
    func distanceToCityJSON() {
        var url: URL!
        if units == 0 {
            url = URL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=" + latitude + "," + longitude + "&destinations=" + searchLatitude + "," + searchLongitude + "&key=AIzaSyC0AbgywK_k1ODP1kheexnBPaa12d-Qkog")
        } else if units == 1 {
            url = URL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=" + latitude + "," + longitude + "&destinations=" + searchLatitude + "," + searchLongitude + "&key=AIzaSyC0AbgywK_k1ODP1kheexnBPaa12d-Qkog")
        }
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                // WIFI Error
            } else {
                if let content = data {
                    do {
                        let myJSON = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let rows = myJSON["rows"] as? NSArray {
                            if let inRows = rows[0] as? NSDictionary {
                                if let elements = inRows["elements"] as? NSArray {
                                    if let inElements = elements[0] as? NSDictionary {
                                        if let distance = inElements["distance"] as? NSDictionary {
                                            if let distanceText = distance["text"] as? String {
                                                UserDefaults.standard.set(distanceText, forKey: "savedDistance")
                                                DispatchQueue.main.async {
                                                    self.distanceButton.setTitle(distanceText, for: .normal)
                                                }
                                            }
                                        }
                                        
                                        if let duration = inElements["duration"] as? NSDictionary {
                                            if let durationText = duration["text"] as? String {
                                                let formatedDurationText = durationText.replacingOccurrences(of: "hours", with: "hrs")
                                                UserDefaults.standard.set(formatedDurationText, forKey: "savedDuration")
                                                DispatchQueue.main.async {
                                                    self.timeButton.setTitle(formatedDurationText, for: .normal)
                                                    self.progressBar.progress = 1
                                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                }
                                            }
                                        }
                                        
                                        if let status = inElements["status"] as? String {
                                            if status == "ZERO_RESULTS" {
                                                UserDefaults.standard.set("", forKey: "savedDistance")
                                                UserDefaults.standard.set("", forKey: "savedDuration")
                                                DispatchQueue.main.async {
                                                    self.distanceButton.setTitle("", for: .normal)
                                                    self.timeButton.setTitle("", for: .normal)
                                                    self.progressBar.progress = 1
                                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        return
                    }
                }
            }
        }
        task.resume()
    }
    
    func searchCity() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        searchCity()
    }
    
    @IBAction func UVIndexButton(_ sender: UIButton) {
        WeatherUndergroundJSON(distanceJSON: true)
    }
    
    @IBAction func tempButton(_ sender: UIButton) {
        
    }
    
    @IBAction func windButton(_ sender: UIButton) {
        
    }
    
    @IBAction func distanceButton(_ sender: UIButton) {
        
    }
    
    
    @IBAction func timeButton(_ sender: UIButton) {
        let regionDistance: CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(Double(searchLatitude)!, Double(searchLongitude)!)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = UserDefaults.standard.object(forKey: "savedSearchCityName") as? String
        mapItem.openInMaps(launchOptions: options)
    }
}

extension SearchViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        searchLatitude = String(place.coordinate.latitude)
        searchLongitude = String(place.coordinate.longitude)
        UserDefaults.standard.set(searchLatitude, forKey: "savedSearchLatitude")
        UserDefaults.standard.set(searchLongitude, forKey: "savedSearchLongitude")
        dismiss(animated: true, completion: nil)
        WeatherUndergroundJSON(distanceJSON: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
