//
//  UserDefaults+KKX.swift
//
//  Created by ming on 2019/6/4.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

extension UserDefaults {
    
    /// 根据key设置、获取UserDefaults中value
    ///
    /// 存储信息
    ///
    ///     let userDefaults = UserDefaults.standard
    ///     userDefaults["key"] = "value"
    /// - Parameters: key:  key
    ///
    public subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }
    
}
