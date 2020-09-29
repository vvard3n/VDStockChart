//
//  VDStockChartView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class VDStockChartView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    /// 图表渲染器
    weak var renderer: VDChartRenderer? {
        didSet {
            oldValue?.layers.forEach { $0.removeFromSuperlayer() }
            oldValue?.views.forEach { $0.removeFromSuperview() }
            guard let renderer = renderer else { return }
            renderer.layers.forEach { layer.addSublayer($0) }
            renderer.views.forEach { addSubview($0) }
            renderer.reload()
            scrollView.contentSize = CGSize(width: renderer.contentWidth, height: 1)
            setNeedsLayout()
        }
    }
    /// 是否允许滚动
    var isAllowScroll: Bool = true {
        didSet {
            if isAllowScroll { addSubview(scrollView) }
            else { scrollView.removeFromSuperview() }
        }
    }
    /// 处理图表滚动
    private lazy var scrollView = UIScrollView()
    /// 滚动偏移量
    var offsetX: CGFloat {
        set { if isAllowScroll { scrollView.contentOffset.x = newValue } }
        get { return isAllowScroll ? scrollView.contentOffset.x : 0 }
    }
    /// 是否允许缩放
    var isAllowScale: Bool = true
    /// 当前缩放度
    var scale: CGFloat = 1
    /// 最大缩放度
    var maxScale: CGFloat = 3
    /// 最小缩放度
    var minScale: CGFloat = 0.5
    
    // MARK: Public method
    
    func reload() {
        guard let renderer = renderer else { return }
        renderer.reload()
        scrollView.contentSize = CGSize(width: renderer.contentWidth, height: 1)
        renderer.prepareRendering()
        renderer.rendering()
    }
    
    // MARK: - Gestures
    
    @objc private func pinchGestureAction(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.numberOfTouches == 2 else { return }
        guard let renderer = renderer else { return }
        let oldScale = scale
        scale = max(min(scale + gesture.scale - 1, maxScale), minScale)
        gesture.scale = 1
        if oldScale == scale { return }
        
        scrollView.contentSize = CGSize(width: renderer.contentWidth, height: 1)
        
        let point1 = gesture.location(ofTouch: 0, in: self)
        let point2 = gesture.location(ofTouch: 1, in: self)
        let centerX = offsetX + (point1.x + point2.x) / 2 - renderer.mainChartFrame.minX
        let leftCount = centerX / ((renderer.widthOfNode + renderer.gapOfNode) * oldScale)
        let newCenterX = leftCount * ((renderer.widthOfNode + renderer.gapOfNode) * scale)
        let newOffsetX = newCenterX - centerX
        offsetX = max(0, offsetX + newOffsetX)
        
        renderer.prepareRendering()
        renderer.rendering()
    }
    
    // MARK: - Override
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let renderer = renderer else { return }
        renderer.layout()
        if isAllowScroll {
            scrollView.frame = CGRect(x: renderer.mainChartFrame.minX, y: 0, width: renderer.mainChartFrame.width, height: bounds.height)
        }
        renderer.prepareRendering()
        renderer.rendering()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return isAllowScale
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            renderer?.prepareRendering()
            renderer?.rendering()
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        //
        //        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction(_:)))
        //        addGestureRecognizer(longPressGesture)
    }
    
}
