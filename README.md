## KKXExtension

## <a id="How_to_use_KKXExtension"></a>How to use KKXExtension
* 打开Xcode
    * 选择 `File` --> `Swift Packages` --> `Add Packages Dependency`
    * `Choose Project` 点击`Next`，搜索`KKXExtension` --> `Next`


## <a id="Date+KKX.swift"></a>Date+KKX.swift
```swift
/// yyyy-MM-dd
public let KKXDate = "yyyy-MM-dd"
/// HH:ss:mm
public let KKXTime = "HH:ss:mm"
/// yyyy-MM-dd HH:ss:mm
public let KKXDateAndTime = "yyyy-MM-dd HH:ss:mm"

extension Date {
    
    /// 转成时间格式字符串(自定义格式)
    /// - Parameter formater: 日期格式，默认 yyyy-MM-dd
    /// - Returns: formater字符串
    public func stringValue(_ formater: String = KKXDate) -> String
}
```

## <a id="DispatchQueue+KKX.swift"></a>DispatchQueue+KKX.swift
```swift
DispatchQueue.safe {
    /// 主线程操作
}
```

## <a id="String+KKX.swift"></a>String+KKX.swift
```swift
let timeString = "2019-12-30 14:32:50"
timeString.dateValue(KKXDateAndTime) // 字符串转日期
let interval = timeString.timeInterval(KKXDateAndTime) // 字符串转毫秒

interval.timeString // “00:00:00”
interval.dateString(KKXDateAndTime) // 毫秒转字符串
```

## <a id="UICollectionView+KKX.swift"></a>UICollectionView+KKX.swift
```swift
let collectionView = UICollectionView()
// cell注册
collectionView.kkx_register(UICollectionViewCell.self)
// cell复用
collectionView.kkx_dequeueReusableCell(forClass: UICollectionViewCell.self, for: IndexPath(row: 0, section: 0))

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let contentWidth: CGFloat = 100.0
    let height = collectionView.kkx_cellHeight(UICollectionViewCell.self, for: indexPath, contentWidth: contentWidth) { (cell) in
        // configure cell
    }
    return height
}

// cell中
override var kkx_totalHeight: CGFloat {
    lastView.frame.maxY + 15
}
```

## <a id="UITableView+KKX.swift"></a>UITableView+KKX.swift
```swift
let tableView = UITableView()
// cell注册
tableView.kkx_register(UITableViewCell.self)
// cell复用
tableView.kkx_dequeueReusableCell(UITableViewCell.self)

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let contentWidth = tableView.frame.size.width
    let height = tableView.kkx_cellHeight(UITableViewCell.self, for: indexPath, contentWidth: contentWidth) { (cell) in
        // configure cell
    }

    return height
}
    
// cell中
override var kkx_totalHeight: CGFloat {
    lastView.frame.maxY + 15
}
```

## <a id="UITableViewController+KKX.swift"></a>UITableViewController+KKX.swift
```swift
// 键盘上方辅助view
let textField = UITextField()
textField.inputAccessoryView = inputAccessoryBar
```

## <a id="UIColor+KKX.swift"></a>UIColor+KKX.swift
```swift
let image = UIColor.white.image // 单色转图片
let color = UIColor(hex: 0xffff)
```

## <a id="UIView+KKX.swift"></a>UIView+KKX.swift
```swift
let button = UIButton(type: .custom)
button.timerObject.timerCount = 60
button.timerDelegate = self
button.startTimer()
```

## <a id="UserDefaults+KKX.swift"></a>UserDefaults+KKX.swift
```swift
// 下标获取/赋值操作
let userDefaults = UserDefaults.standard
userDefaults["key"] = "value"
```
