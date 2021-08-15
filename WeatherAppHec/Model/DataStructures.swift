//
//  DataStructures.swift
//  WeatherAppHec
//
//  Created by HECTOR TERRERO on 8/15/21.
//

import Foundation
import UIKit


// MARK: - DATA STRUCTURES
struct openWeatherMapData: Codable{
    let lat: Float
    let lon: Float
    let timezone: String
    let timezone_offset: Float
    let current: CurrentWeather
    let hourly: [HourlyWeatherItem]
    let daily: [DailyWeatherItem]
}
struct CurrentWeather: Codable  {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feels_like: Double
    let pressure: Double
    let humidity: Double
    let dew_point: Double
    let uvi: Double
    let clouds: Double
    let visibility: Double
    let wind_speed: Double
    let wind_deg: Double
//    let rain: RainWeather
//    let snow: SnowWeather
    let weather: [WeatherWeather]
    
}
//struct RainWeather: Codable {
//    let the1h: Double
//
//    enum CodingKeys: String, CodingKey {
//            case the1H = "1h"
//        }
//
//}
//struct SnowWeather: Codable {
//    let t1h: Double
//
//    enum CodingKeys: String, CodingKey {
//            case the1H = "1h"
//        }
//}
struct WeatherWeather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
//struct HourlyWeather: Codable {
//    let data: [HourlyWeatherItem]
//
//}
struct HourlyWeatherItem: Codable {
    let dt: Int
    let temp: Double
    let feels_like: Double
    let pressure: Double
    let humidity: Double
    let dew_point: Double
    let uvi: Double
    let clouds: Double
    let visibility: Double
    let wind_speed: Double
    let wind_deg: Double
    let wind_gust: Double
    let weather: [WeatherWeather]
    let pop: Double
    
    
}
struct DailyWeatherItem: Codable {
    
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let moonrise: Int
    let moonset: Int
    let moon_phase: Double
    let temp: TempWeather
    let feels_like: Feel_likeWeatherDaily
    let pressure: Double
    let humidity: Double
    let dew_point: Double
    let wind_speed: Double
    let wind_deg: Double
    let weather: [WeatherWeather]
    let clouds: Double
    let pop: Double
//    let rain: Double
    let uvi: Double
    
}
struct TempWeather: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}
struct Feel_likeWeatherDaily: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
    
    
}



