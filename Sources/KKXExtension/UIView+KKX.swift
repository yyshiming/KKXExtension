//
//  UIView+KKX.swift
//
//  Created by ming on 2019/3/28.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

/// 存储计时信息的对象，可以在代理方法里面设置button标题
///
///     let button = UIButton(type: .custom)
///     button.timerObject.timerCount = 60
///     button.timerDelegate = self
///     button.startTimer()
public class KKXTimerObject {
    
    /// 计时秒数，默认 60
    public var timerCount: Int = 60 {
        didSet {
            currentCount = timerCount
        }
    }
    
    /// 定时器当前数值
    public fileprivate(set) var currentCount: Int = 60
    /// 定时器是否倒计时中
    public fileprivate(set) var isCountDown: Bool = false
    fileprivate var timer: Timer?
    
    /// 销毁定时器
    fileprivate func invalidateTimer() {
        isCountDown = false
        timer?.invalidate()
        timer = nil
        currentCount = timerCount
        
    }
    
    deinit {
        invalidateTimer()
        #if DEBUG
        print("timer invalidate")
        #endif
    }
}

public protocol KKXTimer {
    
    /// 存储计时信息的对象
    var timerObject: KKXTimerObject { get }
    
    /// 开始计时
    func startTimer()
}

public protocol KKXTimerDelegate: AnyObject {
    
    /// 将要倒计时
    func timerWillRunning(_ object: KKXTimer)
    /// 倒计时中
    func timerRunning(_ object: KKXTimer, count: Int)
    /// 倒计时结束
    func timerDidStop(_ object: KKXTimer)
}

extension KKXTimerDelegate {
    
    func timerWillRunning(_ object: KKXTimer) { }
    func timerRunning(_ object: KKXTimer, count: Int) { }
    func timerDidStop(_ object: KKXTimer) { }
}

// MARK: -======== 倒计时Timer ========
/// 为UIButton添加的倒计时扩展功能，可以在获取验证码的按钮上使用
extension UIView: KKXTimer {
    
