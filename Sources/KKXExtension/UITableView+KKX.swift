//
//  UITableView+KKX.swift
//
//  Created by ming on 2019/6/4.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

// MARK: - ======== UITableView注册、复用 ========
extension UITableView {

    /// 注册复用Cell
    /// - Parameter cellClass: 类型
    public func kkx_register<T: UITableViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        register(T.self, forCellReuseIdentifier: identifier)
    }

    /// 从nib注册复用Cell
    /// - Parameter cellClass: 类型
    public func kkx_register<T: UITableViewCell>(_ nib: UINib?, forCellClass cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    /// 复用cell
    /// - Parameter cellClass: 类型
    public func kkx_dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type) -> T {
        let identifier = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withIdentifier: identifier) as? T else {
            fatalError("Couldn't find UITableViewCell for \(identifier), make sure the cell is registered with table view")
        }
        return cell
    }
    
    /// 复用cell
    /// - Parameter cellClass: 类型
    public func kkx_dequeueReusableCell<T: UITableViewCell>(
        _ cellClass: T.Type,
        for indexPath: IndexPath) -> T {
        
        let identifier = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(identifier) with reuse identifier of \(identifier)")
        }
        return cell
    }
    
    /// 从Nib注册复用header、footer
    /// - Parameter viewClass: 类型
    public func kkx_register<T: UITableViewHeaderFooterView>(
        _ nib: UINib?,
        forHeaderFooterViewClass viewClass: T.Type) {
        let identifier = String(describing: viewClass)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }

    /// 注册复用header、footer
    /// - Parameter viewClass: 类型
    public func kkx_register<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) {
        let identifier = String(describing: viewClass)
        register(T.self, forHeaderFooterViewReuseIdentifier: identifier)
    }

    /// 复用HeaderFooter
    /// - Parameter viewClass: 类型
    public func kkx_dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_ viewClass: T.Type) -> T {
        let identifier = String(describing: viewClass)
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T else {
            fatalError("Couldn't find UITableViewHeaderFooterView for \(identifier), make sure the view is registered with table view")
        }
        return headerFooterView
    }
}

extension UITableView {
    public func kkx_templateCell<T: UITableViewCell>(
        _ cellClass: T.Type,
        for indexPath: IndexPath) -> T {
        
        let name = String(describing: cellClass) + "Templete"
        var cell = templateCells[name] as? T
        if cell == nil {
            cell = cellClass.init()
            if cell == nil {
                fatalError("Unable to dequeue \(String(describing: cellClass)) with reuse identifier of \(String(describing: cellClass))")
            }
            templateCells[name] = cell
        }
        return cell!
    }
    
    /// cell中赋值calculateHeight后可以用此方法获取cell高度，
    /// 只适合用在 accessoryType = .none 的时候
    public func kkx_cellHeight<T: UITableViewCell>(
        _ cellClass: T.Type,
        for indexPath: IndexPath,
        contentWidth: CGFloat,
        configuration: ((T) -> Void)) -> CGFloat {
        
        guard shouldKeepCaches, let height = cellHeightCaches[indexPath] else {
            let cell = kkx_templateCell(cellClass, for: indexPath)
            cell.frame.size.width = contentWidth
            configuration(cell)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            
            let height = cell.kkxTotalHeight
            cellHeightCaches[indexPath] = height
            
            kkxPrint("Calculate height: \(height) for indexPath: \(indexPath.section)-\(indexPath.item)")
            return height
        }
        
        kkxPrint("Use cached height: \(height) for indexPath: \(indexPath.section)-\(indexPath.item)")
        return height
    }
    
}

// MARK: - ======== UITableViewHeaderFooterView高度 ========
extension UITableView {
    
    private func kkx_templateHeaderFooter<T: UITableViewHeaderFooterView>(
        _ viewClass: T.Type,
        for section: Int) -> T {
        
        let name = String(describing: viewClass) + "Template"
        var view = templateHeaders[name] as? T
        
        if view == nil {
            view = viewClass.init()
            if view == nil {
                fatalError("Unable to dequeue \(String(describing: viewClass)) with reuse identifier of \(String(describing: viewClass))")
            }
            templateHeaders[name] = view
        }
        return view!
    }
    
