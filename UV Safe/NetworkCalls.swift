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
    
    static let APIKey = "6a58932e63b48033343af20d04c41dc4"
    
    static func getUVIndex(_ latitude: String,_ longitude: String, completion: @escaping (Result<Int>) -> Void) {
        
        let UVIndexURL = "https://api.openweathermap.org/data/2.5/uvi?appid=\(APIKey)&lat=\(latitude)&lon=\(longitude)"
        
        Alamofire.request(UVIndexURL).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                
                let UVIndexInt = Int(json["value"].doubleValue.rounded())
                
                completion(.success(UVIndexInt))
            }
        }
    }
    
    static func getWeather(_ latitude: String,_ longitude: String,_ units: Int, completion: @escaping (Result<NSDictionary>) -> Void) {
        
        let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(APIKey)&lat=\(latitude)&lon=\(longitude)"
        
        Alamofire.request(weatherURL).responseJSON { response in
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
}
