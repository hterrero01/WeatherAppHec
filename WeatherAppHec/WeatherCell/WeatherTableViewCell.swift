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
    
    let weatherManager = WeatherServices()
    
    
    
    
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
    
    
    //configures the sell based on the model data
    func configure(with model: DailyWeatherItem) {
        
        self.lowTempLabel.text = "\(Int(model.temp.min))"
        
        self.highTempLabel.text = "\(Int(model.temp.max))"
        
        self.dayLabel.text = DateManager.getDayForDate(date: model.dt)
        
        let iconCode = model.weather[0].icon
        
        weatherManager.getWeatherIcon(iconCode: iconCode) { image in
            guard let iconImage = image else {return}
            
            DispatchQueue.main.async {
                self.iconImageView.image = iconImage
                self.reloadInputViews()
            }
        }
        
        self.dateLabel.text = DateManager.getMonthDayDate(date: model.dt)
        
    }

}
