//
//  ViewController.swift
//  WeatherAppHec
//
//  Created by HECTOR TERRERO on 8/12/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var table: UITableView!
    
    @IBOutlet var currentDateLabel: UILabel!
    
    @IBOutlet var currentIconImage: UIImageView!
    
    @IBOutlet var currentSummaryLabel: UILabel!
    
    @IBOutlet var currentTempLabel: UILabel!
    
    var dailyModels = [DailyWeatherItem]()
    
    var currentInfo: CurrentWeather?
    
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //setup tableview
        configureTableView()
        
        configureNavBar()
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    
    // MARK: - NAV BarConfiguration
    
    func configureNavBar(){

        let barRightBtn = UIBarButtonItem(image: nil, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(permissionBtn))
        barRightBtn.title = "Permission"
        self.navigationItem.rightBarButtonItem = barRightBtn
       
    }
    
    @objc
    func permissionBtn(){
        setupLocation()
    }
    
    
    
    // MARK: - TableView Configuration
    
    func configureTableView(){
        
        //register two cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        
    }
    
    // MARK: - LOCATION
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        
        case .notDetermined:
            print("DOING NOTHING")
        case .restricted:
            print("DOING NOTHING")
        case .denied:
            print("DOING NOTHING")
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {return}
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        let exclusions = "minutely,alerts"
        let apiKey = "00e968e72670c774ac30090f73fb5664"
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
            
            self.currentInfo = result.current
            let entries = result.daily
            self.dailyModels.append(contentsOf: entries)
            
            DispatchQueue.main.async {
                self.table.reloadData()
                self.setUpCurrentWeather()
                
            }
            
            //update user interface
        }).resume()
        
    }
    
    
    // MARK: - Current Weather
    
    func setUpCurrentWeather() {
        
        guard let currentWeather = self.currentInfo else { return }
        
        self.currentDateLabel.text = getDateFormatForDate(date: Date(timeIntervalSince1970: Double(currentWeather.dt)))
        self.currentSummaryLabel.text = currentWeather.weather[0].description
        self.currentTempLabel.text = "\(Int(currentWeather.temp))"
        
        let iconCode = currentWeather.weather[0].icon
        
        let url = "http://openweathermap.org/img/wn/\(iconCode)@2x.png"
        
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, _, error) in
            guard let data = data, error == nil else {
                print(error)
                return
            }
            DispatchQueue.main.async {
                let downloadImage = UIImage(data: data)
                self.currentIconImage.image = downloadImage
                self.currentIconImage.contentMode = .scaleAspectFit
                self.reloadInputViews()
                print("Uploaded UIImage")
            }
        }
        task.resume()
        
        
    }
    
    func getDateFormatForDate (date: Date?) -> String {
        
        guard let date = date else {
            return "Couldnt convert date"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        
        
        return dateFormatter.string(from: date)
        
    }
    

    // MARK: - UITABLEVIEW DELEGATE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        
        cell.configure(with:  dailyModels[indexPath.row])
        
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        
        vc.selectedDay = dailyModels[indexPath.row]

        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }


}





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
struct DailyWeather: Codable {
    let data: [DailyWeatherItem]

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



