//
//  UICollectionView+KKX.swift
//
//  Created by ming on 2019/5/9.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

// MARK: - ======== UICollectionView注册、复用 ========
extension UICollectionView {

    /// 从Nib注册复用Cell
    /// - Parameter cellClass: 类型
    public func kkx_registerFromNib<T: UICollectionViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    /// 从Nib注册复用Cell
    /// - Parameter nib: Nib
    /// - Parameter cellClass: 类型
    public func kkx_register<T: UICollectionViewCell>(_ nib: UINib?, forCellWithClass cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    /// 注册复用Cell
    /// - Parameter cellClass: 类型
    public func kkx_register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        register(T.self, forCellWithReuseIdentifier: identifier)
    }
    
    /// 注册ReusableView
    /// - Parameter viewClass: 类型
    /// - Parameter kind: kind
    public func kkx_register<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind kind: String) {
        let identifier = String(describing: viewClass)
        register(T.self,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: identifier)
    }
    
    /// 从Nib注册ReusableView
    /// - Parameter kind: kind
    /// - Parameter viewClass: 类型
    public func kkx_registerFromNib<T: UICollectionReusableView>(_ viewClass: T.Type, forSupplementaryViewOfKind kind: String) {
        let identifier = String(describing: viewClass)
        register(UINib(nibName: identifier, bundle: nil),
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: identifier)
    }
    
    /// 从Nib注册ReusableView
    /// - Parameter nib: Nib
    /// - Parameter kind: kind
    /// - Parameter viewClass: 类型
    public  func kkx_register<T: UICollectionReusableView>(
        _ nib: UINib?,
        forSupplementaryViewOfKind kind: String,
        withViewClass viewClass: T.Type) {
        let identifier = String(describing: viewClass)
        register(nib,
                 forSupplementaryViewOfKind: kind,
                 withReuseIdentifier: identifier)
    }
    
    /// 获取复用cell
    /// - Parameter aClass: 类型
    /// - Parameter indexPath: indexPath
    public func kkx_dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        
        let identifier = String(describing: cellClass)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(identifier) with reuse identifier of \(identifier)")
        }
        return cell
    }
    
    /// 获取复用ReusableView
    /// - Parameter kind: kind
    /// - Parameter viewClass: 类型
    /// - Parameter indexPath: indexPath
    public func kkx_dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        _ viewClass: T.Type,
        ofKind kind: String,
        for indexPath: IndexPath) -> T {
        
        let identifier = String(describing: viewClass)
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Couldn't find UICollectionReusableView for \(identifier), make sure the view is registered with collection view")
        }
        return cell
    }
    
}

// MARK: - ======== UICollectionViewcell高度 ========
extension UICollectionView {
    
    private func kkx_templateCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        
        let name = String(describing: cellClass) + "Template"
        var cell = templateCells[name] as? T
        if cell == nil {
            if #available(iOS 11.0, *) {
                // iOS 10会崩溃
                cell = kkx_dequeueReusableCell(cellClass, for: indexPath)
            } else {
                cell = cellClass.init()
            }
            if cell == nil {
                fatalError("Unable to dequeue \(String(describing: cellClass)) with reuse identifier of \(String(describing: cellClass))")
            }
            templateCells[name] = cell
        }
        return cell!
    }
    
    /// cell中赋值calculateHeight后可以用此方法获取cell高度
    public func kkx_cellHeight<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath, contentWidth: CGFloat, configuration: ((T) -> Void)) -> CGFloat {
        guard shouldKeepCaches, let height = cellHeightCaches[indexPath] else {
            let cell = kkx_templateCell(cellClass, for: indexPath)
            cell.frame.size.width = contentWidth
            configuration(cell)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            let height = cell.kkx_totalHeight
            cellHeightCaches[indexPath] = height
            
            kkxPrint("Calculate height: \(height) for indexPath: \(indexPath.section)-\(indexPath.item)")
            return height
        }
        
        kkxPrint("Use cached height: \(height) for indexPath: \(indexPath.section)-\(indexPath.item)")
        return height
    }
    
}

// MARK: - ======== UICollectionViewReusableView高度 ========
extension UICollectionView {
    
    private func kkx_templateReusableView<T: UICollectionReusableView>(_ viewClass: T.Type, ofKind kind: String, for section: Int) -> T {
        
        let name = String(describing: viewClass) + "Template"
        var view = templateHeaders[name] as? T
        if kind == UICollectionView.elementKindSectionFooter {
            view = templateFooters[name] as? T
        }
        if view == nil {
            if #available(iOS 11.0, *) {
                // iOS 10会崩溃
                let indexPath = IndexPath(item: 0, section: section)
                view = kkx_dequeueReusableSupplementaryView(viewClass, ofKind: kind, for: indexPath)
            } else {
                view = viewClass.init()
            }
            if view == nil {
                fatalError("Unable to dequeue \(String(describing: viewClass)) with reuse identifier of \(String(describing: viewClass))")
            }
            if kind == UICollectionView.elementKindSectionFooter {
                templateFooters[name] = view
            } else {
                templateHeaders[name] = view
            }
        }
        return view!
    }
    
    /// cell中赋值calculateHeight后可以用此方法获取cell高度
    public func kkx_reusableViewHeight<T: UICollectionReusableView>(
        _ viewClass: T.Type,
        ofKind kind: String,
        for section: Int,
        contentWidth: CGFloat,
        configuration: ((T) -> Void)) -> CGFloat {
        
        var height = headerHeightCaches[section]
        if kind == UICollectionView.elementKindSectionFooter {
            height = footerHeightCaches[section]
        }
        guard shouldKeepCaches, let cacheHeight = height else {
            let view = kkx_templateReusableView(viewClass, ofKind: kind, for: section)
            view.frame.size.width = contentWidth
            configuration(view)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            let h = view.kkx_totalHeight
            headerHeightCaches[section] = h
            if kind == UICollectionView.elementKindSectionFooter {
                footerHeightCaches[section] = h
            } else {
                headerHeightCaches[section] = h
            }
            
            kkxPrint("Calculate height: \(h) for section: \(section)")
            return h
        }
        
        kkxPrint("Use cached height: \(cacheHeight) for section: \(section)")
        return cacheHeight
    }
    
}

