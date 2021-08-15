//
//  ViewController.swift
//  WeatherAppHec
//
//  Created by HECTOR TERRERO on 8/12/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var table: UITableView!
    
    @IBOutlet var currentDateLabel: UILabel!
    
    @IBOutlet var currentIconImage: UIImageView!
    
    @IBOutlet var currentSummaryLabel: UILabel!
    
    @IBOutlet var currentTempLabel: UILabel!
    
    var dailyModels = [DailyWeatherItem]()
    
    var currentInfo: CurrentWeather?
    
    let locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //assign location managers delegate
        locationManager.delegate = self
        
        //setup tableview
        configureTableView()
        
        //setup the navigation bar with barBtnItem
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
        
        //register the cell
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        
    }
    

    // MARK: - Current Weather Setup
    
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
    
}


// MARK: - LOCATION MANAGER DELEGATE
extension ViewController: CLLocationManagerDelegate {
    
    func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
    
}

// MARK: - UITABLEVIEW DELEGATE
extension ViewController:  UITableViewDelegate, UITableViewDataSource {
    
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

