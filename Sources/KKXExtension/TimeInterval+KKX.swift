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
    
    /// 时间戳（毫秒），转成时间格式字符串(自定义格式)
    ///
    ///     let millisecond = 3_600_000
    ///     let string1 = millisecond.timeString()
    ///     // string1 = "01:00:00"
    ///
    ///     let string2 = millisecond.timeString("HH时mm分")
    ///     // string2 = "01时00分
    ///
    /// - Parameter formater: 日期格式，默认 HH:mm:ss
    /// - Returns: formater格式字符串
    public func timeString(_ formater: String = KKXTime) -> String {
        return dateString(formater, timeZone: TimeZone(secondsFromGMT: 0))
    }
    
    /// 时间戳（毫秒），转成时间格式字符串(自定义格式)
    /// - Parameter formater: 日期格式，默认 yyyy-MM-dd
    /// - Parameter timeZone: 时区，默认为当前时区
    /// - Returns: formater格式字符串
    public func dateString(_ formater: String = KKXDate, timeZone: TimeZone? = nil) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = formater
        if timeZone != nil {
            dateFormater.timeZone = timeZone
        }
        let date = Date(timeIntervalSince1970: self/1000.0)
        return dateFormater.string(from: date)
    }
    
}
