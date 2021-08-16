//
//  DateManager.swift
//  WeatherAppHec
//
//  Created by HECTOR TERRERO on 8/15/21.
//

import Foundation
import UIKit



class DateManager {
    
    
    //returns date with format " Sunday, February 3, 1993
    class func getDayMonthDayYearDate (date: Int) -> String {
        
        let correctDate = Date(timeIntervalSince1970: Double(date))
        
    
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        
        
        return dateFormatter.string(from: correctDate)
        
    }
    
    
    class func getMonthDayDate (date: Int) -> String {
        
        
        let correctDate = Date(timeIntervalSince1970: Double(date))
        
    
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        
        return dateFormatter.string(from: correctDate)
        
    
    }
    
    //returns day for a given date
    class func getDayForDate(date: Int) -> String {
        
        let correctDate = Date(timeIntervalSince1970: Double(date))
        
    
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        
        return dateFormatter.string(from: correctDate)
        
        
    }
}
