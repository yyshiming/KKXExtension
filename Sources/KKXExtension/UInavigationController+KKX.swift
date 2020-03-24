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
        kkxSwizzleSelector(self, originalSelector: #selector(pushViewController(_:animated:)), swizzledSelector: #selector(kkxPushViewController(_:animated:)))
    }
    
    @objc private func kkxPushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if self.viewControllers.count == 1 { viewController.hidesBottomBarWhenPushed = true }
        if viewController is KKXCustomNavigationBar {
            viewController.kkxLastNavBarStyle = self.topViewController?.kkxCustomNavBarStyle
        }
        self.kkxPushViewController(viewController, animated: animated)
    }
}

extension UINavigationController {
    
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }

    open override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
    
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return topViewController
    }
    
    open override var shouldAutorotate: Bool {
        if let vc = topViewController {
            return vc.shouldAutorotate
        }
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let vc = topViewController {
            return vc.supportedInterfaceOrientations
        }
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let vc = topViewController {
            return vc.preferredInterfaceOrientationForPresentation
        }
        return .portrait
    }
    
    open override var prefersStatusBarHidden: Bool {
        if let vc = topViewController {
            return vc.prefersStatusBarHidden
        }
        return false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let vc = topViewController {
            return vc.preferredStatusBarStyle
        }
        return .default
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        if let vc = topViewController {
            return vc.preferredStatusBarUpdateAnimation
        }
        return .none
    }
    
}
