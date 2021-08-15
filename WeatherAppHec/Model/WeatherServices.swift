//
//  WeatherServices.swift
//  WeatherAppHec
//
//  Created by HECTOR TERRERO on 8/15/21.
//

import Foundation
import CoreLocation


class WeatherServices {
    
    let apiKey = "00e968e72670c774ac30090f73fb5664"
    let exclusions = "minutely,alerts"
    
    
    

    
    
    //Does request call to the OpenWeathermap API with a completion handler to update UI related objects
    func requestWeatherForLocation(location: CLLocation?, completion: @escaping (openWeatherMapData?)->()) {
        guard let currentLocation = location else {return}
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(lat)&lon=\(long)&units=imperial&exclude=\(exclusions)&appid=\(apiKey)"
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            //validation
            
            guard let data = data, error == nil else {
                print ("something went wrong")
                
                return }
            
            
            
            //convert data to models/someobjects
            
            var json: openWeatherMapData?
            
            do{
                json = try  JSONDecoder().decode(openWeatherMapData.self, from: data)
            }
            catch {
                print ("error \(error)")
            }
            
            guard let result = json else {
                return
            }
            
            completion(result)
            
            //update user interface
        }).resume()
        
    }

    
}
