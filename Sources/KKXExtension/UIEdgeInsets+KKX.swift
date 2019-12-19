//
//  UIEdgeInsets+KKX.swift
//
//  Created by ming on 2019/6/13.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    /// 初始化 top = left = bottom = right = value
    public init(value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
    
    /// placeholder为占位参数，不传值
    public init(top: CGFloat = 0,
                left: CGFloat = 0,
                bottom: CGFloat = 0,
                right: CGFloat = 0,
                placeholder: Int = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}
