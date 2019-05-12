//
//  Utilities.swift
//  UV Safe
//
//  Created by Shawn Patel on 5/11/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class NetworkCalls {
    
    /*let APIKeys = ["8578e6219f5a0317", "9b13cd2abe7021ac", "e0b3dccaac724dcf", "5aacfe2a581db8d9", "c01a9d84445503bb"]
     let randomAPIKey = Int(arc4random_uniform(UInt32(APIKey.count)))*/
    
    static let openWeatherMapAPIKey = "6a58932e63b48033343af20d04c41dc4"
    static let googlePlaceAPIKey = "AIzaSyC0AbgywK_k1ODP1kheexnBPaa12d-Qkog"
    
    static func getUVIndex(_ latitude: String,_ longitude: String, completion: @escaping (Result<Int>) -> Void) {
        
        let url = "https://api.openweathermap.org/data/2.5/uvi?appid=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)"
        
        Alamofire.request(url).responseJSON { response in
            
            if response.error != nil {
                completion(.failure(response.error!))
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                let UVIndexInt = Int(json["value"].doubleValue.rounded())
                
                completion(.success(UVIndexInt))
            }
        }
    }
    
    static func getWeather(_ latitude: String,_ longitude: String,_ units: Int, completion: @escaping (Result<NSDictionary>) -> Void) {
        
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)"
        
        Alamofire.request(url).responseJSON { response in
            
            if response.error != nil {
                completion(.failure(response.error!))
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                let city = json["name"].stringValue
                let country = json["sys"]["country"].stringValue
                
                var temp = json["main"]["temp"].doubleValue
                if units == 0 {
                    temp = ((temp - 273.15) * 9/5 + 32).rounded()
                } else if units == 1 {
                    temp = (temp - 273.15).rounded()
                }
                
                var wind = json["wind"]["speed"].doubleValue
                if units == 0 {
                    wind = (wind * 2.237).rounded()
                } else if units == 1 {
                    wind = (wind * 3.6).rounded()
                }
                
                let conditions = json["weather"].arrayObject![0] as! [String : Any]
                
                let description = (conditions["description"] as! String).capitalized
                let icon = (conditions["icon"] as! String).filter("0123456789".contains)
                
                let weatherData: NSDictionary = [
                    "city" : "\(city), \(country)",
                    "temp" : Int(temp),
                    "wind" : Int(wind),
                    "conditions" : description,
                    "icon" : icon
                ]
                
                completion(.success(weatherData))
            }
        }
    }
    
    static func getTravelStatus(_ latitude: String,_ longitude: String,_ searchLatitude: String,_ searchLongitude: String,_ units: Int, completion: @escaping (Result<NSDictionary>) -> Void) {
        
        var url: String!
        if units == 0 {
            url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(latitude),\(longitude)&destinations=\(searchLatitude),\(searchLongitude)&key=\(googlePlaceAPIKey)"
        } else if units == 1 {
            url = "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=\(latitude),\(longitude)&destinations=\(searchLatitude),\(searchLongitude)&key=\(googlePlaceAPIKey)"
        }
        
        Alamofire.request(url).responseJSON { response in
            
            if response.error != nil {
                completion(.failure(response.error!))
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                let rows = JSON(json["rows"].arrayObject![0])
                let elements = JSON(rows["elements"].arrayObject![0])
                
                if elements["status"].stringValue != "OK" {
                    completion(.failure(NSLocalizedString(elements["status"].stringValue, comment: "") as! Error))
                }
                
                let distance = elements["distance"]["text"].stringValue
                let duration = elements["duration"]["text"].stringValue.replacingOccurrences(of: "hours", with: "hrs")
                
                let travelData: NSDictionary = [
                    "distance" : distance,
                    "duration" : duration
                ]
                
                completion(.success(travelData))
            }
        }
    }
    
    /*func distanceToCityJSON() {
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
    }*/
}
