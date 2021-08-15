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
    
    var selectedDay: DailyWeatherItem?
    
    var iconCode: String? {
        didSet{
            
            if let iconCode = iconCode {
                getIconForDay(iconCode: iconCode)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDetailView()
        
        
        // Do any additional setup after loading the view.
    }
    
    func getIconForDay (iconCode: String) {
    
        let url = "http://openweathermap.org/img/wn/\(iconCode)@2x.png"
        
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, _, error) in
            guard let data = data, error == nil else {
                print(error)
                return
            }
            DispatchQueue.main.async {
                let downloadImage = UIImage(data: data)
                self.iconImage.image = downloadImage
                self.reloadInputViews()
            }
        }
        task.resume()
        
        
    }
    
    func configureDetailView(){
        guard let dayInfo = selectedDay else {
            return
        }
        
        self.dateLabel.text = getDateFormatForDate(date: Date(timeIntervalSince1970: Double(dayInfo.dt)))
        self.summaryLabel.text = dayInfo.weather[0].description
        self.tempLabel.text = "\(Int(dayInfo.temp.day))"
        self.iconCode = dayInfo.weather[0].icon
        
    }
    
    func getDateFormatForDate (date: Date?) -> String {
        
        guard let date = date else {
            return "Couldnt convert date"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        
        
        return dateFormatter.string(from: date)
        
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
