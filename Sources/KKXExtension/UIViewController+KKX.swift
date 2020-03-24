//
//  UIViewController+KKX.swift
//
//  Created by Weichen Jiang on 8/3/18.
//  Copyright © 2018 J&K INVESTMENT HOLDING GROUP. All rights reserved.
//

import UIKit
import Photos

/// 自定义返回按钮的viewController需要实现的协议
public protocol KKXCustomBackItem: NSObjectProtocol { }
public protocol KKXCustomNavigationBar: NSObjectProtocol { }

// MARK: - ======== swizzle ========
extension UIViewController {
    
    public class func initializeController() {
        
        kkxSwizzleSelector(self, originalSelector: #selector(willMove(toParent:)), swizzledSelector: #selector(kkxWillMove(toParent:)))
        kkxSwizzleSelector(self, originalSelector: #selector(viewDidLoad), swizzledSelector: #selector(kkxViewDidLoad))
        kkxSwizzleSelector(self, originalSelector: #selector(viewWillAppear(_:)), swizzledSelector: #selector(kkxViewWillAppear(_:)))
        kkxSwizzleSelector(self, originalSelector: #selector(viewWillDisappear(_:)), swizzledSelector: #selector(kkxViewWillDisappear(_:)))
        
        kkxSwizzleSelector(self, originalSelector: #selector(getter: preferredStatusBarStyle), swizzledSelector: #selector(kkxStatusBarUpdateStyle))
        kkxSwizzleSelector(self, originalSelector: #selector(getter: preferredStatusBarUpdateAnimation), swizzledSelector: #selector(kkxStatusBarUpdateAnimation))
        
    }
    
}

extension UIViewController {
    
    // MARK: -------- Properties --------
    
    /// 是否应该刷新数据，默认false
    public var shouldReloadData: Bool {
        get {
            let first = objc_getAssociatedObject(self, &AssociatedKeys.shouldReloadData) as? Bool
            return first ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldReloadData, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// TableView  Style: plain
    public var plainTableView: UITableView {
        if let tableView = objc_getAssociatedObject(self, &AssociatedKeys.plainTableView) as? UITableView {
            return tableView
        }
        else {
            let tableView = UITableView(frame: CGRect.zero, style: .plain)
            tableView.tableFooterView = UIView()
            tableView.backgroundColor = .clear
            tableView.alwaysBounceVertical = true
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            view.addSubview(tableView)
            
            objc_setAssociatedObject(self, &AssociatedKeys.plainTableView, tableView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tableView
        }
    }
    
    /// TableView  Style: group
    public var groupedTableView: UITableView {
        if let tableView = objc_getAssociatedObject(self, &AssociatedKeys.groupedTableView) as? UITableView {
            return tableView
        }
        else {
            let tableView = UITableView(frame: CGRect.zero, style: .grouped)
            tableView.tableFooterView = UIView()
            tableView.backgroundColor = .clear
            view.addSubview(tableView)
            view.sendSubviewToBack(tableView)
            
            objc_setAssociatedObject(self, &AssociatedKeys.groupedTableView, tableView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tableView
        }
    }
    
    /// statusBar高度
    public var kkxStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    /// navbar高度
    public var kkxNavBarHeight: CGFloat {
        return navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    /// tabbar高度
    public var kkxTabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.size.height ?? 0
    }
    
    /// statusBar + navbar高度
    public var kkxTop: CGFloat {
        var top: CGFloat = 0
        if !UIApplication.shared.isStatusBarHidden {
            top += kkxStatusBarHeight
        }
        if navigationController?.navigationBar.isHidden == false {
            top += kkxNavBarHeight
        }
        return top
    }

    /// tabbar高度
    public var kkxBottom: CGFloat {
        var bottom: CGFloat = 0
        if tabBarController?.tabBar.isHidden == false {
            bottom += kkxTabBarHeight
        }
        return bottom
    }
    
}

// MARK: - ======== Life Circle ========
extension UIViewController {

    @objc private func kkxWillMove(toParent parent: UIViewController?) {
        if let _ = kkxLastNavBarStyle, parent == nil {
            kkxLastNavBarStyle?()
        }
    }
    
    @objc private func kkxViewDidLoad() {
        self.kkxViewDidLoad()
        if self is KKXCustomBackItem {
            let backItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            backItem.width = 80
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    @objc private func kkxViewWillAppear(_ animated: Bool) {
        self.kkxViewWillAppear(animated)
        if let _ = navigationController, self is KKXCustomNavigationBar {
            reloadNavigationBar()
        }
    }
    
    @objc private func kkxViewWillDisappear(_ animated: Bool) {
        self.kkxViewWillDisappear(animated)
        view.endEditing(true)
    }
    
}

// MARK: - ======== 状态栏 Style ========
extension UIViewController {
    
    public var kkxStatusBarAnimation:  UIStatusBarAnimation {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.statusBarAnimation) as? UIStatusBarAnimation
            return style ?? UIStatusBarAnimation.none
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.statusBarAnimation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var kkxStatusBarStyle: UIStatusBarStyle {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.statusBarStyle) as? UIStatusBarStyle
            return style ?? UIStatusBarStyle.default
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.statusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc private func kkxStatusBarUpdateStyle() -> UIStatusBarStyle {
        return kkxStatusBarStyle
    }
    
    @objc private func kkxStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return kkxStatusBarAnimation
    }
    
}

// MARK: - ======== 导航栏 Style ========
extension UIViewController {
    
    private func reloadNavigationBar() {
        if kkxCustomNavBarStyle == nil {
            kkxCustomNavBarStyle = { [unowned self] in
                self.configureThemeStyle()
                self.applyNavBarStyle()
            }
        }
        
        kkxCustomNavBarStyle?()
    }
    
    /// 自定义导航栏风格
    public var kkxCustomNavBarStyle: (() -> Void)? {
        get {
            let custom = objc_getAssociatedObject(self, &AssociatedKeys.customNavBarStyle) as? (() -> Void)
            return custom
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customNavBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            reloadNavigationBar()
        }
    }
    
    /// 上一个viewController导航栏风格
    public var kkxLastNavBarStyle: (() -> Void)? {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.lastNavBarStyle) as? (() -> Void)
            return style
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastNavBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 导航栏背景图片，默认nil
    public var kkxNavBarBgImage: UIImage? {
        get {
            let image = objc_getAssociatedObject(self, &AssociatedKeys.backgroundImage) as? UIImage
            return image
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 导航栏风格，默认default
    public var kkxNavBarStyle: UIBarStyle {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.barStyle) as? UIBarStyle
            return style ?? .default
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.barStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// items颜色，默认black
    public var kkxNavTintColor: UIColor {
        get {
            let color = objc_getAssociatedObject(self, &AssociatedKeys.tintColor) as? UIColor
            return color ?? .black
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// bar背景颜色，默认nil
    public var kkxNavBarTintColor: UIColor? {
        get {
            let color = objc_getAssociatedObject(self, &AssociatedKeys.barTintColor) as? UIColor
            return color
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.barTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否半透明，默认true
    public var kkxNavIsTranslucent: Bool {
        get {
            let isTranslucent = objc_getAssociatedObject(self, &AssociatedKeys.isTranslucent) as? Bool
            return isTranslucent ?? true
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isTranslucent, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 标题颜色，默认black
    public var kkxNavBarTitleColor: UIColor {
        get {
            let color = objc_getAssociatedObject(self, &AssociatedKeys.titleColor) as? UIColor
            return color ?? .black
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.titleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 应用设置的导航栏效果
    public func applyNavBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(kkxNavBarBgImage, for: .default)
        navigationController?.navigationBar.barStyle = kkxNavBarStyle
        navigationController?.navigationBar.tintColor = kkxNavTintColor
        navigationController?.navigationBar.barTintColor = kkxNavBarTintColor
        navigationController?.navigationBar.isTranslucent = kkxNavIsTranslucent
        
        setTitleColor(kkxNavBarTitleColor)
    }
    
    /// 设置导航栏背景色，item、title、状态栏为白色
    public func configureImageStyle(_ image: UIImage? = nil) {
        kkxNavBarBgImage = image
        kkxNavTintColor = .white
        kkxNavIsTranslucent = false
        kkxNavBarTitleColor = .white
        kkxStatusBarStyle = .lightContent
    }
    
    /// 设置导航栏为默认半透明，item、title、状态栏为黑色
    public func configureWhiteStyle(_ alpha: CGFloat = 1.0) {
        kkxNavBarBgImage = nil
        kkxNavBarStyle = .default
        kkxStatusBarStyle = .default
        kkxNavIsTranslucent = true
        kkxNavBarTitleColor = .kkxBlack
        kkxNavTintColor = .kkxBlack
    }
    
    /// 设置导航栏为透明色，item、title、状态栏为白色
    public func configureClearStyle() {
        kkxNavBarBgImage = UIColor.clear.image
        kkxNavTintColor = .white
        kkxNavIsTranslucent = true
        kkxNavBarTitleColor = .white
        kkxStatusBarStyle = .lightContent
    }
    
    public func configureThemeStyle() {
        kkxNavBarBgImage = nil
        kkxNavBarStyle = .default
        kkxStatusBarStyle = .lightContent
        kkxNavIsTranslucent = false
        kkxNavBarTitleColor = .white
        kkxNavTintColor = .white
        kkxNavBarTintColor = UIColor.mainNavBar
    }
    
    /// 设置标题颜色
    public func setTitleColor(_ color: UIColor) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingMiddle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }
    
}

// MARK: - ======== UIImagePickerController ========
extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private static var callback: ((UIImage) -> Void)?
    
    /// 选择照片来源
    public func selectedPhoto(_ callback: @escaping ((UIImage) -> Void)) {
        UIViewController.callback = callback
        let cancelAction = UIAlertAction(title: KKXExtensionString("Cancel"), style: .cancel) { (action) in
            
        }
        let photosAction = UIAlertAction(title: KKXExtensionString("Album"), style: .default) { (action) in
            self.fromPhoto()
        }
        let cameraAction = UIAlertAction(title: KKXExtensionString("Camera"), style: .default) { (action) in
            self.fromCamera()
        }
        alert(.actionSheet, actions: [cancelAction, cameraAction, photosAction])
    }
    
    /// 从相册选择图片
    public func fromPhoto(_ callback: ((UIImage) -> Void)? = nil) {
        if callback != nil {
            UIViewController.callback = callback
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.photoAuthorized({ () in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                imagePicker.mediaTypes = ["public.image"]
                self.present(imagePicker, animated: true, completion: nil)
            })
        }
    }
    
    /// 拍照
    public func fromCamera(_ callback: ((UIImage) -> Void)? = nil) {
        if callback != nil {
            UIViewController.callback = callback
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.cameraAuthorized({ () in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                imagePicker.mediaTypes = ["public.image"]
                self.present(imagePicker, animated: true, completion: nil)
            })
        }
    }
    
    /// 选择相册或拍照后回调
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            UIViewController.callback?(image)
        }
        self.dismiss(animated: true, completion:nil)
    }
    
}

// MARK: - ======== 相册、相机授权 ========
extension UIViewController {
    
    // MRK: -------- Helper --------
    
    public func alert(_ style: UIAlertController.Style, title: String? = nil, message: String? = nil, actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in actions {
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    public func retry(message: String? = nil, action retryAction: @escaping (() -> Swift.Void)) {
        let alertAction = UIAlertAction(title: KKXExtensionString("Retry"), style: .default) { (action) in
            retryAction()
        }
        alert(.alert, title: KKXExtensionString("Error"), message: message, actions: [alertAction])
    }
    
    /// 获取相册权限
    public func photoAuthorized(_ authorized: @escaping () -> Void) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                switch status {
                case .authorized:
                    DispatchQueue.safe {
                        authorized()
                    }
                default:
                    self.alertDenied()
                }
            }
        case .restricted:
            alertRestricted()
        case .denied:
            alertDenied()
        case .authorized:
            authorized()
        @unknown default:
            break
        }
    }
    
    /// 获取相机权限
    public func cameraAuthorized(_ authorized: @escaping () -> Void) {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                DispatchQueue.safe {
                    if granted {
                        authorized()
                    }
                    else {
                        self.alertDenied(false)
                    }
                }
            }
        case .restricted:
            alertRestricted(false)
        case .denied:
            alertDenied(false)
        case .authorized:
            authorized()
        @unknown default:
            break
        }
        
    }
    
    /// 设备不支持
    private func alertRestricted(_ photo: Bool = true) {
        let message: String?
        if photo {
            message = KKXExtensionString("error-cannot.use-album")
        }
        else {
            message = KKXExtensionString("error-cannot.use-camera")
        }
        let action = UIAlertAction(title: KKXExtensionString("OK"), style: .default) { (action) in }
        self.alert(.alert, title: nil, message: message, actions: [action])
    }
    
    /// 用户拒绝开启相册或相机权限提示
    private func alertDenied(_ photo: Bool = true) {
        let name = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "unknown"
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? name
        let message: String?
        if photo {
            message = String(format: KKXExtensionString("device-access-your-album"), appName)
        }
        else {
            message = String(format: KKXExtensionString("device-access-your-camera"), appName)
        }
        let action = UIAlertAction(title: KKXExtensionString("OK"), style: .default) { (action) in }
        self.alert(.alert, title: nil, message: message, actions: [action])
    }
    
}

// MARK: - ======== 保存图片到相册 ========
extension UIViewController {
    
    public func kkxSavePhoto(_ image: UIImage?, began: (() -> Void)? = nil, completion: ((Bool, Error?) -> Void)? = nil) {
        guard let _ = image else { return }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                began?()
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image!)
                }) { (success, error) in
                    completion?(success, error)
                }
            default:
                break
            }
        }
    }
    
}

// MARK: - ======== AssociatedKeys ========
fileprivate struct AssociatedKeys {
    static var shouldReloadData = "kkx-shouldReloadData"
    static var plainTableView = "kkx-plainTableView"
    static var groupedTableView = "kkx-groupedTableView"
        
    static var statusBarAnimation = "kkx-statusBarAnimation"
    static var statusBarStyle = "kkx-statusBarStyle"

    static var backgroundImage = "kkx-backgroundImage"
    static var barStyle = "kkx-barStyle"
    static var tintColor = "kkx-tintColor"
    static var barTintColor = "kkx-barTintColor"
    static var isTranslucent = "kkx-isTranslucent"
    static var titleColor = "kkx-titleColor"
    static var customNavBarStyle = "kkx-customNavBarStyle"
    static var lastNavBarStyle = "kkx-lastNavBarStyle"
    
    static var shouldAutorotate = "kkx-shouldAutorotate"
    static var supportedOrientations = "kkx-supportedOrientations"
    static var preferredOrientationForPresentation = "kkx-preferredOrientationForPresentation"
    
    static var reachability = "kkx-reachability"
}
