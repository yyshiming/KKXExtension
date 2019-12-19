struct KKXExtension {
    var text = "Hello, World!"
}

/// DEBUG环境打印
public func kkxPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items, separator, terminator)
    #endif
}
