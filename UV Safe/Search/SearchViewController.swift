//
//  SearchViewController.swift
//  UV Safe
//
//  Created by Sapna Patel on 6/20/17.
//  Copyright © 2017 Sapna Patel. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        
        case cells
        
        enum NibName: String, CaseIterable {
            case LocationCell
            case UVIndexCell
            case TemperatureCell
            case WeatherDescriptionCell
        }
        
        enum Identifier: String, CaseIterable {
            case location
            case uvIndex
            case temperature
            case weatherDescription
        }
        
        enum Cells: Int, CaseIterable {
            case location
            case uvIndex
            case temperature
            case weatherDescription
        }
    }
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var units: Int!
    public var latitude: String!
    public var longitude: String!
    
    var CELL_BOX_SIZE: CGFloat {
        return collectionView.frame.width / 2 - 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNibs()
        
        popupView.layer.borderWidth = 1
        popupView.layer.borderColor = UIColor.white.cgColor
        popupView.layer.cornerRadius = Constants.CELL_RADIUS
        collectionView.layer.cornerRadius = Constants.CELL_RADIUS
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        self.overrideUserInterfaceStyle = .dark
        collectionView.alpha = 0
        
        units = UserDefaults.standard.integer(forKey: "units")
        latitude = UserDefaults.standard.string(forKey: "savedSearchLatitude") ?? ""
        longitude = UserDefaults.standard.string(forKey: "savedSearchLongitude") ?? ""
        
        updateWeatherInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(frame: view.frame)
        blurView.applyBlur(with: blurEffect)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        blurView.addGestureRecognizer(tap)

        self.view.insertSubview(blurView, belowSubview: popupView)
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
                
                self.progressBar.progress = 1
            }
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismissView()
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        }
    }
    
    private func cellForLocationSection(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.location.rawValue,
                                                      for: indexPath) as! LocationCell
        cell.setWidth(to: ceil(CELL_BOX_SIZE))
        cell.setHeight(to: ceil(CELL_BOX_SIZE))
        
        if let latitude = Double(UserDefaults.standard.string(forKey: "savedSearchLatitude") ?? ""),
           let longitude = Double(UserDefaults.standard.string(forKey: "savedSearchLongitude") ?? "") {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            cell.setLocation(to: coordinate)
        }
        
        if let cityAndCountry = UserDefaults.standard.string(forKey: "savedSearchCityName") {
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
        cell.setWidth(to: floor(CELL_BOX_SIZE))
        cell.setHeight(to: floor(CELL_BOX_SIZE))
        
        let uvIndex = UserDefaults.standard.integer(forKey: "savedSearchUVIndexInt")
        cell.uvIndex.text = String(uvIndex)
        
        return cell
    }
    
    private func cellForTemperatureSection(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.temperature.rawValue,
                                                      for: indexPath) as! TemperatureCell
        cell.setWidth(to: ceil(CELL_BOX_SIZE))
        cell.setHeight(to: ceil(CELL_BOX_SIZE))
        
        cell.currentTempTopConstraint.constant = -16
        
        if let currentTemp = UserDefaults.standard.string(forKey: "savedSearchTemp") {
            cell.currentTemp.text = currentTemp
        }
        
        if let minTemp = UserDefaults.standard.string(forKey: "savedSearchMinTemp") {
            cell.lowTemp.text = "L: \(minTemp)"
        }
        
        if let maxTemp = UserDefaults.standard.string(forKey: "savedSearchMaxTemp") {
            cell.highTemp.text = "H: \(maxTemp)"
        }
        
        return cell
    }
    
    private func cellForWeatherDescriptionSection(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Section.Identifier.weatherDescription.rawValue,
                                                      for: indexPath) as! WeatherDescriptionCell
        cell.setWidth(to: floor(CELL_BOX_SIZE))
        cell.setHeight(to: floor(CELL_BOX_SIZE))
        
        if let details = UserDefaults.standard.string(forKey: "savedSearchWeather") {
            cell.details.text = details
        }
        
        if let icon = UserDefaults.standard.string(forKey: "savedSearchIconString") {
            cell.icon.image = UIImage(named: icon)
        }
        
        return cell
    }   
}
