//
//  UIColor+KKX.swift
//
//  Created by Weichen Jiang on 9/8/18.
//  Copyright © 2018 J&K INVESTMENT HOLDING GROUP. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// 单色转换为image
    public var image: UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 单色转换为image
    public func image(_ size: CGSize, radius: CGFloat = 0) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        context?.addPath(path.cgPath)
        context?.drawPath(using: .fill)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        let w = size.width/2
        let h = size.height/2
        let insets = UIEdgeInsets(top: h-1, left: w-1, bottom: h, right: w)
        let resizeImage = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    public convenience init?(red: UInt32, green: UInt32, blue: UInt32, transparent: CGFloat = 1) {
        let r = min(max(red, 0), 255)
        let g = min(max(green, 0), 255)
        let b = min(max(blue, 0), 255)
        let t = min(max(transparent, 0), 1)
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: t)
    }
    
    /// hexString: 0xFFFF, #EEEEEE, DDDDDD
    public convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var string = ""
        if hexString.lowercased().hasPrefix("0x") {
            string = hexString.replacingOccurrences(of: "0x", with: "")
        }
        else if hexString.lowercased().hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        }
        else {
            string = hexString
        }
        
        if string.count == 3 {
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }
        
        guard let hex = UInt32(string, radix: 16) else {
            return nil
        }
        
        var trans = alpha
        trans = min(max(trans, 0), 1)
        
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: red, green: green, blue: blue, transparent: trans)
    }
    
    /// hex: 0xFFFFFF
    public convenience init?(hex: UInt32, alpha: CGFloat = 1.0) {
        var trans = alpha
        trans = min(max(trans, 0), 1)
        
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: red, green: green, blue: blue, transparent: trans)
    }
    
}

extension UIColor {

    public class var kkxCard: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return .systemGray6
                }
                else {
                    return .white
                }
            }

        } else {
            return .white
        }
    }
    
    public class var kkxSubTitle: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.6)
        }
    }
    
    /// 黑色
    public class var kkxBlack: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    
    /// 白色
    public class var kkxWhite: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    
    public class var kkxTipLabel: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 240.0/255.0, alpha: 0.7)
                }
                else {
                    return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.7)
                }
            }
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.7)
        }
    }
    
    public class var kkxGray: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (collection) -> UIColor in
                if collection.userInterfaceStyle == .dark {
                    return UIColor(white: 0.3, alpha: 1.0)
                }
                else {
                    return UIColor(white: 0.9, alpha: 1.0)
                }
            }
        } else {
            return UIColor(white: 0.9, alpha: 1.0)
        }
    }
    
    // 占位符颜色
    public class var kkxPlaceholderText: UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.3)
        }
    }
    
    // 分割线、边框颜色
    public class var kkxSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return .separator
        } else {
            return UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 67.0/255.0, alpha: 0.3)
        }
    }
    
    public class var kkxSystemBlue: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBlue
        } else {
            return #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        }
    }
}
