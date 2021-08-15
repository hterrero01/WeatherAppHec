//
//  WeatherTableViewCell.swift
//  WeatherAppHec
//
//  Created by HECTOR TERRERO on 8/12/21.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    
    static let identifier = "WeatherTableViewCell"
    
    
    @IBOutlet  var dateLabel: UILabel!
    @IBOutlet  var dayLabel: UILabel!
    @IBOutlet  var iconImageView: UIImageView!
    @IBOutlet  var lowTempLabel: UILabel!
    @IBOutlet  var highTempLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super .awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "WeatherTableViewCell", bundle: nil)
    }
    
    
    func configure(with model: DailyWeatherItem) {
        
        self.lowTempLabel.text = "\(Int(model.temp.min))"
        self.highTempLabel.text = "\(Int(model.temp.max))"
        self.dayLabel.text = getDayForDate(date: Date(timeIntervalSince1970: Double(model.dt)))
        getIconForDay(iconCode: model.weather[0].icon)
        self.dateLabel.text = getDateFormatForDate(date: Date(timeIntervalSince1970: Double(model.dt)))
        
        
    }
    
    func getDayForDate(date: Date?) -> String {
        
        guard let date = date else {
            return "Couldnt convert date"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        
        return dateFormatter.string(from: date)
        
    }
    
    func getIconForDay (iconCode: String) {
    
        let url = "http://openweathermap.org/img/wn/\(iconCode)@2x.png"
        
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, _, error) in
            guard let data = data, error == nil else {
                print("THERE IS AN ERROR")
                print(error)
                return
            }
            DispatchQueue.main.async {
                let downloadImage = UIImage(data: data)
                self.iconImageView.image = downloadImage
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
        dateFormatter.dateFormat = "MMM d"
        
        
        return dateFormatter.string(from: date)
        
    }
    
    
}
