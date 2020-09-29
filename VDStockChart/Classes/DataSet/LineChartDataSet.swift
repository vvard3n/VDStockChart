//
//  LineChartDataSet.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class LineChartDataSet {
    /// 连接点坐标
    var points = [CGPoint]()
    /// 线宽
    var lineWidth: CGFloat = 1
    /// 线条颜色
    var lineColor = UIColor.red
    /// 填充色
    var fillColor: UIColor?
    /// 填充色集合（渐变色）
    var fillColors: [CGColor]?
    /// 渐变色填充位置
    var fillLocations: [NSNumber] = [0.3, 1]
}
