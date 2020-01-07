//
//  NSObject+KKX.swift
//
//  Created by ming on 2019/12/19.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

// MARK: - ======== KKXInputDelegate ========
public protocol KKXInputDelegate: AnyObject {
    func inputCancelButtonAction()
    func inputDoneButtonAction()
    func inputDatePickerValueChanged(_ datePicker: UIDatePicker)
}

extension KKXInputDelegate {
    public func inputCancelButtonAction() { }
    public func inputDoneButtonAction() { }
    public func inputDatePickerValueChanged(_ datePicker: UIDatePicker) { }
}

extension NSObject {
    
    private weak var kkx_inputDelegate: KKXInputDelegate? {
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
            picker.addTarget(self, action: #selector(kkx_valueChanged(_:)), for: .valueChanged)
            return picker
        }
    }
    
    /// UITextField().inputAccessoryView = inputAccessoryBar
    public var inputAccessoryBar: UIToolbar {
        if let bar = objc_getAssociatedObject(self, &AssociatedKeys.inputAccessoryBar) as? UIToolbar {
            return bar
        }
        else {
            let bar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
            bar.items = [
                UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(kkx_cancelAction)),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(kkx_doneAction)),
            ]
            objc_setAssociatedObject(self, &AssociatedKeys.inputAccessoryBar, bar, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return bar
        }
    }
    
    // MARK: -------- Actions --------
    
    @objc private func kkx_cancelAction() {
        kkx_inputDelegate?.inputCancelButtonAction()
    }
    
    @objc private func kkx_doneAction() {
        kkx_inputDelegate?.inputDoneButtonAction()
    }
    
    @objc private func kkx_valueChanged(_ datePicker: UIDatePicker) {
        kkx_inputDelegate?.inputDatePickerValueChanged(datePicker)
    }
    
}

// MARK: - ======== deinitLog ========
extension NSObject {

    public func kkx_deinitLog() {
        kkxPrint(NSStringFromClass(self.classForCoder) + " deinit")
    }
    
}

fileprivate struct AssociatedKeys {
    static var datePicker = "kkx-datePicker"
    static var inputAccessoryBar = "kkx-inputAccessoryBar"
}
