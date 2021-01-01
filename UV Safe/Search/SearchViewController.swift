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
            }
            self.UVIndexButton.setTitle(UserDefaults.standard.object(forKey: "savedSearchUVIndex") as? String, for: .normal)
            if let UVIndex = UserDefaults.standard.object(forKey: "savedSearchUVIndexInt") as? Int {
                self.updateUVIndexColor(index: UVIndex)
            }
            self.tempButton.setTitle(UserDefaults.standard.object(forKey: "savedSearchTemp") as? String, for: .normal)
            self.windButton.setTitle(UserDefaults.standard.object(forKey: "savedSearchWind") as? String, for: .normal)
            self.conditionsText.text = UserDefaults.standard.object(forKey: "savedSearchWeather") as? String
            self.distanceButton.setTitle(UserDefaults.standard.object(forKey: "savedDistance") as? String, for: .normal)
            self.timeButton.setTitle(UserDefaults.standard.object(forKey: "savedDuration") as? String, for: .normal)
            if let iconString = UserDefaults.standard.object(forKey: "savedSearchIconString") as? String {
                self.conditionsImage.image = UIImage(named: iconString)
            }
            if let lat = UserDefaults.standard.object(forKey: "savedSearchLatitude") as? String {
                self.searchLatitude = lat
            } else {
                self.searchLatitude = "37.338207"
            }
            if let long = UserDefaults.standard.object(forKey: "savedSearchLongitude") as? String {
                self.searchLongitude = long
            } else {
                self.searchLongitude = "-121.886330"
            }
            if let lat = UserDefaults.standard.object(forKey: "savedLatitude") as? String {
                self.latitude = lat
            }
            if let long = UserDefaults.standard.object(forKey: "savedLongitude") as? String {
                self.longitude = long
            }
            
            self.updateWeatherInfo()
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
        if let contains = self.tempButton.currentTitle?.contains("F") {
            if contains && self.units == 1 {
                self.updateWeatherInfo()
            }
        }
        
        if let contains = self.tempButton.currentTitle?.contains("C") {
            if contains && self.units == 0 {
                self.updateWeatherInfo()
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
    
    func updateWeatherInfo() {
        progressBar.progress = 0
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        NetworkCalls.getWeatherbitUVIndex(searchLatitude, searchLongitude) { response in
            
            if response.isFailure {
                let alert = AlertService.alert(message: response.error!.localizedDescription)
                self.present(alert, animated: true)
            }
            
            if let UVIndex = response.value {
                UserDefaults.standard.set(UVIndex, forKey: "savedSearchUVIndexInt")
                UserDefaults.standard.set(String(UVIndex) + " UVI", forKey: "savedSearchUVIndex")
                
                DispatchQueue.main.async {
                    self.UVIndexButton.setTitle(String(UVIndex) + " UVI", for: .normal)
                    self.updateUVIndexColor(index: UVIndex)
                }
            }
        }
        
        NetworkCalls.getWeather(searchLatitude, searchLongitude, units) { response in
            
            if response.isFailure {
                let alert = AlertService.alert(message: response.error!.localizedDescription)
                self.present(alert, animated: true)
            }
            
            if let weatherData = response.value {
                UserDefaults.standard.set(weatherData["city"] as! String, forKey: "savedSearchCityName")
                
                if self.units == 0 {
                    UserDefaults.standard.set(String(weatherData["temp"] as! Int) + "°F", forKey: "savedSearchTemp")
                    UserDefaults.standard.set(String(weatherData["wind"] as! Int) + " MPH", forKey: "savedSearchWind")
                } else if self.units == 1{
                    UserDefaults.standard.set(String(weatherData["temp"] as! Int) + "°C", forKey: "savedSearchTemp")
                    UserDefaults.standard.set(String(weatherData["wind"] as! Int) + " KPH", forKey: "savedSearchWind")
                }
                
                UserDefaults.standard.set(weatherData["conditions"] as! String, forKey: "savedSearchWeather")
                UserDefaults.standard.set(weatherData["icon"] as! String, forKey: "savedSearchIconString")
                
                DispatchQueue.main.async {
                    self.cityLabel.text = weatherData["city"] as? String
                    
                    self.tempButton.setTitle(UserDefaults.standard.string(forKey: "savedSearchTemp"), for: .normal)
                    self.windButton.setTitle(UserDefaults.standard.string(forKey: "savedSearchWind"), for: .normal)
                    
                    self.conditionsText.text = weatherData["conditions"] as? String
                    self.conditionsImage.image = UIImage(named: weatherData["icon"] as! String)
                }
            }
            
            if self.tempButton.currentTitle?.contains("F") ?? false && self.units == 1 {
                self.updateWeatherInfo()
            } else if self.tempButton.currentTitle?.contains("C") ?? false && self.units == 0 {
                self.updateWeatherInfo()
            } else {
                self.updateTravelInfo()
            }
        }
    }
    
    func updateTravelInfo() {
        NetworkCalls.getTravelStatus(latitude, longitude, searchLatitude, searchLongitude, units) { response in
            
            if response.isFailure {
                let alert = AlertService.alert(message: response.error!.localizedDescription)
                self.present(alert, animated: true)
            }
            
            if let travelData = response.value {
                UserDefaults.standard.set(travelData["distance"] as! String, forKey: "savedDistance")
                UserDefaults.standard.set(travelData["duration"] as! String, forKey: "savedDuration")
                
                DispatchQueue.main.async {
                    self.distanceButton.setTitle(travelData["distance"] as? String, for: .normal)
                    self.timeButton.setTitle(travelData["duration"] as? String, for: .normal)
                }
            }
            
            self.progressBar.progress = 1
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func updateUVIndexColor(index: Int) {
        if index >= 0 && index <= 2{
            UVIndexButton.setTitleColor(.green, for: .normal)
        } else if index >= 3 && index <= 5 {
            UVIndexButton.setTitleColor(.yellow, for: .normal)
        } else if index >= 6 && index <= 7 {
            UVIndexButton.setTitleColor(.orange, for: .normal)
        } else if index >= 8 && index <= 10 {
            UVIndexButton.setTitleColor(.red, for: .normal)
        } else if index >= 11 {
            UVIndexButton.setTitleColor(.purple, for: .normal)
        }
    }
    
    func searchCity() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        if #available(iOS 13.0, *) {
            autocompleteController.overrideUserInterfaceStyle = .light
        }
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        searchCity()
    }
    
    @IBAction func UVIndexButton(_ sender: UIButton) {
        self.updateWeatherInfo()
    }
    
    @IBAction func timeButton(_ sender: UIButton) {
        let regionDistance: CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(Double(searchLatitude)!, Double(searchLongitude)!)
        let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
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
        self.updateWeatherInfo()
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
