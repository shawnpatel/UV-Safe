//
//  HomeViewController.swift
//  UV Safe
//
//  Created by Shawn Patel on 6/20/17.
//  Copyright © 2017 Shawn Patel. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

import GooglePlaces
import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    enum Section: Int, CaseIterable {
        
        case cells
        
        enum NibName: String, CaseIterable {
            case LocationCell
            case UVIndexCell
            case TemperatureCell
            case WeatherDescriptionCell
            case ReminderCell
        }
        
        enum Identifier: String, CaseIterable {
            case location
            case uvIndex
            case temperature
            case weatherDescription
            case reminder
        }
        
        enum Cells: Int, CaseIterable {
            case location
            case uvIndex
            case temperature
            case weatherDescription
            case reminder
        }
    }
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var units: Int!
    
    var startStop = false
    var seconds = 5400
    var timer = Timer()
    
    var locationManager: CLLocationManager!
    var latitude = ""
    var longitude = ""
    var canCall = true
    
    var CELL_WIDTH: CGFloat {
        return collectionView.frame.width - 20
    }
    
    var CELL_BOX_SIZE: CGFloat {
        return collectionView.frame.width / 2 - 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.overrideUserInterfaceStyle = .dark
        
        registerNibs()
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(HomeViewController.movedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(HomeViewController.movedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        progressBar.tintColor = Constants.UV_SAFE_YELLOW
        progressBar.progressTintColor = Constants.UV_SAFE_RED
        
        getCurrentLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        movedToForeground()
    }
    
    @objc func movedToForeground() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        DispatchQueue.main.async {
            if let checkStartStop = UserDefaults.standard.object(forKey: "savedStartStop") as? Bool {
                self.startStop = checkStartStop
                if self.startStop == false {
                    //self.startStopButton.setTitle("Remind Me!", for: .normal)
                } else if self.startStop == true {
                    //self.startStopButton.setTitle("Cancel", for: .normal)
                    self.seconds = UserDefaults.standard.integer(forKey: "savedSeconds")
                    let newTimestamp = Int(Date().timeIntervalSince1970)
                    if let savedTimestamp = UserDefaults.standard.object(forKey: "savedTimestamp") as? Int {
                        let secondsDifference = newTimestamp - savedTimestamp
                        if self.seconds - secondsDifference > 0 {
                            self.seconds -= secondsDifference
                            self.startTimer()
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            self.triggerNotification(whenToSend: self.seconds)
                        } else if self.seconds - secondsDifference <= 0 && self.seconds - secondsDifference >= -86400 {
                            let alertController = UIAlertController(title: "Are you still in the sun?", message: "It has been 90 minutes or more since you last applied sunscreen. Would you like to set a new reminder?", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                                self.resetTimer()
                                UserDefaults.standard.set(false, forKey: "savedStartStop")
                            }))
                            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                                self.seconds = 5400
                                self.timer.invalidate()
                                self.startTimer()
                                self.triggerNotification(whenToSend: 5400)
                            }))
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            self.resetTimer()
                            UserDefaults.standard.set(false, forKey: "savedStartStop")
                            
                            let alertController = UIAlertController(title: "Where have you been?", message: "Its been more than a day since you enabled the sunscreen reminder. It has been automatically reset.", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        movedToBackground()
    }
    
    @objc func movedToBackground() {
        if startStop == true {
            timer.invalidate()
            UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: "savedTimestamp")
        }
    }
    
    func getCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0] as CLLocation
        latitude = "\(userLocation.coordinate.latitude)"
        longitude = "\(userLocation.coordinate.longitude)"
        
        UserDefaults.standard.set(latitude, forKey: "savedLatitude")
        UserDefaults.standard.set(longitude, forKey: "savedLongitude")
        
        manager.stopUpdatingLocation()
        getWeatherInfo()
    }
    
    func getWeatherInfo() {
        if canCall {
            canCall = false
            updateWeatherInfo()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
        /*self.cityLabel.text = "Enable Location Services!"
        self.tempButton.isEnabled = false
        self.windButton.isEnabled = false
        self.startStopButton.isEnabled = false*/
        progressBar.progress = 1
    }
    
    func updateWeatherInfo() {
        units = UserDefaults.standard.integer(forKey: "units")
        
        progressBar.progress = 0
        
        NetworkCalls.getWeatherbitUVIndex(latitude, longitude) { response in
            
            if response.isFailure {
                let alert = AlertService.alert(message: response.error!.localizedDescription)
                self.present(alert, animated: true)
            }
            
            if let UVIndex = response.value {
                UserDefaults.standard.set(UVIndex, forKey: "savedUVIndexInt")
                UserDefaults.standard.set(String(UVIndex) + " UVI", forKey: "savedUVIndex")
            }
        }
        
        NetworkCalls.getWeather(latitude, longitude, units) { response in
            
            if response.isFailure {
                let alert = AlertService.alert(message: response.error!.localizedDescription)
                self.present(alert, animated: true)
            }
            
            if let weatherData = response.value {
                UserDefaults.standard.set(weatherData["city"] as! String, forKey: "savedCityName")
                
                if self.units == 0 {
                    UserDefaults.standard.set(String(weatherData["temp"] as! Int) + " °F", forKey: "savedTemp")
                    UserDefaults.standard.set(String(weatherData["minTemp"] as! Int) + " °F", forKey: "savedMinTemp")
                    UserDefaults.standard.set(String(weatherData["maxTemp"] as! Int) + " °F", forKey: "savedMaxTemp")
                } else if self.units == 1{
                    UserDefaults.standard.set(String(weatherData["temp"] as! Int) + " °C", forKey: "savedTemp")
                    UserDefaults.standard.set(String(weatherData["minTemp"] as! Int) + " °C", forKey: "savedMinTemp")
                    UserDefaults.standard.set(String(weatherData["maxTemp"] as! Int) + " °C", forKey: "savedMaxTemp")
                }
                
                UserDefaults.standard.set(weatherData["conditions"] as! String, forKey: "savedWeather")
                UserDefaults.standard.set(weatherData["icon"] as! String, forKey: "savedIconString")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(0 ..< Section.allCases.count))
                }
            }
            
            self.progressBar.progress = 1
        }
    }
    
    @objc func updateTimer() {
        seconds -= 1
        if seconds == 0 {
            let alertController = UIAlertController(title: "Are you still in the sun?", message: "It has been 90 minutes or more since you last applied sunscreen. Would you like to set a new reminder?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                self.resetTimer()
                UserDefaults.standard.set(false, forKey: "savedStartStop")
            }))
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.seconds = 5400
                self.timer.invalidate()
                self.startTimer()
                self.triggerNotification(whenToSend: 5400)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        let minutes = seconds / 60
        //timeLabel.text = String(minutes) + " mins"
        UserDefaults.standard.set(seconds, forKey: "savedSeconds")
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HomeViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func resetTimer() {
        self.timer.invalidate()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        self.startStop = false
        //self.startStopButton.setTitle("Remind Me!", for: .normal)
        UserDefaults.standard.set(self.startStop, forKey: "savedStartStop")
        self.seconds = 5400
        UserDefaults.standard.set(self.seconds, forKey: "savedSeconds")
        //self.timeLabel.text = "90 mins"
    }
    
    func startTimer() {
        startStop = true
        //startStopButton.setTitle("Cancel", for: .normal)
        runTimer()
        UserDefaults.standard.set(startStop, forKey: "savedStartStop")
    }
    
    func triggerNotification(whenToSend: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Apply Sunscreen!"
        content.body = "It has been 90 minutes since you last applied suncreen. Apply another coating of sunscreen then set another reminder by opening UV Safe."
        content.badge = 1
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(whenToSend), repeats: false)
        let request = UNNotificationRequest(identifier: "Reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @IBAction func startStopButton(_ sender: UIButton) {
        if startStop == false {
            // Stop -> Start
            
            let UVIndex = UserDefaults.standard.object(forKey: "savedUVIndexInt") as? Int
            if UVIndex! <= 2 {
                let alertController = UIAlertController(title: "Are you sure?", message: "The UV Index is 0-2, which is a safe level. You only need to apply sunscreen if your skin is sensitive to the sun. Do you wish to continue?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                    self.startStop = false
                    UserDefaults.standard.set(self.startStop, forKey: "savedStartStop")
                }))
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.startStop = true
                    UserDefaults.standard.set(self.startStop, forKey: "savedStartStop")
                    self.startTimer()
                    self.triggerNotification(whenToSend: 5400)
                }))
                self.present(alertController, animated: true, completion: nil)
            } else {
                startStop = true
                UserDefaults.standard.set(self.startStop, forKey: "savedStartStop")
                startTimer()
                triggerNotification(whenToSend: 5400)
            }
        } else if startStop == true {
            // Start -> Stop
            
            let alertController = UIAlertController(title: "Are you sure?", message: "By pressing 'Stop', the sunscreen timer will reset. Are you sure you want to continue?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.startStop = false
                UserDefaults.standard.set(self.startStop, forKey: "savedStartStop")
                self.resetTimer()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private func registerNibs() {
        for i in 0 ..< Section.NibName.allCases.count {
            let nib = UINib(nibName: Section.NibName.allCases[i].rawValue, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: Section.Identifier.allCases[i].rawValue)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else {
            print("Cannot find section at index \(section).")
            return 0
        }
        
        switch sectionType {
            case .cells:
                return Section.Cells.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let row = Section.Cells(rawValue: indexPath.row) else {
            print("Cannot find section at index \(indexPath.section).")
            return UICollectionViewCell()
        }
        
        switch row {
            case .location:
                return cellForLocationSection(indexPath: indexPath)
                
            case .uvIndex:
                return cellForUVIndexSection(indexPath: indexPath)
                
            case .temperature:
                return cellForTemperatureSection(indexPath: indexPath)
                
            case .weatherDescription:
                return cellForWeatherDescriptionSection(indexPath: indexPath)
                
            case .reminder:
                return cellForReminderSection(indexPath: indexPath)
        }
    }
    
    private func cellForLocationSection(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.location.rawValue,
                                                      for: indexPath) as! LocationCell
        cell.setWidth(to: CELL_BOX_SIZE)
        cell.setHeight(to: CELL_BOX_SIZE)
        
        if let latitude = Double(UserDefaults.standard.string(forKey: "savedLatitude") ?? ""),
           let longitude = Double(UserDefaults.standard.string(forKey: "savedLongitude") ?? "") {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            cell.setLocation(to: coordinate)
        }
        
        if let cityAndCountry = UserDefaults.standard.string(forKey: "savedCityName") {
            let split = cityAndCountry.split(separator: ",")
            let city = String(split[0])
            let country = String(split[1])
            
            cell.city.text = city
            cell.country.text = country
        }
        
        return cell
    }
    
    private func cellForUVIndexSection(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.uvIndex.rawValue,
                                                      for: indexPath) as! UVIndexCell
        cell.setWidth(to: CELL_BOX_SIZE)
        cell.setHeight(to: CELL_BOX_SIZE)
        
        let uvIndex = UserDefaults.standard.integer(forKey: "savedUVIndexInt")
        cell.uvIndex.text = String(uvIndex)
        
        return cell
    }
    
    private func unitsChanged() {
        updateWeatherInfo()
    }
    
    private func cellForTemperatureSection(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.temperature.rawValue,
                                                      for: indexPath) as! TemperatureCell
        cell.setWidth(to: CELL_BOX_SIZE)
        cell.setHeight(to: CELL_BOX_SIZE)
        
        cell.unitsChanged = self.unitsChanged
        
        let unitIndex = UserDefaults.standard.integer(forKey: "units")
        cell.unitSegment.selectedSegmentIndex = unitIndex
        
        if let currentTemp = UserDefaults.standard.string(forKey: "savedTemp") {
            cell.currentTemp.text = currentTemp
        }
        
        if let minTemp = UserDefaults.standard.string(forKey: "savedMinTemp") {
            cell.lowTemp.text = "L: \(minTemp)"
        }
        
        if let maxTemp = UserDefaults.standard.string(forKey: "savedMaxTemp") {
            cell.highTemp.text = "H: \(maxTemp)"
        }
        
        return cell
    }
    
    private func cellForWeatherDescriptionSection(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.weatherDescription.rawValue,
                                                      for: indexPath) as! WeatherDescriptionCell
        cell.setWidth(to: CELL_BOX_SIZE)
        cell.setHeight(to: CELL_BOX_SIZE)
        
        if let details = UserDefaults.standard.string(forKey: "savedWeather") {
            cell.details.text = details
        }
        
        if let icon = UserDefaults.standard.string(forKey: "savedIconString") {
            cell.icon.image = UIImage(named: icon)
        }
        
        return cell
    }
    
    private func cellForReminderSection(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.reminder.rawValue,
                                                      for: indexPath) as! ReminderCell
        cell.setWidth(to: CELL_WIDTH)
        cell.setHeight(to: CELL_BOX_SIZE)
        
        let uvIndex = UserDefaults.standard.integer(forKey: "savedUVIndexInt")
        
        cell.updateChart(uvIndex: uvIndex)
        
        return cell
    }
}

extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    @IBAction func searchButton(_ sender: Any) {
        self.searchCity()
    }
    
    private func searchCity() {
        let autocompleteController = GMSAutocompleteViewController()
        
        autocompleteController.tableCellBackgroundColor = .black
        autocompleteController.delegate = self
        
        autocompleteController.overrideUserInterfaceStyle = .dark
        
        self.present(autocompleteController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let searchLatitude = String(place.coordinate.latitude)
        let searchLongitude = String(place.coordinate.longitude)
        
        UserDefaults.standard.set(searchLatitude, forKey: "savedSearchLatitude")
        UserDefaults.standard.set(searchLongitude, forKey: "savedSearchLongitude")
        
        self.dismiss(animated: true) {
            self.performSegue(withIdentifier: "homeToSearch", sender: nil)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
