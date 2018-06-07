//
//  HomeViewController.swift
//  UV Safe
//
//  Created by Sapna Patel on 6/20/17.
//  Copyright © 2017 Sapna Patel. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import GoogleMobileAds

class HomeViewController: UIViewController, CLLocationManagerDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var UVIndexButton: UIButton!
    @IBOutlet weak var tempButton: UIButton!
    @IBOutlet weak var windButton: UIButton!
    @IBOutlet weak var conditionsImage: UIImageView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var interstitial: GADInterstitial!
    
    var tempUnit = false
    var windUnit = false
    
    var startStop = false
    var seconds = 5400
    var timer = Timer()
    
    var locationManager: CLLocationManager!
    var latitude = ""
    var longitude = ""
    var canCall = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = createAndLoadInterstitial()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(HomeViewController.movedToBackground), name: .UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(HomeViewController.movedToForeground), name: .UIApplicationDidBecomeActive, object: nil)
        
        DispatchQueue.main.async {
            self.cityLabel.text = UserDefaults.standard.object(forKey: "savedCityName") as? String
            self.UVIndexButton.setTitle(UserDefaults.standard.object(forKey: "savedUVIndex") as? String, for: .normal)
            self.tempButton.setTitle(UserDefaults.standard.object(forKey: "savedTemp") as? String, for: .normal)
            self.windButton.setTitle(UserDefaults.standard.object(forKey: "savedWind") as? String, for: .normal)
            if let iconString = UserDefaults.standard.object(forKey: "savedIconString") as? String {
                self.conditionsImage.image = UIImage(named: iconString)
            }
        }
        
        if let checkTempUnit = UserDefaults.standard.object(forKey: "savedTempUnit") as? Bool {
            tempUnit = checkTempUnit
        }
        if let checkWindUnit = UserDefaults.standard.object(forKey: "savedWindUnit") as? Bool {
            windUnit = checkWindUnit
        }
        
        self.UVIndexButton.titleLabel?.numberOfLines = 1
        self.UVIndexButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.UVIndexButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        
        self.tempButton.titleLabel?.numberOfLines = 1
        self.tempButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.tempButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        
        self.windButton.titleLabel?.numberOfLines = 1
        self.windButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.windButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        
        getCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 243/255, green: 178/255, blue: 41/255, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.tabBarController?.tabBar.barTintColor = UIColor(red: 243/255, green: 178/255, blue: 41/255, alpha: 1)
        self.tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.tabBarController?.tabBar.isTranslucent = false
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
                    self.startStopButton.setTitle("Remind Me!", for: .normal)
                } else if self.startStop == true {
                    self.startStopButton.setTitle("Cancel", for: .normal)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        callWeatherUndergroundJSON()
    }
    
    func callWeatherUndergroundJSON() {
        if canCall {
            canCall = false
            WeatherUndergroundJSON()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
        self.cityLabel.text = "Enable Location Services!"
        self.tempButton.isEnabled = false
        self.windButton.isEnabled = false
        self.startStopButton.isEnabled = false
        progressBar.progress = 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func WeatherUndergroundJSON() {
        progressBar.progress = 0
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let APIKey = ["8578e6219f5a0317", "9b13cd2abe7021ac", "e0b3dccaac724dcf", "5aacfe2a581db8d9", "c01a9d84445503bb"]
        let randomAPIKey = Int(arc4random_uniform(UInt32(APIKey.count)))
        let url = URL(string: "https://api.wunderground.com/api/" + APIKey[randomAPIKey] + "/conditions/q/" + latitude + "," + longitude + ".json")
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
                                    UserDefaults.standard.set(cityName, forKey: "savedCityName")
                                    DispatchQueue.main.async {
                                        self.cityLabel.text = cityName
                                    }
                                }
                            }
                            
                            if let UVIndexString = currentObservation["UV"] as? String {
                                if let UVIndexDouble = Double(UVIndexString) {
                                    let UVIndexInt = Int(UVIndexDouble)
                                    var UVIndexStringInt = String(UVIndexInt)
                                    if UVIndexStringInt == "-1" {
                                        UVIndexStringInt = "N/A"
                                    }
                                    UserDefaults.standard.set(UVIndexInt, forKey: "savedUVIndexInt")
                                    UserDefaults.standard.set(UVIndexStringInt + " UV", forKey: "savedUVIndex")
                                    DispatchQueue.main.async {
                                        self.UVIndexButton.setTitle(UVIndexStringInt + " UV", for: .normal)
                                    }
                                }
                            }
                            
                            if self.tempUnit == false {
                                if let tempF = currentObservation["temp_f"] {
                                    let tempFString = String(format: "%.0f", Double(String(describing: tempF))!)
                                    UserDefaults.standard.set(tempFString + "°F", forKey: "savedTemp")
                                    DispatchQueue.main.async {
                                        self.tempButton.setTitle(String(tempFString) + "°F", for: .normal)
                                    }
                                }
                            } else if self.tempUnit == true {
                                if let tempC = currentObservation["temp_c"] {
                                    let tempCString = String(format: "%.0f", Double(String(describing: tempC))!)
                                    UserDefaults.standard.set(tempCString + "°C", forKey: "savedTemp")
                                    DispatchQueue.main.async {
                                        self.tempButton.setTitle(tempCString + "°C", for: .normal)
                                    }
                                }
                            }
                            
                            if self.windUnit == false {
                                if let windMPH = currentObservation["wind_mph"] {
                                    let windMPHString = String(format: "%.0f", Double(String(describing: windMPH))!)
                                    UserDefaults.standard.set(windMPHString + " MPH", forKey: "savedWind")
                                    DispatchQueue.main.async {
                                        self.windButton.setTitle(windMPHString + " MPH", for: .normal)
                                    }
                                }
                            } else if self.windUnit == true {
                                if let windKPH = currentObservation["wind_kph"] {
                                    let windKPHString = String(format: "%.0f", Double(String(describing: windKPH))!)
                                    UserDefaults.standard.set(windKPHString + " KPH", forKey: "savedWind")
                                    DispatchQueue.main.async {
                                        self.windButton.setTitle(windKPHString + " KPH", for: .normal)
                                    }
                                }
                            }
                            
                            if let iconString = currentObservation["icon"] as? String {
                                UserDefaults.standard.set(iconString, forKey: "savedIconString")
                                DispatchQueue.main.async {
                                    self.conditionsImage.image = UIImage(named: iconString)
                                    self.progressBar.progress = 1
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    @IBAction func UVIndexButton(_ sender: UIButton) {
        canCall = true
        getCurrentLocation()
    }
    
    @IBAction func tempButton(_ sender: UIButton) {
        if tempUnit == true {
            // C -> F
            tempUnit = false
        } else if tempUnit == false {
            // F -> C
            tempUnit = true
        }
        UserDefaults.standard.set(tempUnit, forKey: "savedTempUnit")
        WeatherUndergroundJSON()
    }
    
    @IBAction func windButton(_ sender: UIButton) {
        if windUnit == true {
            // KPH -> MPH
            windUnit = false
        } else if windUnit == false {
            // MPH -> KPH
            windUnit = true
        }
        UserDefaults.standard.set(windUnit, forKey: "savedWindUnit")
        WeatherUndergroundJSON()
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
        let minutes = seconds/60
        timeLabel.text = String(minutes) + " mins"
        UserDefaults.standard.set(seconds, forKey: "savedSeconds")
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(HomeViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func resetTimer() {
        self.timer.invalidate()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        self.startStop = false
        self.startStopButton.setTitle("Remind Me!", for: .normal)
        UserDefaults.standard.set(self.startStop, forKey: "savedStartStop")
        self.seconds = 5400
        UserDefaults.standard.set(self.seconds, forKey: "savedSeconds")
        self.timeLabel.text = "90 mins"
    }
    
    func startTimer() {
        startStop = true
        startStopButton.setTitle("Cancel", for: .normal)
        runTimer()
        UserDefaults.standard.set(startStop, forKey: "savedStartStop")
    }
    
    func triggerNotification(whenToSend: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Apply Sunscreen!"
        content.body = "It has been 90 minutes since you last applied suncreen. Apply another coating of sunscreen then set another reminder by opening UV Safe."
        content.badge = 1
        content.sound = UNNotificationSound.default()
        
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
                    
                    // Load Ad
                    self.showAd()
                }))
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.startStop = true
                    UserDefaults.standard.set(self.startStop, forKey: "savedStartStop")
                    self.startTimer()
                    self.triggerNotification(whenToSend: 5400)
                    
                    // Load Ad
                    self.showAd()
                }))
                self.present(alertController, animated: true, completion: nil)
            } else {
                startStop = true
                UserDefaults.standard.set(self.startStop, forKey: "savedStartStop")
                startTimer()
                triggerNotification(whenToSend: 5400)
                
                // Load Ad
                showAd()
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
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-5075997087510380/2496743086")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func showAd() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready!")
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
}
