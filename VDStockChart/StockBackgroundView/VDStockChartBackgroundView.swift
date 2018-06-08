//
//  VDStockChartBackgroundView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit
import CoreGraphics

enum VDStockType {
    case timeLine
    case KLine
}

class VDStockChartBackgroundView: UIScrollView {
    
    public var stockType : VDStockType = .timeLine
//    /// 是否允许滚动
//    var isAllowScroll: Bool = true {
//        didSet {
//            if isAllowScroll { addSubview(scrollView) }
//            else { scrollView.removeFromSuperview() }
//        }
//    }
//    /// 是否允许缩放
//    var isAllowScale: Bool = true
//    /// 处理图表滚动
//    private lazy var scrollView = UIScrollView()
    func drawBackgroundLines() {
        
    }

}
