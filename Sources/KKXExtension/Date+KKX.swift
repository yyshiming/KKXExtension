//
//  Date+KKX.swift
//
//  Created by ming on 2019/3/28.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

/// yyyy-MM-dd
public let KKXDate = "yyyy-MM-dd"
/// HH:mm:ss
public let KKXTime = "HH:mm:ss"
/// yyyy-MM-dd HH:ss:mm
public let KKXDateAndTime = "yyyy-MM-dd HH:mm:ss"

extension Date {
    
    /// 转成时间格式字符串(自定义格式)
    /// - Parameter formater: 日期格式，默认 yyyy-MM-dd
    /// - Returns: formater字符串
    public func stringValue(_ formater: String = KKXDate) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = formater
        return dateFormater.string(from: self)
    }
    
}
