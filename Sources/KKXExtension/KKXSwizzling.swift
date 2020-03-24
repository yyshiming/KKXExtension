//
//  KKXSwizzling.swift
//
//  Created by ming on 2019/4/4.
//  Copyright © 2019 ming. All rights reserved.
//

import ObjectiveC

/// 交换Class中的方法和自定义方法
/// - Parameter theClass: 要交换的Class
/// - Parameter originalSelector: Class方法
/// - Parameter swizzledSelector: 自定义方法
public func kkxSwizzleSelector(_ theClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    
    let originalMethod = class_getInstanceMethod(theClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector)
    
    let didAddMethod: Bool = class_addMethod(theClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
    
    if didAddMethod {
        class_replaceMethod(theClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    } else {
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}
