//
//  VDTabView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

enum VDTopBarDistributionStyle {
    case inScreen
    case outScreen
}

public class VDTabView: UIView {
    
    public var titles = [String]() {
        didSet {
            createTabs()
        }
    }
    
    public var isScrollEnabled = true {
        didSet {
            scrollView.isScrollEnabled = isScrollEnabled
            createTabs()
        }
    }
    
    private(set) var selectedIndex : Int = 0
    public var titleFont : UIFont = UIFont.systemFont(ofSize: 15)
    public var titleAdjustsFontSizeToFitWidth : Bool = true
    
    let indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 2))
    
    private let scrollView = UIScrollView()
    private var titleLbls = [TabSelectorLabel]()
    private var selectedTitleLbl : TabSelectorLabel? = nil
    
    public var didTapTabLabel : ((Int)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension VDTabView {
    override public func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        reload()
    }
    
    private func setupSubviews() {
        scrollView.frame = bounds
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        
        indicatorView.isHidden = true
        indicatorView.backgroundColor = UIColor(hex: "E63130")
        scrollView.addSubview(indicatorView)
        
        let line = UIView(frame: CGRect(x: 0, y: bounds.size.height - CGFloatFromPixel(pixel: 1), width: bounds.size.width, height: CGFloatFromPixel(pixel: 1)))
        line.backgroundColor = UIColor(hex: "EEEEEE")
        addSubview(line)
    }
    
    private func createTabs() {
        for titleLbl in titleLbls {
            titleLbl.removeFromSuperview()
        }
        titleLbls.removeAll()
        var itemWidth : CGFloat = 0
        if isScrollEnabled {
            itemWidth = scrollView.bounds.size.width / 5
        }
        else {
            itemWidth = scrollView.bounds.size.width / CGFloat(titles.count)
        }
        for i in 0..<titles.count {
            let titleLbl = TabSelectorLabel()
            let x : CGFloat = CGFloat(i) * itemWidth
            titleLbl.frame = CGRect(x: x, y: 0, width: itemWidth, height: scrollView.bounds.size.height)
            titleLbl.text = titles[i]
            titleLbl.textAlignment = .center
            titleLbl.textColor = UIColor(red: 102/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1)
            titleLbl.adjustsFontSizeToFitWidth = titleAdjustsFontSizeToFitWidth
            titleLbl.font = titleFont
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(titleLblDidTap(tap:)))
            titleLbl.addGestureRecognizer(tapGes)
            titleLbl.isUserInteractionEnabled = true
            scrollView.addSubview(titleLbl)
            titleLbls.append(titleLbl)
            titleLbl.tag = i
            scrollView.contentSize = CGSize(width: titleLbl.frame.maxX, height: 0)
            
            if i == 0 {
                selectedIndex = 0
                titleLbl.selected = true
                selectedTitleLbl = titleLbl
                indicatorView.isHidden = false
                indicatorView.frame = CGRect(x: (titleLbl.bounds.size.width - indicatorView.bounds.size.width) / 2, y: titleLbl.bounds.size.height - indicatorView.bounds.size.height, width: 20, height: 2)
            }
        }
    }
    
    func reload() {
        var itemWidth : CGFloat = 0
        if isScrollEnabled {
            itemWidth = scrollView.bounds.size.width / 5
        }
        else {
            itemWidth = scrollView.bounds.size.width / CGFloat(titles.count)
        }
        for i in 0..<titles.count {
            let titleLbl = titleLbls[i]
            let x : CGFloat = CGFloat(i) * itemWidth
            titleLbl.frame = CGRect(x: x, y: 0, width: itemWidth, height: scrollView.bounds.size.height)
            titleLbl.text = titles[i]
            titleLbl.font = titleFont
            scrollView.contentSize = CGSize(width: titleLbl.frame.maxX, height: 0)
            
            if i == 0 {
                titleLbl.selected = true
                selectedTitleLbl = titleLbl
                indicatorView.isHidden = false
                indicatorView.frame = CGRect(x: (titleLbl.bounds.size.width - indicatorView.bounds.size.width) / 2, y: titleLbl.bounds.size.height - indicatorView.bounds.size.height, width: 20, height: 2)
            }
        }
    }
}

extension VDTabView {
    @objc func titleLblDidTap(tap: UITapGestureRecognizer) {
        guard let callBack = didTapTabLabel else {
            return
        }
        guard let view = tap.view else {
            return
        }
        selectAtIndex(index: view.tag)
        callBack(view.tag)
    }
    
    public func selectAtIndex(index: Int) {
        var selectIndex = index
        if index < 0 {
            selectIndex = 0
        }
        if index > titles.count - 1 {
            selectIndex = titles.count - 1
        }
        
        selectedIndex = selectIndex
        
        let titleLbl = titleLbls[selectIndex]
        guard let currentLbl = selectedTitleLbl else {
            return
        }
        currentLbl.selected = false
        titleLbl.selected = true
        selectedTitleLbl = titleLbl
        UIView.animate(withDuration: 0.3) {
            self.indicatorView.frame = CGRect(x: titleLbl.frame.origin.x + (titleLbl.bounds.size.width - self.indicatorView.bounds.size.width) / 2, y: titleLbl.bounds.size.height - self.indicatorView.bounds.size.height, width: 20, height: 2)
        }
        //滚动
        var lblMoveX : CGFloat = titleLbl.center.x - bounds.size.width * 0.5
        let lblMoveMax : CGFloat = scrollView.contentSize.width - bounds.size.width
        let lblMoveMin : CGFloat = 0
        
        if (lblMoveX > lblMoveMax) {
            lblMoveX = lblMoveMax;
        }
        if (lblMoveX < 0) {
            lblMoveX = lblMoveMin;
        }
        scrollView.setContentOffset(CGPoint(x: lblMoveX, y: 0), animated: true)
    }
}

class TabSelectorLabel: UILabel {
    var textInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInset))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += textInset.top + textInset.bottom
        intrinsicSuperViewContentSize.width += textInset.left + textInset.right
        return intrinsicSuperViewContentSize
    }
    
    var selected: Bool = false {
        didSet {
            if selected {
                textColor = UIColor(hex: "E63130")
            }
            else {
                textColor = UIColor(red: 102/255.0, green: 96/255.0, blue: 96/255.0, alpha: 1)
            }
        }
    }
}
