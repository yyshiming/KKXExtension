//
//  UInavigationController+KKX.swift
//
//  Created by ming on 2019/4/8.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    // MARK: -------- swizzle --------
    
    public static func initializeNavController() {
        kkx_swizzleSelector(self, originalSelector: #selector(pushViewController(_:animated:)), swizzledSelector: #selector(kkx_pushViewController(_:animated:)))
    }
    
    @objc private func kkx_pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.viewControllers.count == 1 { viewController.hidesBottomBarWhenPushed = true }
        self.kkx_pushViewController(viewController, animated: animated)
    }
}
