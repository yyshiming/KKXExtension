//
//  DispatchQueue+KKX.swift
//
//  Created by ming on 2019/6/4.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

extension DispatchQueue {
    
    /// 在主线程调用block
    /// - Parameter block: 要调用的block
    public class func safe(_ block: @escaping () -> ()) {
        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
}
