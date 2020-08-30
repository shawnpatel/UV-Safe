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

import Alamofire
import SwiftyJSON

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var UVIndexButton: UIButton!
    @IBOutlet weak var tempButton: UIButton!
    @IBOutlet weak var windButton: UIButton!
    @IBOutlet weak var conditionsImage: UIImageView!
    @IBOutlet weak var conditionsText: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    var units: Int!
    
    var startStop = false
    var seconds = 5400
    var timer = Timer()
    
    var locationManager: CLLocationManager!
    var latitude = ""
    var longitude = ""
    var canCall = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(HomeViewController.movedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(HomeViewController.movedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        DispatchQueue.main.async {
            self.cityLabel.text = UserDefaults.standard.object(forKey: "savedCityName") as? String
            self.UVIndexButton.setTitle(UserDefaults.standard.object(forKey: "savedUVIndex") as? String, for: .normal)
            if let UVIndex = UserDefaults.standard.object(forKey: "savedUVIndexInt") as? Int {
                self.updateUVIndexColor(index: UVIndex)
            }
            self.tempButton.setTitle(UserDefaults.standard.object(forKey: "savedTemp") as? String, for: .normal)
            self.windButton.setTitle(UserDefaults.standard.object(forKey: "savedWind") as? String, for: .normal)
            self.conditionsText.text = UserDefaults.standard.object(forKey: "savedWeather") as? String
            if let iconString = UserDefaults.standard.object(forKey: "savedIconString") as? String {
                self.conditionsImage.image = UIImage(named: iconString)
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
        
        self.startStopButton.titleLabel?.numberOfLines = 1
        self.startStopButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.startStopButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        
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
        
        units = UserDefaults.standard.integer(forKey: "units")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        movedToForeground()
        
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
        self.cityLabel.text = "Enable Location Services!"
        self.tempButton.isEnabled = false
        self.windButton.isEnabled = false
        self.startStopButton.isEnabled = false
        progressBar.progress = 1
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func updateWeatherInfo() {
        progressBar.progress = 0
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        NetworkCalls.getWeatherbitUVIndex(latitude, longitude) { response in
            
            if response.isFailure {
                let alert = AlertService.alert(message: response.error!.localizedDescription)
                self.present(alert, animated: true)
            }
            
            if let UVIndex = response.value {
                UserDefaults.standard.set(UVIndex, forKey: "savedUVIndexInt")
                UserDefaults.standard.set(String(UVIndex) + " UVI", forKey: "savedUVIndex")
                
                DispatchQueue.main.async {
                    self.UVIndexButton.setTitle(String(UVIndex) + " UVI", for: .normal)
                    self.updateUVIndexColor(index: UVIndex)
                }
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
                    UserDefaults.standard.set(String(weatherData["temp"] as! Int) + "°F", forKey: "savedTemp")
                    UserDefaults.standard.set(String(weatherData["wind"] as! Int) + " MPH", forKey: "savedWind")
                } else if self.units == 1{
                    UserDefaults.standard.set(String(weatherData["temp"] as! Int) + "°C", forKey: "savedTemp")
                    UserDefaults.standard.set(String(weatherData["wind"] as! Int) + " KPH", forKey: "savedWind")
                }
                
                UserDefaults.standard.set(weatherData["conditions"] as! String, forKey: "savedWeather")
                UserDefaults.standard.set(weatherData["icon"] as! String, forKey: "savedIconString")
                
                DispatchQueue.main.async {
                    self.cityLabel.text = weatherData["city"] as? String
                    
                    self.tempButton.setTitle(UserDefaults.standard.string(forKey: "savedTemp"), for: .normal)
                    self.windButton.setTitle(UserDefaults.standard.string(forKey: "savedWind"), for: .normal)
                    
                    self.conditionsText.text = weatherData["conditions"] as? String
                    self.conditionsImage.image = UIImage(named: weatherData["icon"] as! String)
                }
            }
            
            self.progressBar.progress = 1
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if self.tempButton.currentTitle?.contains("F") ?? false && self.units == 1 {
                self.updateWeatherInfo()
            } else if self.tempButton.currentTitle?.contains("C") ?? false && self.units == 0 {
                self.updateWeatherInfo()
            }
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
    
    @IBAction func UVIndexButton(_ sender: UIButton) {
        canCall = true
        getCurrentLocation()
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
