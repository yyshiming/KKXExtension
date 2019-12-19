//
//  Timer+KKX.swift
//
//  Created by ming on 2019/3/20.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

extension Timer {

    /// iOS 10.0之前避免循环引用
    public class func kkx_scheduledTimer(timeInterval: TimeInterval, repeats: Bool, block: @escaping((Timer) -> Void))->Timer{
        if #available(iOS 10.0, *) {
            let timer = Timer(timeInterval: timeInterval, repeats: repeats, block: block)
            RunLoop.current.add(timer, forMode: .common)
            return timer
        } else {
            let timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(blockInvoke(_:)), userInfo: block, repeats: repeats)
            RunLoop.current.add(timer, forMode: .common)
            return timer
        }
    }
    
    @objc static private func blockInvoke(_ timer: Timer) {
        let block = timer.userInfo as? ((Timer) -> Void)
        if timer.isValid {
            block?(timer)
        }
    }
    
}
