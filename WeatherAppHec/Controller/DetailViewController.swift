//
//  DetailViewController.swift
//  WeatherAppHec
//
//  Created by HECTOR TERRERO on 8/15/21.
//

import UIKit

class DetailViewController: UIViewController {
    
    

    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var iconImage: UIImageView!
    
    @IBOutlet var tempLabel: UILabel!
    
    @IBOutlet var summaryLabel: UILabel!
    
    //handles all openweathermap request
    let weatherManager = WeatherServices ()
    
    //stored property to hold the daily weather data
    var selectedDay: DailyWeatherItem?
    
    var iconCode: String? {
        didSet{
            
            if let iconCode = iconCode {
                
                weatherManager.getWeatherIcon(iconCode: iconCode) { image in
                    guard let iconImage = image else {return}
                    DispatchQueue.main.async {
                        self.iconImage.image = iconImage
                        self.reloadInputViews()
                    }
                }
//                getIconForDay(iconCode: iconCode)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDetailView()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    //configures values for IBoutlets
    func configureDetailView(){
        guard let dayInfo = selectedDay else {
            return
        }
        
        self.dateLabel.text = DateManager.getDayMonthDayYearDate(date: dayInfo.dt)
        self.summaryLabel.text = dayInfo.weather[0].description
        self.tempLabel.text = "\(Int(dayInfo.temp.day))"
        self.iconCode = dayInfo.weather[0].icon
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
