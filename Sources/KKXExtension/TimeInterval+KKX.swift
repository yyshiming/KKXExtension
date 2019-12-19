//
//  TimeInterval+KKX.swift
//
//  Created by ming on 2019/4/15.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

extension Int {
    public static let aSecond: Int = 1
    public static let aMinute: Int = Int.aSecond*60
    public static let aHour: Int = Int.aMinute*60
    public static let aDay: Int = Int.aHour*24
    public static let aWeek: Int = Int.aDay*7
}

extension TimeInterval {
    
    /// 时间戳（毫秒），转成时间格式 00:00:00
    public var timeString: String {
        let format = "%.2d"
        var theLastTime = "00:00"
        let second = Int(self/1000.0)
        if second < Int.aMinute {
            theLastTime = String(format: "00:\(format)", second)
        }
        else if second < Int.aHour {
            theLastTime = String(format: "\(format):\(format)", second/Int.aMinute, second%Int.aMinute)
        }
        else {
            theLastTime = String(format: "\(format):\(format):\(format)", second/Int.aHour, second%Int.aHour/Int.aMinute, second%Int.aMinute)
        }
        return theLastTime
    }
    
    /// 时间戳（毫秒），转成时间格式字符串(自定义格式)
    /// - Parameter formater: 日期格式，默认 yyyy-MM-dd
    /// - Returns: formater字符串
    public func dateString(_ formater: String = KKXDate) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = formater
        let date = Date(timeIntervalSince1970: self/1000.0)
        return dateFormater.string(from: date)
    }
    
}
