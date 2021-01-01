//
//  SearchViewController.swift
//  UV Safe
//
//  Created by Sapna Patel on 6/20/17.
//  Copyright © 2017 Sapna Patel. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var units: Int!
    public var latitude: String!
    public var longitude: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        units = UserDefaults.standard.integer(forKey: "units")
    }
    
    func updateWeatherInfo() {
        progressBar.progress = 0
        
        NetworkCalls.getWeatherbitUVIndex(latitude, longitude) { response in
            if response.isFailure {
                let alert = AlertService.alert(message: response.error!.localizedDescription)
                self.present(alert, animated: true)
            }
            
            if let UVIndex = response.value {
                UserDefaults.standard.set(UVIndex, forKey: "savedSearchUVIndexInt")
                UserDefaults.standard.set(String(UVIndex) + " UVI", forKey: "savedSearchUVIndex")
            }
        }
        
        NetworkCalls.getWeather(latitude, longitude, units) { response in
            if response.isFailure {
                let alert = AlertService.alert(message: response.error!.localizedDescription)
                self.present(alert, animated: true)
            }
            
            if let weatherData = response.value {
                UserDefaults.standard.set(weatherData["city"] as! String, forKey: "savedSearchCityName")
                
                if self.units == 0 {
                    UserDefaults.standard.set(String(weatherData["temp"] as! Int) + "°F", forKey: "savedSearchTemp")
                    UserDefaults.standard.set(String(weatherData["minTemp"] as! Int) + " °F", forKey: "savedSearchMinTemp")
                    UserDefaults.standard.set(String(weatherData["maxTemp"] as! Int) + " °F", forKey: "savedSearchMaxTemp")
                } else if self.units == 1{
                    UserDefaults.standard.set(String(weatherData["temp"] as! Int) + "°C", forKey: "savedSearchTemp")
                    UserDefaults.standard.set(String(weatherData["minTemp"] as! Int) + " °C", forKey: "savedSearchMinTemp")
                    UserDefaults.standard.set(String(weatherData["maxTemp"] as! Int) + " °C", forKey: "savedSearchMaxTemp")
                }
                
                UserDefaults.standard.set(weatherData["conditions"] as! String, forKey: "savedSearchWeather")
                UserDefaults.standard.set(weatherData["icon"] as! String, forKey: "savedSearchIconString")
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    
                    UIView.animate(withDuration: 0.5) {
                        self.collectionView.alpha = 1
                    }
                }
            }
        }
    }
}