    /// cell中赋值calculateHeight后可以用此方法获取cell高度
    public func kkx_headerFooterHeight<T: UITableViewHeaderFooterView>(
        _ viewClass: T.Type,
        for section: Int,
        contentWidth: CGFloat,
        configuration: ((T) -> Void)) -> CGFloat {
        
        let height = headerHeightCaches[section]
        guard shouldKeepCaches, let cacheHeight = height else {
            let view = kkx_templateHeaderFooter(viewClass, for: section)
            view.frame.size.width = contentWidth
            configuration(view)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            let h = view.kkxTotalHeight
            headerHeightCaches[section] = h
            
            kkxPrint("Calculate height: \(h) for section: \(section)")
            return h
        }
        
        kkxPrint("Use cached height: \(cacheHeight) for section: \(section)")
        return cacheHeight
    }
    
}

extension UITableView {
    
    /// 滚动到顶部
    public func kkx_scrollToTop(animated: Bool = true) {
        setContentOffset(.zero, animated: animated)
    }
    
    /// 滚动到底部
    public func kkx_scrollToBottom(animated: Bool = true) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: animated)
    }
    
}

// MARK: - ======== swizzle ========
extension UITableView {
    
    public class func initializeTableView() {
        kkxSwizzleSelector(self, originalSelector: #selector(reloadData), swizzledSelector: #selector(kkx_reloadData))
        kkxSwizzleSelector(self, originalSelector: #selector(reloadRows(at:with:)), swizzledSelector: #selector(kkx_reloadRows(at:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(reloadSections(_:with:)), swizzledSelector: #selector(kkx_reloadSections(_:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(deleteRows(at:with:)), swizzledSelector: #selector(kkx_deleteRows(at:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(deleteSections(_:with:)), swizzledSelector: #selector(kkx_deleteSections(_:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(insertRows(at:with:)), swizzledSelector: #selector(kkx_insertRows(at:with:)))
        kkxSwizzleSelector(self, originalSelector: #selector(insertSections(_:with:)), swizzledSelector: #selector(kkx_insertSections(_:with:)))
    }
    
    @objc private func kkx_reloadData() {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_reloadData()
    }
    
    @objc private func kkx_reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        for indexPath in indexPaths {
            cellHeightCaches.removeValue(forKey: indexPath)
        }

        kkx_reloadRows(at: indexPaths, with: animation)
        kkxPrint("reloadRows at \(indexPaths)")
    }
    
    @objc private func kkx_reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        let indexPaths = cellHeightCaches.filter { (caches) -> Bool in
            return sections.contains(caches.key.section)
        }
        for indexPath in indexPaths.keys {
            cellHeightCaches.removeValue(forKey: indexPath)
        }
        
        let headerSections = headerHeightCaches.filter { (caches) -> Bool in
            return sections.contains(caches.key)
        }
        for section in headerSections.keys {
            headerHeightCaches.removeValue(forKey: section)
        }
        
        let footerSections = footerHeightCaches.filter { (caches) -> Bool in
            return sections.contains(caches.key)
        }
        for section in footerSections.keys {
            footerHeightCaches.removeValue(forKey: section)
        }
        
        kkx_reloadSections(sections, with: animation)
        kkxPrint("reloadSections at \(indexPaths.keys)")
    }
    
    @objc private func kkx_deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_deleteRows(at: indexPaths, with: animation)
        kkxPrint("deleteRows at \(indexPaths)")
    }
    
    @objc private func kkx_deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_deleteSections(sections, with: animation)
        kkxPrint("deleteSections at \(sections)")
    }
    
    @objc private func kkx_insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_insertRows(at: indexPaths, with: animation)
        kkxPrint("insertRows at \(indexPaths)")
    }
    
    @objc private func kkx_insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_insertSections(sections, with: animation)
        kkxPrint("insertSections at \(sections)")
    }
}

// MARK: - ======== KKXAssociatedKeys ========
fileprivate struct AssociatedKeys {
    
}
