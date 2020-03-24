import UIKit

struct KKXExtension {
    var text = "Hello, World!"
    public static func initializeSwizzle() {
        UITableView.initializeTableView()
        UICollectionView.initializeCollectionView()
        UIViewController.initializeController()
        UINavigationController.initializeNavController()
    }
}

/// 获取目前屏幕中显示的viewController
public var kkxTopViewController: UIViewController? {
    var controller = UIApplication.shared.keyWindow?.rootViewController
    while true {
        if let presentedControler = controller?.presentedViewController {
            controller = presentedControler
        }
        else if let topViewController = (controller as? UINavigationController)?.topViewController {
            controller = topViewController
        }
        else if let selectedController = (controller as? UITabBarController)?.selectedViewController {
            controller = selectedController
        }
        else {
            break
        }
    }
    return controller
}

/// 注册推送通知
public func registerRemoteNotifications() {
    if #available(iOS 10.0, *) {
        let center = UNUserNotificationCenter.current()
        let options = UNAuthorizationOptions.badge.rawValue | UNAuthorizationOptions.sound.rawValue | UNAuthorizationOptions.alert.rawValue
        center.requestAuthorization(options: UNAuthorizationOptions(rawValue: options)) { (granted, error) in
            if granted {
                DispatchQueue.safe {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else {
                DispatchQueue.safe {
                    kkxPrint("请开启推送功能否则无法收到推送通知")
                }
            }
        }
    } else {
        let types = UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.alert.rawValue
        let settings = UIUserNotificationSettings(types: UIUserNotificationType(rawValue: types), categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
    }
}

// MARK: - ======== LocalizedString ========
public func KKXExtensionString(_ key: String) -> String {
    return NSLocalizedString(key, tableName: "KKXExtension", bundle: Bundle.main, value: "", comment: "")
}

/// DEBUG环境打印
public func kkxPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items, separator, terminator)
    #endif
}

/// DEBUG环境打印
public func kkxDebugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    debugPrint(items, separator, terminator)
    #endif
}
