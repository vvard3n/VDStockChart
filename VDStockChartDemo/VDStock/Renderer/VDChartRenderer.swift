//
//  VDChartRenderer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

protocol VDChartRenderer: class {
    var layers: [CALayer] { get }
    var views: [UIView] { get }
    var container: VDChartContainer { get }
    var mainChartFrame: CGRect { get }
    var numberOfNodes: Int { get }
    var widthOfNode: CGFloat { get }
    var gapOfNode: CGFloat { get }
    var contentWidth: CGFloat { get }
    var selectedNodeIndex: Int { get }
    
    /// 必要布局可在此方法中完成
    func layout()
    /// 准备渲染图表
    func prepareRendering()
    /// 渲染图表
    func rendering()
    /// 渲染触摸准心 十
    func renderingTouchTarget(point: CGPoint)
    /// 清除触摸准心
    func clearTouchTarget()
    /// 刷新图表
    func reload()
}

extension VDChartRenderer {
    var leftIndex: Int {
        return max(Int(floor(container.offsetX / ((widthOfNode + gapOfNode) * container.scale))), 0)
    }
    
    var rightIndex: Int {
        let index = Int((container.offsetX + mainChartFrame.width) / ((widthOfNode + gapOfNode) * container.scale))
        return max(min(index, numberOfNodes - 1), 0)
    }
    
    var contentWidth: CGFloat {
        return CGFloat(numberOfNodes) * ((widthOfNode + gapOfNode) * container.scale) - gapOfNode * container.scale
    }
    
    func reload() { }
}
