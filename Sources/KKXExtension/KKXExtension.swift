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
