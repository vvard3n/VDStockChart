//
//  AxisDataSet.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class AxisDataSet {
    /// 网格线宽度
    var lineWidth: CGFloat = CGFloatFromPixel(pixel: 1)
    /// 网格线颜色
    var lineColor: UIColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
    /// 文本与网格线间距
    var textGap: CGFloat = 1
    /// 文本大小
    var textSize = CGSize (width: 100, height: 14)
    /// 文本字体大小
    var fontSize: CGFloat = 10
    /// 文本颜色
    var textColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    
    var points: [AxisPoint] = []
}

struct AxisPoint {
    var centerX: CGFloat
    var text: String
}
