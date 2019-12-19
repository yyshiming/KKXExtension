//
//  UIScrollView+KKX.swift
//
//  Created by ming on 2019/5/9.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit
#if canImport(MJRefresh)
import MJRefresh
#endif

extension UIScrollView {
    
    /// 分页加载页数, 默认 1
    public var pageNumber: Int {
        get {
            let page = objc_getAssociatedObject(self, &AssociatedKeys.pageNumber) as? Int
            return page ?? 1
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pageNumber, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 分页加载每页条数，默认 10
    public var pageSize: Int {
        get {
            let page = objc_getAssociatedObject(self, &AssociatedKeys.pageSize) as? Int
            return page ?? kkx_defaultSize
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pageSize, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var kkx_defaultSize: Int {
        return 10
    }
    
    public var isFirstLoad: Bool {
        get {
            let first = objc_getAssociatedObject(self, &AssociatedKeys.isFirstLoad) as? Bool
            return first ?? true
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isFirstLoad, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var isHideOnFirstLoad: Bool {
        get {
            let isHide = objc_getAssociatedObject(self, &AssociatedKeys.isHideOnFirstLoad) as? Bool
            return isHide ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isHideOnFirstLoad, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var hasMoreData: Bool {
        get {
            let hasMoreData = objc_getAssociatedObject(self, &AssociatedKeys.hasMoreData) as? Bool
            return hasMoreData ?? true
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.hasMoreData, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    #if canImport(MJRefresh)
    public func beginRefreshing(_ isRefresh: Bool = true) {
        if isFirstLoad {
            self.superview?.kkx_loading = true
            if self.isHideOnFirstLoad {
                self.isHidden = true
            }
        }
        if isRefresh {
            self.hasMoreData = true
            self.mj_footer?.resetNoMoreData()
        }
    }
    
    public func endRefreshing() {
        if isFirstLoad {
            self.superview?.kkx_loading = false
            self.isFirstLoad = false
            self.isHidden = false
        }
        
        self.mj_header?.endRefreshing()
        if hasMoreData {
            self.mj_footer?.endRefreshing()
        }
        else {
            self.mj_footer?.endRefreshingWithNoMoreData()
        }
    }
    #endif
    
}

// MARK: - ======== 缓存属性 ========
extension UIScrollView {
    
    /// cell高度缓存
    public var cellHeightCaches: [IndexPath: CGFloat] {
        get {
            guard let heightCaches = objc_getAssociatedObject(self, &AssociatedKeys.cellHeightCaches) as? [IndexPath: CGFloat] else {
                let heightCaches: [IndexPath: CGFloat] = [:]
                objc_setAssociatedObject(self, &AssociatedKeys.cellHeightCaches, heightCaches, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return heightCaches
            }
            return heightCaches
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.cellHeightCaches, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// header高度缓存
    public var headerHeightCaches: [Int: CGFloat] {
        get {
            guard let heightCaches = objc_getAssociatedObject(self, &AssociatedKeys.headerHeightCaches) as? [Int: CGFloat] else {
                let heightCaches: [Int: CGFloat] = [:]
                objc_setAssociatedObject(self, &AssociatedKeys.headerHeightCaches, heightCaches, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return heightCaches
            }
            return heightCaches
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.headerHeightCaches, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// footer高度缓存
    public var footerHeightCaches: [Int: CGFloat] {
        get {
            guard let heightCaches = objc_getAssociatedObject(self, &AssociatedKeys.footerHeightCaches) as? [Int: CGFloat] else {
                let heightCaches: [Int: CGFloat] = [:]
                objc_setAssociatedObject(self, &AssociatedKeys.footerHeightCaches, heightCaches, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return heightCaches
            }
            return heightCaches
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.footerHeightCaches, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var templateCells: [String: Any] {
        get {
            guard let templateCells = objc_getAssociatedObject(self, &AssociatedKeys.templateCells) as? [String: Any] else {
                let templateCells: [String: Any] = [:]
                objc_setAssociatedObject(self, &AssociatedKeys.templateCells, templateCells, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return templateCells
            }
            return templateCells
            
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.templateCells, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var templateHeaders: [String: Any] {
        get {
            guard let templateCells = objc_getAssociatedObject(self, &AssociatedKeys.templateHeaders) as? [String: Any] else {
                let templateCells: [String: Any] = [:]
                objc_setAssociatedObject(self, &AssociatedKeys.templateHeaders, templateCells, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return templateCells
            }
            return templateCells
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.templateHeaders, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var templateFooters: [String: Any] {
        get {
            guard let templateCells = objc_getAssociatedObject(self, &AssociatedKeys.templateFooters) as? [String: Any] else {
                let templateCells: [String: Any] = [:]
                objc_setAssociatedObject(self, &AssociatedKeys.templateFooters, templateCells, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return templateCells
            }
            return templateCells
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.templateFooters, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 是否使用缓存
    public var shouldKeepCaches: Bool {
        get {
            guard let shouldKeepCaches = objc_getAssociatedObject(self, &AssociatedKeys.shouldKeepCaches) as? Bool else {
                let shouldKeepCaches = false
                objc_setAssociatedObject(self, &AssociatedKeys.shouldKeepCaches, shouldKeepCaches, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return shouldKeepCaches
            }
            return shouldKeepCaches
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.shouldKeepCaches, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - ======== KKXAssociated ========
fileprivate struct AssociatedKeys {
    static var pageNumber = "kkx-pageNumber"
    static var pageSize = "kkx-pageSize"
    static var isFirstLoad = "kkx-isFirstLoad"
    static var isHideOnFirstLoad = "kkx-isHideOnFirstLoad"
    static var hasMoreData = "kkx-hasMoreData"
    
    static var cellHeightCaches = "kkx-cellHeightCaches"
    static var headerHeightCaches = "kkx-headerHeightCaches"
    static var footerHeightCaches = "kkx-footerHeightCaches"
    static var templateCells = "kkx-templateCells"
    static var templateHeaders = "kkx-templateHeaders"
    static var templateFooters = "kkx-templateFooters"
    static var shouldKeepCaches = "kkx-shouldKeepCaches"
}
