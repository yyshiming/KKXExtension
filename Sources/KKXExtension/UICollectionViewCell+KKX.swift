//
//  UICollectionViewCell+KKX.swift
//  SwiftMobile
//
//  Created by ming on 2020/1/7.
//  Copyright © 2020 ming. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    public var deleteAction: ((IndexPath?) -> Void)? {
        get {
            let action = objc_getAssociatedObject(self, &AssociatedKeys.deleteAction) as? ((IndexPath?) -> Void)
            return action
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.deleteAction, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var contentInsets: UIEdgeInsets {
        get {
            let insets = objc_getAssociatedObject(self, &AssociatedKeys.contentInsets) as? UIEdgeInsets
            return insets ?? .zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.contentInsets, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open var canBecomeFirstResponder: Bool {
        return true
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(delete(_:)){
            return true
        }
        return false
    }
    
    override open func delete(_ sender: Any?) {
        deleteAction?(kkx_indexPath)
    }

}

// MARK: - ======== KKXDefaultBackgroundView cell选中背景色 ========
open class KKXDefaultBackgroundView: UIView {
    
    open override func draw(_ rect: CGRect) {
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef?.saveGState()
        
        let bezierPath = UIBezierPath(rect: rect)
        if #available(iOS 13.0, *) {
            UIColor.systemGray2.setFill()
        } else {
            let fillColor = UIColor(red: 208.0/255.0, green: 208.0/255.0, blue: 208.0/255.0, alpha: 1.0)
            fillColor.setFill()
        }
        
        bezierPath.fill()
        contextRef?.restoreGState()
    }
    
}

// MARK: - ======== AssociatedKeys ========
fileprivate struct AssociatedKeys {
    static var deleteAction = "kkx-deleteAction"
    static var contentInsets = "kkx-contentInsets"
}
