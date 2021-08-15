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
    
    //model handling all api requests
    var weatherManager = WeatherServices()
    
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
        
     
        //checks permision for location servicies incase of any changes.
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()

        }
        
    }
    
    
    // MARK: - NAV BarConfiguration
    
    func configureNavBar(){

        //creates UIBarButton Item to be added to the navigation bar on the right side
        let barRightBtn = UIBarButtonItem(image: nil, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(permissionBtn))
        
        barRightBtn.title = "Permission"
        
        self.navigationItem.rightBarButtonItem = barRightBtn
       
    }
    
    //action for handling the navigationbar right button item
    @objc
    func permissionBtn(){
        setupLocation()
    }
    
    
    
    // MARK: - TableView Configuration
    
    func configureTableView(){
        
        //register the cell and assign delegates
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        
    }
    

    // MARK: - Current Weather Setup
    
    //handles the TODAY weather data which is stored in current object
    func setUpCurrentWeather() {
        
        
        guard let currentWeather = self.currentInfo else { return }
        
        self.currentDateLabel.text = DateManager.getDayMonthDayYearDate(date: currentWeather.dt)

        self.currentSummaryLabel.text = currentWeather.weather[0].description
        self.currentTempLabel.text = "\(Int(currentWeather.temp))"
        
        let iconCode = currentWeather.weather[0].icon
        
        //retrives icon image for current weather
        weatherManager.getWeatherIcon(iconCode: iconCode) { image in
            guard let iconImage = image else {return}
            
            DispatchQueue.main.async {
                self.currentIconImage.image = iconImage
                self.currentIconImage.contentMode = .scaleAspectFit
                self.reloadInputViews()
                print("Uploaded UIImage")
            }
        }
    }
}


// MARK: - LOCATION MANAGER DELEGATE
extension ViewController: CLLocationManagerDelegate {
    
    //checks status of location services
    func setupLocation() {
        
        // checks if permission has been previously denied and alerts user.
        if locationManager.authorizationStatus == .denied {
            let alertController = UIAlertController(title: "Location Services DENIED", message: "Please change permission on Settings", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion:  nil)
            }))
            present(alertController, animated: true, completion: nil)
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //request weather data once a location has been determined
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            weatherManager.requestWeatherForLocation(location: currentLocation) { result in
                
                guard let result = result else {return}
                self.currentInfo = result.current
                let entries = result.daily
                self.dailyModels.append(contentsOf: entries)
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                    self.setUpCurrentWeather()
                
            }
        }
    }
}
    
    //handles approprite action based on location services permission selected by the user.
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