    public var timerObject: KKXTimerObject {
        get {
            if let timerObj = objc_getAssociatedObject(self, &AssociatedKeys.timerObject) as? KKXTimerObject {
                return timerObj
            }
            else {
                let timerObj = KKXTimerObject()
                objc_setAssociatedObject(self, &AssociatedKeys.timerObject, timerObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return timerObj
            }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.timerObject, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 计时代理
    public weak var timerDelegate: KKXTimerDelegate? {
        get {
            let deleg = objc_getAssociatedObject(self, &AssociatedKeys.timerDelegate) as? KKXTimerDelegate
            return deleg
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.timerDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 开始计时
    public func startTimer() {
        if timerObject.isCountDown {
            return
        }
        timerObject.invalidateTimer()
        timerObject.isCountDown = true
        timerDelegate?.timerWillRunning(self)
        
        timerObject.timer = Timer.kkx_scheduledTimer(timeInterval: 1.0, repeats: true, block: { [unowned self](timer) in
            self.timerFired(timer)
        })
        
        timerDelegate?.timerRunning(self, count: timerObject.currentCount)
    }
    
    private func timerFired(_ timer: Timer) {
        
        timerObject.currentCount -= 1
        guard timerObject.currentCount > 0 else {
            timerObject.invalidateTimer()
            timerDelegate?.timerDidStop(self)
            return
        }
        timerDelegate?.timerRunning(self, count: timerObject.currentCount)
    }
    
}

// MARK: - ======== 系统菊花动画 ========
extension UIView {
    
    /// 是否显示菊花动画
    public var kkx_loading: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.loading) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.loading, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {

                addSubview(kkx_loadingView)
                bringSubviewToFront(kkx_loadingView)
                kkx_loadingView.startAnimating()
                
                let attributes: [NSLayoutConstraint.Attribute] = [.top, .leading, .bottom, .trailing]
                for attribute in attributes {
                    NSLayoutConstraint(
                        item: kkx_loadingView,
                        attribute: attribute,
                        relatedBy: .equal,
                        toItem: self,
                        attribute: attribute,
                        multiplier: 1.0,
                        constant: 0.0
                    ).isActive = true
                }
            }
            else {
                kkx_loadingView.removeFromSuperview()
            }
        }
    }
    
    public var kkx_loadingView: UIActivityIndicatorView {
        guard let loadingView = objc_getAssociatedObject(self, &AssociatedKeys.loadingView) as? UIActivityIndicatorView else {
            
            let indicatorView = UIActivityIndicatorView()
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            indicatorView.backgroundColor = .clear
            if #available(iOS 13.0, *) {
                indicatorView.style = .medium
            } else {
                indicatorView.style = .gray
            }
            objc_setAssociatedObject(self, &AssociatedKeys.loadingView, indicatorView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            return indicatorView
        }
        return loadingView
    }
}

// MARK: - ======== 没有数据时展示的view ========
extension UIView {
    
    /// 没有数据时显示的view
    public var noDataView: KKXNoDataView {
        get {
            if let view = objc_getAssociatedObject(self, &AssociatedKeys.noDataView) as? KKXNoDataView {
                return view
            }
            else {
                let view = KKXNoDataView()
                addSubview(view)
                view.isHidden = true
                
                let attributes: [NSLayoutConstraint.Attribute] = [.top, .leading, .bottom, .trailing]
                for attribute in attributes {
                    NSLayoutConstraint(
                        item: view,
                        attribute: attribute,
                        relatedBy: .equal,
                        toItem: self,
                        attribute: attribute,
                        multiplier: 1.0,
                        constant: 0.0
                    ).isActive = true
                }
                
                objc_setAssociatedObject(self, &AssociatedKeys.noDataView, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return view
            }
        }
    }

}

// MARK: - ======== 添加下划线 ========
/*
 linePath.removeAllPoints()
 linePath.move(to: startPoint)
 linePath.addLine(to: endPoint)
 drawLines()
 */
extension UIView {
    
    /// 是否隐藏line，默认false
    public var isLineHidden: Bool {
        get {
            return lineLayer.isHidden
        }
        set {
            lineLayer.isHidden = newValue
        }
    }
    
    /// 默认 0.5
    public var lineWidth: CGFloat {
        get {
            let width = objc_getAssociatedObject(self, &AssociatedKeys.lineWidth) as? CGFloat
            return width ?? lineDefaultWidth
        }
        set {
            lineLayer.lineWidth = newValue
            objc_setAssociatedObject(self, &AssociatedKeys.lineWidth, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 默认 rgba: 0.0, 0.0, 25.0/255.0, 0.22
    public var lineColor: UIColor {
        get {
            let color = objc_getAssociatedObject(self, &AssociatedKeys.lineColor) as? UIColor
            return color ?? lineDefaultColor
        }
        set {
            lineLayer.strokeColor = newValue.cgColor
            objc_setAssociatedObject(self, &AssociatedKeys.lineColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 默认 UIEdgeInsets.zero
    public var lineInsets: UIEdgeInsets {
        get {
            let insets = objc_getAssociatedObject(self, &AssociatedKeys.lineInsets) as? UIEdgeInsets
            return insets ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lineInsets, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 绘制路径
    public var linePath: UIBezierPath {
        get {
            if let path = objc_getAssociatedObject(self, &AssociatedKeys.linePath) as? UIBezierPath {
                return path
            }
            else {
                let path = UIBezierPath()
                objc_setAssociatedObject(self, &AssociatedKeys.linePath, path, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return path
            }
        }
    }
    
    /// 添加图层，例如分割线
    public var lineLayer: CAShapeLayer {
        get {
            if let shapeLayer = objc_getAssociatedObject(self, &AssociatedKeys.lineLayer) as? CAShapeLayer {
                return shapeLayer
            }
            else {
                let shapeLayer = CAShapeLayer()
                shapeLayer.backgroundColor = UIColor.clear.cgColor
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.strokeColor = lineColor.cgColor
                shapeLayer.lineWidth = lineWidth
                layer.addSublayer(shapeLayer)
                objc_setAssociatedObject(self, &AssociatedKeys.lineLayer, shapeLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return shapeLayer
            }
        }
    }
    
    /// 在layoutSubviews中调用此方法添加line
    public func drawBottomLine() {
        let startPoint = CGPoint(x: lineInsets.left, y: frame.size.height - lineWidth)
        let endPoint = CGPoint(x: frame.size.width - lineInsets.right, y: frame.size.height - lineWidth)
        linePath.removeAllPoints()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        drawLines()
    }
    
    /// 自定义path
    public func drawLines(_ path: UIBezierPath? = nil) {
        lineLayer.path = path?.cgPath ?? linePath.cgPath
    }
    
    /// 添加stroke动画
    public func addStrokeAnimation(_ duration: CFTimeInterval = 0.25) {
        let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        animation.duration = duration
        animation.fromValue = 0.0
        animation.toValue = 1.0
        lineLayer.add(animation, forKey: "stroke")
    }
    
}
private let lineDefaultWidth: CGFloat = 0.5/UIScreen.main.scale
private var lineDefaultColor: UIColor {
    .kkxSeparator
}

// MARK: - ======== Frame ========
extension UIView {
    
    public var kkx_x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    public var kkx_y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    public var kkx_width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    public var kkx_height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    public var kkx_minX: CGFloat {
        return frame.minX
    }
    
    public var kkx_minY: CGFloat {
        return frame.minY
    }
    
    public var kkx_midX: CGFloat {
        return frame.midX
    }
    
    public var kkx_midY: CGFloat {
        return frame.midY
    }
    
    public var kkx_maxX: CGFloat {
        return frame.maxX
    }
    
    public var kkx_maxY: CGFloat {
        return frame.maxY
    }
    
}

// MARK: - ========  模糊效果 ========
extension UIView {
    
    public func blur(withStyle style: UIBlurEffect.Style = .light) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        addSubview(blurEffectView)
        clipsToBounds = true
    }
    
    public func blurred(withStyle style: UIBlurEffect.Style = .light) -> UIView {
        let imgView = self
        imgView.blur(withStyle: style)
        return imgView
    }
    
}

// MARK: - ========  indexPath ========
public protocol UIViewIndexPath {
    
    /// 可用于UITableViewCell、UICollectionViewCell传参数
    var kkx_indexPath: IndexPath? { get set }
}

extension UIView : UIViewIndexPath {
    
    public var kkx_indexPath: IndexPath? {
        get {
            let indexPath = objc_getAssociatedObject(self, &AssociatedKeys.indexPath) as? IndexPath
            return indexPath
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.indexPath, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

public protocol KKXCalculateHeight {
    var kkx_totalHeight: CGFloat { get }
}

// MARK: - ======== Cell计算高度 ========
extension UIView: KKXCalculateHeight{
    
    /// 高度计算
    ///
    ///     view中重写 kkx_totalHeight，返回view的真实高度
    @objc
    public var kkx_totalHeight: CGFloat {
        0.0
    }

}

// MARK: - ======== KKXAssociated ========
private struct AssociatedKeys {
    static var timerDelegate = "kkx-timerDelegate"
    static var timerObject = "kkx-timerObject"
    
    static var loading = "kkx-loading"
    static var loadingView = "kkx-loadingView"
    static var noDataView = "kkx-noDataView"
    
    static var linePath = "kkx-linePath"
    static var lineLayer = "kkx-lineLayer"
    static var lineWidth = "kkx-lineWidth"
    static var lineColor = "kkx-lineColor"
    static var lineInsets = "kkx-lineInsets"
    
    static var indexPath = "kkx-indexPath"
}
