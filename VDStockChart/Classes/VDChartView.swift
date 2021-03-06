//
//  VDChartView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

public protocol VDChartViewDelegate: NSObjectProtocol {
    func chartViewDidTouchTarget(_ chartView: VDChartView, touchPoint: CGPoint, nodeIndex: Int)
    func chartViewDidCancelTouchTarget(_ chartView: VDChartView)
}

//extension VDChartViewDelegate {
//    public func chartViewDidTouchTarget(_ chartView: VDChartView, touchPoint: CGPoint, nodeIndex: Int) {}
//    public func chartViewDidCancelTouchTarget(_ chartView: VDChartView) {}
//}

public class VDChartView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, VDChartContainer {
    weak var delegate: VDChartViewDelegate? = nil
    var timer = Timer()
    
    /// 图表渲染器
    weak var renderer: VDChartRenderer? {
        didSet {
            //            var offset = scrollView.contentOffset
            //            offset.x -= 1.0
            //            offset.y -= 1.0
            //            scrollView.setContentOffset(offset, animated: false)
            //            offset.x += 1.0;
            //            offset.y += 1.0;
            //            scrollView.setContentOffset(offset, animated: false)
            
            oldValue?.layers.forEach { $0.removeFromSuperlayer() }
            oldValue?.views.forEach { $0.removeFromSuperview() }
            guard let renderer = renderer else { return }
            if renderer is VDTimeChartLineRenderer {
                isAllowScale = false
                isAllowScroll = false
            }
            else {
                isAllowScale = true
                isAllowScroll = true
            }
            renderer.layers.forEach { layer.addSublayer($0) }
            renderer.views.forEach { addSubview($0) }
            
            //            scrollView.contentOffset = CGPoint(x: renderer.contentWidth - renderer.container.bounds.width, y: 0)
            
            scrollView.contentSize = CGSize(width: renderer.contentWidth, height: 1)
            scrollView.setContentOffset(CGPoint(x: renderer.contentWidth - renderer.container.bounds.width + 5 + 5, y: 0), animated: false)
            //            scrollView.contentOffset = CGPoint(x: renderer.contentWidth - renderer.container.bounds.width + 5 + 5, y: 0)
            scrollView.backgroundColor = UIColor(white: 1, alpha: 0.1)
            renderer.reload()
            scrollView.contentOffset = CGPoint(x: renderer.contentWidth - renderer.container.bounds.width + 5 + 5, y: 0)
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
    public var offsetX: CGFloat {
        set { if isAllowScroll { scrollView.contentOffset.x = newValue } }
        get { return isAllowScroll ? scrollView.contentOffset.x : 0 }
    }
    /// 是否允许缩放
    var isAllowScale: Bool = true
    /// 当前缩放度
    public var scale: CGFloat = 1
    /// 最大缩放度
    var maxScale: CGFloat = 3
    /// 最小缩放度
    var minScale: CGFloat = 0.5
    
    // MARK: Public method
    
    func reload() {
        guard let renderer = renderer else { return }
        renderer.reload()
        scrollView.contentSize = CGSize(width: renderer.contentWidth, height: 1)
        renderer.clearTouchTarget()
        renderer.prepareRendering()
        renderer.rendering()
    }
    
    // MARK: - Gestures
    
    @objc private func tapGestureAction(_ gesture: UITapGestureRecognizer) {
        cancelTouchTarget()
    }
    
    @objc private func pinchGestureAction(_ gesture: UIPinchGestureRecognizer) {
        delegate?.chartViewDidCancelTouchTarget(self)
        guard gesture.numberOfTouches == 2 else { return }
        guard let renderer = renderer else { return }
        renderer.clearTouchTarget()
        
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
    
    @objc private func longPressGestureAction(_ gesture: UILongPressGestureRecognizer) {
        guard let renderer = renderer else { return }
        
        //        if renderer.borderLayer.frame.contains(gesture.location(in: self)) {
        renderer.renderingTouchTarget(point: gesture.location(in: self))
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(cancelTouchTarget), object: nil)
        self.perform(#selector(cancelTouchTarget), with: nil, afterDelay: 5)
        delegate?.chartViewDidTouchTarget(self, touchPoint: gesture.location(in: self), nodeIndex: renderer.selectedNodeIndex)
        //        }
    }
    
    @objc private func cancelTouchTarget() {
        delegate?.chartViewDidCancelTouchTarget(self)
        guard let renderer = renderer else { return }
        renderer.clearTouchTarget()
        renderer.prepareRendering()
        renderer.rendering()
    }
    
    // MARK: - Override
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let renderer = renderer else { return }
        renderer.layout()
        if isAllowScroll {
            scrollView.frame = CGRect(x: renderer.mainChartFrame.minX, y: 0, width: renderer.mainChartFrame.width, height: bounds.height)
        }
        delegate?.chartViewDidCancelTouchTarget(self)
        renderer.clearTouchTarget()
        renderer.prepareRendering()
        renderer.rendering()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //        return isAllowScale
        if gestureRecognizer is UILongPressGestureRecognizer {
            guard let renderer = renderer else { return false }
            if renderer.borderLayer.frame.contains(gestureRecognizer.location(in: self)) {
                return true
            }
        }
        else {
            return true
        }
        return false
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            delegate?.chartViewDidCancelTouchTarget(self)
            renderer?.clearTouchTarget()
            renderer?.prepareRendering()
            renderer?.rendering()
        }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        //        scrollView.decelerationRate = 0.0
        scrollView.bounces = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        //
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction(_:)))
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }
}
