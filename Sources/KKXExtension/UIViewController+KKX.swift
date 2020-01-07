//
//  UIViewController+KKX.swift
//
//  Created by Weichen Jiang on 8/3/18.
//  Copyright © 2018 J&K INVESTMENT HOLDING GROUP. All rights reserved.
//

import UIKit
import Photos
#if canImport(MBProgressHUD)
import MBProgressHUD
#endif

#if canImport(Reachability)
import Reachability
#endif

/// 自定义返回按钮的viewController需要实现的协议
public protocol KKXCustomBackItem: NSObjectProtocol { }
public protocol KKXCustomNavigationBar: NSObjectProtocol { }

// MARK: - ======== swizzle ========
extension UIViewController {
    
    public class func initializeController() {
        
        kkx_swizzleSelector(self, originalSelector: #selector(willMove(toParent:)), swizzledSelector: #selector(kkx_willMove(toParent:)))
        kkx_swizzleSelector(self, originalSelector: #selector(viewDidLoad), swizzledSelector: #selector(kkx_viewDidLoad))
        kkx_swizzleSelector(self, originalSelector: #selector(viewWillAppear(_:)), swizzledSelector: #selector(kkx_viewWillAppear(_:)))
        kkx_swizzleSelector(self, originalSelector: #selector(viewWillDisappear(_:)), swizzledSelector: #selector(kkx_viewWillDisappear(_:)))
        
        kkx_swizzleSelector(self, originalSelector: #selector(getter: preferredStatusBarStyle), swizzledSelector: #selector(kkx_statusBarUpdateStyle))
        kkx_swizzleSelector(self, originalSelector: #selector(getter: preferredStatusBarUpdateAnimation), swizzledSelector: #selector(kkx_statusBarUpdateAnimation))
        
        kkx_swizzleSelector(self, originalSelector: #selector(getter: shouldAutorotate), swizzledSelector: #selector(kkxShouldAutorotate))
        kkx_swizzleSelector(self, originalSelector: #selector(getter: supportedInterfaceOrientations), swizzledSelector: #selector(kkxSupportedInterfaceOrientations))
        kkx_swizzleSelector(self, originalSelector: #selector(getter: preferredInterfaceOrientationForPresentation), swizzledSelector: #selector(kkxPreferredInterfaceOrientationForPresentation))
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
    public var kkx_statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    /// navbar高度
    public var kkx_navBarHeight: CGFloat {
        return navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    /// tabbar高度
    public var kkx_tabBarHeight: CGFloat {
        return tabBarController?.tabBar.frame.size.height ?? 0
    }
    
    /// statusBar + navbar高度
    public var kkx_top: CGFloat {
        var top: CGFloat = 0
        if !UIApplication.shared.isStatusBarHidden {
            top += kkx_statusBarHeight
        }
        if navigationController?.navigationBar.isHidden == false {
            top += kkx_navBarHeight
        }
        return top
    }

    /// tabbar高度
    public var kkx_bottom: CGFloat {
        var bottom: CGFloat = 0
        if tabBarController?.tabBar.isHidden == false {
            bottom += kkx_tabBarHeight
        }
        return bottom
    }
    
    /// keyWindow安全区域
    ///
    ///     状态栏没有隐藏时
    ///     iPhone X:
    ///     UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0)
    ///     其他：
    ///     UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    public var kkx_safeAreaInsets: UIEdgeInsets {
        var insets: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            insets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        }
        return insets
    }
    
}

// MARK: - ======== MBProgressHUD ========
#if canImport(MBProgressHUD)
public let delayDuration: Double = 1.5
extension UIViewController {
    
    public var kkx_hud: MBProgressHUD {
        guard let hud = objc_getAssociatedObject(self, &AssociatedKeys.kkxHUD) as? MBProgressHUD else {
            let newHUD = MBProgressHUD(view: self.view)
            newHUD.label.numberOfLines = 0
            self.view.addSubview(newHUD)
            objc_setAssociatedObject(self, &AssociatedKeys.kkxHUD, newHUD, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newHUD
        }
        return hud
    }
    
    public func showHUD() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    public func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    @discardableResult
    public func showToast(_ toast: String, duration: Double = delayDuration) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.label.text = toast
        hud.label.numberOfLines = 0
        hud.hide(animated: true, afterDelay: duration)
        return hud
    }
    
}
#endif

// MARK: - ======== Life Circle ========
extension UIViewController {

    @objc private func kkx_willMove(toParent parent: UIViewController?) {
        if let _ = kkx_lastNavBarStyle, parent == nil {
            kkx_lastNavBarStyle?()
        }
    }
    
    @objc private func kkx_viewDidLoad() {
        self.kkx_viewDidLoad()
        if self is KKXCustomBackItem {
            let backItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
            backItem.width = 80
            navigationItem.backBarButtonItem = backItem
        }
    }
    
    @objc private func kkx_viewWillAppear(_ animated: Bool) {
        self.kkx_viewWillAppear(animated)
        if let _ = navigationController, self is KKXCustomNavigationBar {
            reloadNavigationBar()
        }
    }
    
    @objc private func kkx_viewWillDisappear(_ animated: Bool) {
        self.kkx_viewWillDisappear(animated)
        view.endEditing(true)
    }
    
}

// MARK: - ======== 状态栏 Style ========
extension UIViewController {
    
    public var kkx_statusBarAnimation:  UIStatusBarAnimation {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.statusBarAnimation) as? UIStatusBarAnimation
            return style ?? UIStatusBarAnimation.none
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.statusBarAnimation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var kkx_statusBarStyle: UIStatusBarStyle {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.statusBarStyle) as? UIStatusBarStyle
            return style ?? UIStatusBarStyle.default
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.statusBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc private func kkx_statusBarUpdateStyle() -> UIStatusBarStyle {
        return kkx_statusBarStyle
    }
    
    @objc private func kkx_statusBarUpdateAnimation() -> UIStatusBarAnimation {
        return kkx_statusBarAnimation
    }
    
}

// MARK: - ======== 导航栏 Style ========
extension UIViewController {
    
    private func reloadNavigationBar() {
        if kkx_customNavBarStyle == nil {
            kkx_customNavBarStyle = { [unowned self] in
                self.configureWhiteStyle()
                self.applyNavBarStyle()
            }
        }
        
        kkx_customNavBarStyle?()
    }
    
    /// 自定义导航栏风格
    public var kkx_customNavBarStyle: (() -> Void)? {
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
    public var kkx_lastNavBarStyle: (() -> Void)? {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.lastNavBarStyle) as? (() -> Void)
            return style
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastNavBarStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 导航栏背景图片，默认nil
    public var kkx_navBarBgImage: UIImage? {
        get {
            let image = objc_getAssociatedObject(self, &AssociatedKeys.backgroundImage) as? UIImage
            return image
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.backgroundImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 导航栏风格，默认default
    public var kkx_navBarStyle: UIBarStyle {
        get {
            let style = objc_getAssociatedObject(self, &AssociatedKeys.barStyle) as? UIBarStyle
            return style ?? .default
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.barStyle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// items颜色，默认black
    public var kkx_navBarTintColor: UIColor {
        get {
            let color = objc_getAssociatedObject(self, &AssociatedKeys.tintColor) as? UIColor
            return color ?? .black
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.tintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 是否半透明，默认true
    public var kkx_navBarIsTranslucent: Bool {
        get {
            let isTranslucent = objc_getAssociatedObject(self, &AssociatedKeys.isTranslucent) as? Bool
            return isTranslucent ?? true
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isTranslucent, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 标题颜色，默认black
    public var kkx_navBarTitleColor: UIColor {
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
        navigationController?.navigationBar.setBackgroundImage(kkx_navBarBgImage, for: .default)
        navigationController?.navigationBar.barStyle = kkx_navBarStyle
        navigationController?.navigationBar.tintColor = kkx_navBarTintColor
        navigationController?.navigationBar.isTranslucent = kkx_navBarIsTranslucent
        
        setTitleColor(kkx_navBarTitleColor)
    }
    
    /// 设置导航栏背景色，item、title、状态栏为白色
    public func configureImageStyle(_ image: UIImage? = nil) {
        kkx_navBarBgImage = image
        kkx_navBarTintColor = .white
        kkx_navBarIsTranslucent = false
        kkx_navBarTitleColor = .white
        kkx_statusBarStyle = .lightContent
    }
    
    /// 设置导航栏为默认半透明，item、title、状态栏为黑色
    public func configureWhiteStyle(_ alpha: CGFloat = 1.0) {
        kkx_navBarBgImage = nil
        kkx_navBarStyle = .default
        kkx_statusBarStyle = .default
        kkx_navBarIsTranslucent = true
        kkx_navBarTitleColor = .black
        kkx_navBarTintColor = .black
    }
    
    /// 设置导航栏为透明色，item、title、状态栏为白色
    public func configureClearStyle() {
        kkx_navBarBgImage = UIColor.clear.image
        kkx_navBarTintColor = .white
        kkx_navBarIsTranslucent = true
        kkx_navBarTitleColor = .white
        kkx_statusBarStyle = .lightContent
    }
    
    /// 设置标题颜色
    public func setTitleColor(_ color: UIColor) {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingMiddle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
    }
    
}

// MARK: - ======== 屏幕旋转控制，默认所有控制器不旋转 ========
extension UIViewController {
    
    public var kkx_shouldAutorotate: Bool {
        get {
            let autoratate = objc_getAssociatedObject(self, &AssociatedKeys.shouldAutorotate) as? Bool
            return autoratate ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldAutorotate, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var kkx_supportedOrientations: UIInterfaceOrientationMask {
        get {
            let orientation = objc_getAssociatedObject(self, &AssociatedKeys.supportedOrientations) as? UIInterfaceOrientationMask
            return orientation ?? .portrait
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.supportedOrientations, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var kkx_preferredOrientationForPresentation: UIInterfaceOrientation {
        get {
            let orientation = objc_getAssociatedObject(self, &AssociatedKeys.preferredOrientationForPresentation) as? UIInterfaceOrientation
            return orientation ?? .portrait
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.preferredOrientationForPresentation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc private func kkxShouldAutorotate() -> Bool {
        if let tabBarController = self as? UITabBarController,
            let selectedVC = tabBarController.selectedViewController {
            return selectedVC.shouldAutorotate
        }
        else if let navController = self as? UINavigationController,
            let topVC = navController.topViewController {
            return topVC.shouldAutorotate
        }
        return kkx_shouldAutorotate
    }
    
    @objc private func kkxSupportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let tabBarController = self as? UITabBarController,
            let selectedVC = tabBarController.selectedViewController {
            return selectedVC.supportedInterfaceOrientations
        }
        else if let navController = self as? UINavigationController,
            let topVC = navController.topViewController {
            return topVC.supportedInterfaceOrientations
        }
        return kkx_supportedOrientations
    }
    
    @objc private func kkxPreferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if let tabBarController = self as? UITabBarController,
            let selectedVC = tabBarController.selectedViewController {
            return selectedVC.preferredInterfaceOrientationForPresentation
        }
        else if let navController = self as? UINavigationController,
            let topVC = navController.topViewController {
            return topVC.preferredInterfaceOrientationForPresentation
        }
        return kkx_preferredOrientationForPresentation
    }
    
}

#if canImport(Reachability)
// MARK: - ======== 网络状态监听 ========
public protocol KKXReachabilityDelegate: AnyObject {
    func onReachable(_ reachability: Reachability?)
    func onUnreachable(_ reachability: Reachability?)
}
extension KKXReachabilityDelegate {
    public func onReachable(_ reachability: Reachability?) { }
    public func onUnreachable(_ reachability: Reachability?) { }
}

extension UIViewController {
    
    private weak var kkx_reachabilityDelegate: KKXReachabilityDelegate? {
        return self as? KKXReachabilityDelegate
    }
    
    public var reachability: Reachability? {
        var reachability = objc_getAssociatedObject(self, &AssociatedKeys.reachability) as? Reachability
        if reachability == nil {
            reachability = try? Reachability()
            reachability?.whenReachable = { [weak self](reachability) in
                self?.kkx_reachabilityDelegate?.onReachable(reachability)
            }
            reachability?.whenUnreachable = { [weak self](reachability) in
                self?.kkx_reachabilityDelegate?.onUnreachable(reachability)
            }
            if let _ = reachability {
                objc_setAssociatedObject(self, &AssociatedKeys.reachability, reachability!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
        return reachability
    }
    
}
#endif

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
    
    public func kkx_savePhoto(_ image: UIImage?) {
        guard let image = image else { return }
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                #if canImport(MBProgressHUD)
                DispatchQueue.safe {
                    self.kkx_hud.mode = .indeterminate
                    self.kkx_hud.label.text = nil
                    self.kkx_hud.show(animated: true)
                }
                #endif

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { (success, error) in
                    if success {
                        #if canImport(MBProgressHUD)
                        DispatchQueue.safe {
                            self.kkx_hud.mode = .text
                            self.kkx_hud.label.text = KKXExtensionString("saved-to-album")
                            self.kkx_hud.hide(animated: true, afterDelay: delayDuration)
                        }
                        #endif
                    }
                    else {
                        kkxPrint(KKXExtensionString("save-failure") + "：" + (error?.localizedDescription ?? ""))
                    }
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
    
    static var kkxHUD = "kkx-hud"
    
    static var statusBarAnimation = "kkx-statusBarAnimation"
    static var statusBarStyle = "kkx-statusBarStyle"

    static var backgroundImage = "kkx-backgroundImage"
    static var barStyle = "kkx-barStyle"
    static var tintColor = "kkx-tintColor"
    static var isTranslucent = "kkx-isTranslucent"
    static var titleColor = "kkx-titleColor"
    static var customNavBarStyle = "kkx-customNavBarStyle"
    static var lastNavBarStyle = "kkx-lastNavBarStyle"
    
    static var shouldAutorotate = "kkx-shouldAutorotate"
    static var supportedOrientations = "kkx-supportedOrientations"
    static var preferredOrientationForPresentation = "kkx-preferredOrientationForPresentation"
    
    static var reachability = "kkx-reachability"
}
