//
//  NSObject+KKX.swift
//
//  Created by ming on 2019/12/19.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

// MARK: - ======== KKXInputDelegate ========
public protocol KKXInputDelegate: AnyObject {
    
    var inputResponders: [UIResponder] { get }
    
    func inputCancelButtonAction()
    func inputPreviousStepButtonAction()
    func inputNextStepButtonAction()
    func inputDoneButtonAction()
    func inputDatePickerValueChanged(_ datePicker: UIDatePicker)
}

extension KKXInputDelegate {
    public var inputResponders: [UIResponder] { [] }
    
    public func inputCancelButtonAction() { }
    public func inputPreviousStepButtonAction() { }
    public func inputNextStepButtonAction() { }
    public func inputDoneButtonAction() { }
    public func inputDatePickerValueChanged(_ datePicker: UIDatePicker) { }
}

public enum KKXInputAccessoryBarStyle {
    /// 取消  完成
    case `default`
    
    /// 上一个 下一个  完成
    case stepArrow
    case stepText
}

extension NSObject {
    
    private weak var kkxInputDelegate: KKXInputDelegate? {
        return self as? KKXInputDelegate
    }
    
    /// UITextField().inputView = datePicker
    public var datePicker: UIDatePicker {
        if let datePicker = objc_getAssociatedObject(self, &AssociatedKeys.datePicker) as? UIDatePicker {
            return datePicker
        }
        else {
            // 设置最小、最大时间
            /*
             let maximumDate = Date()
             let calendar = Calendar.current
             let dateComponents = DateComponents(year: -100, month: 1 - calendar.component(.month, from: maximumDate), day: 1 - calendar.component(.day, from: maximumDate))
             let minimumDate = calendar.date(byAdding: dateComponents, to: maximumDate)
             picker.maximumDate = maximumDate
             picker.minimumDate = minimumDate
             */
            
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.addTarget(self, action: #selector(kkxValueChanged(_:)), for: .valueChanged)
            return picker
        }
    }
    
    private var accessoryBarTintColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return UIColor.white
                }
                else {
                    return UIColor.kkxSystemBlue
                }
            }
        } else {
            return UIColor.kkxSystemBlue
        }
    }
    
    /// UITextField().inputAccessoryView = inputAccessoryBar
    public var inputAccessoryBar: UIToolbar {
        if let bar = objc_getAssociatedObject(self, &AssociatedKeys.inputAccessoryBar) as? UIToolbar {
            return bar
        }
        else {
            let bar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
            bar.tintColor = accessoryBarTintColor
            objc_setAssociatedObject(self, &AssociatedKeys.inputAccessoryBar, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            accessoryBarStyle = .stepArrow
            return bar
        }
    }
    
    public var accessoryBarStyle: KKXInputAccessoryBarStyle {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.inputAccessoryBarStyle) as? KKXInputAccessoryBarStyle
            return style ?? .default
        }
        set {
            switch newValue {
            case .default:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                inputAccessoryBar.items = [cancelItem, flexibleSpaceItem, doneItem]
            case .stepArrow:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                fixedSpaceItem.width = 10
                previousStepItem.image = UIImage(named: "kkx_arrow_up")
                previousStepItem.title = nil
                nextStepItem.image = UIImage(named: "kkx_arrow_down")
                nextStepItem.title = nil
                inputAccessoryBar.items = [previousStepItem, fixedSpaceItem, nextStepItem, flexibleSpaceItem, doneItem]
            case .stepText:
                let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                previousStepItem.image = nil
                previousStepItem.title = KKXExtensionString("PreviousStep")
                nextStepItem.image = nil
                nextStepItem.title = KKXExtensionString("NextStep")
                inputAccessoryBar.items = [previousStepItem, nextStepItem, flexibleSpaceItem, doneItem]
            }
            objc_setAssociatedObject(self, &AssociatedKeys.inputAccessoryBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var kkxFirstResponder: UIResponder? {
        get {
            let responder = objc_getAssociatedObject(self, &AssociatedKeys.kkxFirstResponder) as? UIResponder
            return responder
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kkxFirstResponder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var cancelItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &AssociatedKeys.cancelItem) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(kkxCancelAction))
            objc_setAssociatedObject(self, &AssociatedKeys.cancelItem, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var previousStepItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &AssociatedKeys.previousStepItem) as? UIBarButtonItem else {
            let item = UIBarButtonItem(image: UIImage(named: "kkx_arrow_up"), style: .plain, target: self, action: #selector(kkxPreviousStepAction))
            objc_setAssociatedObject(self, &AssociatedKeys.previousStepItem, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var nextStepItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &AssociatedKeys.nextStepItem) as? UIBarButtonItem else {
            let item = UIBarButtonItem(image: UIImage(named: "kkx_arrow_down"), style: .plain, target: self, action: #selector(kkxNextStepAction))
            objc_setAssociatedObject(self, &AssociatedKeys.nextStepItem, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    public var doneItem: UIBarButtonItem {
        guard let item = objc_getAssociatedObject(self, &AssociatedKeys.doneItem) as? UIBarButtonItem else {
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(kkxDoneAction))
            objc_setAssociatedObject(self, &AssociatedKeys.doneItem, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
        return item
    }
    
    // MARK: -------- Actions --------
    
    @objc private func kkxCancelAction() {
        if let view = self as? UIView {
            view.endEditing(true)
        } else if let viewController = self as? UIViewController {
            viewController.view.endEditing(true)
        }
        kkxInputDelegate?.inputCancelButtonAction()
    }
    
    @objc private func kkxPreviousStepAction() {
        if let responder = kkxFirstResponder,
            responder.isFirstResponder,
            let inputResponders = kkxInputDelegate?.inputResponders,
            let index = inputResponders.firstIndex(of: responder),
            index > 0 {
            
            inputResponders[index - 1].becomeFirstResponder()
        }
        kkxInputDelegate?.inputPreviousStepButtonAction()
    }
    
    @objc private func kkxNextStepAction() {
        if let responder = kkxFirstResponder,
            responder.isFirstResponder,
            let inputResponders = kkxInputDelegate?.inputResponders,
            let index = inputResponders.firstIndex(of: responder),
            index < inputResponders.count - 1 {
            
            inputResponders[index + 1].becomeFirstResponder()
        }
        kkxInputDelegate?.inputNextStepButtonAction()
    }
    
    @objc private func kkxDoneAction() {
        if let view = self as? UIView {
            view.endEditing(true)
        } else if let viewController = self as? UIViewController {
            viewController.view.endEditing(true)
        }
        kkxFirstResponder = nil
        kkxInputDelegate?.inputDoneButtonAction()
    }
    
    @objc private func kkxValueChanged(_ datePicker: UIDatePicker) {
        kkxInputDelegate?.inputDatePickerValueChanged(datePicker)
    }
    
}

// MARK: - ======== deinitLog ========
extension NSObject {

    public func kkxDeinitLog() {
        kkxPrint(NSStringFromClass(self.classForCoder) + " deinit")
    }
    
    /// keyWindow安全区域
    ///
    ///     状态栏没有隐藏时
    ///     iPhone X:
    ///     UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
    ///     其他：
    ///     UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    public var kkxSafeAreaInsets: UIEdgeInsets {
        var insets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
        return insets
    }
    
}

fileprivate struct AssociatedKeys {
    static var datePicker = "kkx-datePicker"
    static var inputAccessoryBar = "kkx-inputAccessoryBar"
    static var inputAccessoryBarStyle = "kkx-inputAccessoryBarStyle"
    static var kkxFirstResponder = "kkx-firstResponder"
    static var cancelItem = "kkx-cancelItem"
    static var previousStepItem = "kkx-previousStepItem"
    static var nextStepItem = "kkx-nextStepItem"
    static var doneItem = "kkx-donItem"
}
