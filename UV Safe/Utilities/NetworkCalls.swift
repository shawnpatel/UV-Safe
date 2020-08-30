//
//  NetworkCalls.swift
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
    
    static let openWeatherMapAPIKey = APIKeys().OpenWeatherMap
    static let weatherbitAPIKey = APIKeys().WeatherBit
    static let googlePlaceAPIKey = APIKeys().GooglePlaces
    
    static func getOpenWeatherMapUVIndex(_ latitude: String,_ longitude: String, completion: @escaping (Result<Int>) -> Void) {
        
        let url = "https://api.openweathermap.org/data/2.5/uvi?appid=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)"
        
        Alamofire.request(url).responseJSON { response in
            
            if response.error != nil {
                completion(.failure(NetworkError.noInternetConnection))
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                let UVIndex = Int(json["value"].doubleValue.rounded())
                
                completion(.success(UVIndex))
            }
        }
    }
    
    static func getWeatherbitUVIndex(_ latitude: String,_ longitude: String, completion: @escaping (Result<Int>) -> Void) {
        
        let url = "https://api.weatherbit.io/v2.0/current?lat=\(latitude)&lon=\(longitude)&key=\(weatherbitAPIKey)"
        
        Alamofire.request(url).responseJSON { response in
            
            if response.error != nil {
                completion(.failure(NetworkError.noInternetConnection))
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                let data = JSON(json["data"].arrayObject?[0] as Any)
                
                let UVIndex = Int(data["uv"].doubleValue.rounded())
                
                completion(.success(UVIndex))
            }
        }
    }
    
    static func getWeather(_ latitude: String,_ longitude: String,_ units: Int, completion: @escaping (Result<NSDictionary>) -> Void) {
        
        let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)"
        
        Alamofire.request(url).responseJSON { response in
            
            if response.error != nil {
                completion(.failure(NetworkError.noInternetConnection))
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
                
                let conditions = JSON(json["weather"].arrayObject?[0] as Any)
                
                let description = conditions["description"].stringValue.capitalized
                let icon = conditions["icon"].stringValue.filter("0123456789".contains)
                
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
                completion(.failure(NetworkError.noInternetConnection))
            }
            
            if let value = response.result.value {
                let json = JSON(value)
                
                let rows = JSON(json["rows"].arrayObject?[0] as Any)
                let elements = JSON(rows["elements"].arrayObject?[0] as Any)
                
                if elements["status"].stringValue != "OK" {
                    completion(.failure(NetworkError.cannotProvideTravelInfo))
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
}
