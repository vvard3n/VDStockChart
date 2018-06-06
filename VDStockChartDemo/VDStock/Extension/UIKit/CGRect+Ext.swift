//
//  CGRect+Ext.swift
//  StockChartDemo
//
//  Created by Haijun on 2018/4/19.
//  Copyright © 2018年 Haijun. All rights reserved.
//

import UIKit

extension CGRect {
    func zoomOut(_ insets: UIEdgeInsets) -> CGRect {
        return CGRect(x: minX + insets.left, y: minY + insets.top, width: width - insets.left - insets.right, height: height - insets.top - insets.bottom)
    }
    
    func zoomOut(_ value: CGFloat) -> CGRect {
        return zoomOut(UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }
    
    func zoomIn(_ insets: UIEdgeInsets) -> CGRect {
        return CGRect(x: minX - insets.left, y: minY - insets.top, width: width + insets.left + insets.right, height: height + insets.top + insets.bottom)
    }
    
    func zoomIn(_ value: CGFloat) -> CGRect {
        return zoomIn(UIEdgeInsets(top: value, left: value, bottom: value, right: value))
    }
}
