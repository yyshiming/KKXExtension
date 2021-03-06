//
//  KKXNoDataView.swift
//
//  Created by ming on 2019/5/9.
//  Copyright © 2019 ming. All rights reserved.
//

import UIKit

public protocol KKXNoDataViewDelegate: AnyObject {
    func noDataViewDidTap(_ noDataView: KKXNoDataView)
    func noDataViewDidClickButton(_ noDataView: KKXNoDataView)
}

extension KKXNoDataViewDelegate {
    public func noDataViewDidTap(_ noDataView: KKXNoDataView) { }
    public func noDataViewDidClickButton(_ noDataView: KKXNoDataView) { }
}

public class KKXNoDataView: UIView {
    
    // MARK: -------- Properties --------
    
    public weak var delegate: KKXNoDataViewDelegate?
    public var spacing: CGFloat = 10 {
        didSet {
            stackView.spacing = spacing
        }
    }
    public var offset: UIOffset = .zero {
        didSet {
            centerX?.constant = offset.horizontal
            centerY?.constant = offset.vertical
        }
    }
    public var margin: CGFloat = 30 {
        didSet {
            leading?.constant = margin
        }
    }
    public var imageView: UIImageView? {
        if _imageView == nil {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            _imageView = imageView
            stackView.insertArrangedSubview(imageView, at: 0)
        }
        
        return _imageView
    }
    
    public var titleLabel: UILabel? {
        if _titleLabel == nil {
            let label = UILabel()
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 18.0)
            label.textColor = UIColor.kkxSubTitle
            label.translatesAutoresizingMaskIntoConstraints = false
            _titleLabel = label
            if let _ = _imageView {
                stackView.insertArrangedSubview(label, at: 1)
            }
            else {
                stackView.insertArrangedSubview(label, at: 0)
            }
        }
        return _titleLabel
    }
    
    public var button: UIButton? {
        if _button == nil {
            let button = UIButton(type: .system)
            button.tintColor = UIColor.kkxSystemBlue
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            _button = button
            stackView.addArrangedSubview(button)
        }
        
        return _button
    }
    
    // MARK: -------- Private Properties --------

    private var leading: NSLayoutConstraint?
    private var centerX: NSLayoutConstraint?
    private var centerY: NSLayoutConstraint?
    
    private var _imageView: UIImageView?
    private var _titleLabel: UILabel?
    private var _button: UIButton?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = spacing
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: -------- Init --------
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tapGesture)
        addSubview(stackView)
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: -------- Actions --------
    
    private func configureConstraints() {
        removeConstraints(constraints)
        leading = NSLayoutConstraint(
            item: stackView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 30.0
        )
        leading?.isActive = true
        NSLayoutConstraint(
            item: stackView,
            attribute: .top,
            relatedBy: .greaterThanOrEqual,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 30.0
        ).isActive = true
        centerX = NSLayoutConstraint(
            item: stackView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0
        )
        centerX?.isActive = true
        centerY = NSLayoutConstraint(
            item: stackView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0
        )
        centerY?.isActive = true
    }
    
    @objc private func tapAction() {
        delegate?.noDataViewDidTap(self)
    }
    
    @objc private func clickButton() {
        delegate?.noDataViewDidClickButton(self)
    }
    
}