// MARK: - ======== swizzle ========
extension UICollectionView {
    
    public class func initializeCollectionView() {
        kkx_swizzleSelector(self, originalSelector: #selector(reloadData), swizzledSelector: #selector(kkx_reloadData))
        kkx_swizzleSelector(self, originalSelector: #selector(reloadItems(at:)), swizzledSelector: #selector(kkx_reloadItems(at:)))
        kkx_swizzleSelector(self, originalSelector: #selector(reloadSections(_:)), swizzledSelector: #selector(kkx_reloadSections(_:)))
        kkx_swizzleSelector(self, originalSelector: #selector(deleteItems(at:)), swizzledSelector: #selector(kkx_deleteItems(at:)))
        kkx_swizzleSelector(self, originalSelector: #selector(deleteSections(_:)), swizzledSelector: #selector(kkx_deleteSections(_:)))
        kkx_swizzleSelector(self, originalSelector: #selector(insertItems(at:)), swizzledSelector: #selector(kkx_insertItems(at:)))
        kkx_swizzleSelector(self, originalSelector: #selector(insertSections(_:)), swizzledSelector: #selector(kkx_insertSections(_:)))
    }
    
    @objc private func kkx_reloadData() {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_reloadData()
    }
    
    @objc private func kkx_reloadItems(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            cellHeightCaches.removeValue(forKey: indexPath)
        }

        kkx_reloadItems(at: indexPaths)
        kkxPrint("reloadItems at \(indexPaths)")
    }
    
    @objc private func kkx_reloadSections(_ sections: IndexSet) {
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
        
        kkx_reloadSections(sections)
        kkxPrint("reloadSections at \(indexPaths.keys)")
    }
    
    @objc private func kkx_deleteItems(at indexPaths: [IndexPath]) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_deleteItems(at: indexPaths)
        kkxPrint("deleteItems at \(indexPaths)")
    }
    
    @objc private func kkx_deleteSections(_ sections: IndexSet) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_deleteSections(sections)
        kkxPrint("deleteSections at \(sections)")
    }
    
    @objc private func kkx_insertItems(at indexPaths: [IndexPath]) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_insertItems(at: indexPaths)
        kkxPrint("insertItems at \(indexPaths)")
    }
    
    @objc private func kkx_insertSections(_ sections: IndexSet) {
        cellHeightCaches.removeAll()
        headerHeightCaches.removeAll()
        footerHeightCaches.removeAll()
        
        kkx_insertSections(sections)
        kkxPrint("insertSections at \(sections)")
    }
}

extension UICollectionView {
    
    public var contentWidth: CGFloat {
        return frame.size.width - contentInset.left - contentInset.right
    }
    
    public var contentHeight: CGFloat {
        return frame.size.height - contentInset.top - contentInset.bottom
    }
    
}
extension UICollectionViewLayout {
    
    public var width: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        return collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
    }
    
    public var height: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        return collectionView.frame.height - collectionView.contentInset.top - collectionView.contentInset.bottom
    }
    
    public func insetsForSection(_ section: Int) -> UIEdgeInsets {
        guard let collectionView = collectionView, let flowLayoutDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout, let inset = flowLayoutDelegate.collectionView?(collectionView, layout: self, insetForSectionAt: section) else {
            if let flowLayout = self as? UICollectionViewFlowLayout {
                return flowLayout.sectionInset
            }
            return .zero
        }
        
        return inset
    }
    
    public var sections: Int {
        if let collectionView = collectionView,
            let dataSource = collectionView.dataSource,
            let sections = dataSource.numberOfSections?(in: collectionView) {
            return sections
        }
        return 0
    }
    
    public func items(in section: Int) -> Int {
        if let collectionView = collectionView,
            let delegate = collectionView.dataSource {
            return delegate.collectionView(collectionView, numberOfItemsInSection: section)
        }
        return 0
    }
    
    public func itemSize(at indexPath: IndexPath) -> CGSize {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            return size
        }
        return .zero
    }
    
    public func headerSize(in section: Int) -> CGSize {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
            return size
        }
        return .zero
    }
    
    public func footerSize(in section: Int) -> CGSize {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
            let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
            return size
        }
        return .zero
    }
    
    public func decorationInsetsForSection(_ section: Int) -> UIEdgeInsets {
        if let collectionView = collectionView,
            let delegate = collectionView.delegate as? HSCollectionViewDelegate {
            let inset = delegate.collectionView(collectionView, layout: self, decorationViewInsetForSectionAt: section)
            return inset
        }
        return .zero
    }
    
}

public protocol KKXCollectionViewDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, hasDecorationViewAt section: Int) -> Bool
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, decorationViewInsetForSectionAt section: Int) -> UIEdgeInsets
}

extension KKXCollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, hasDecorationViewAt section: Int) -> Bool {
        return false
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, decorationViewInsetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
}
