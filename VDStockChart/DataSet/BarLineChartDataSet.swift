//
//  BarLineChartDataSet.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class BarLineChartDataSet: NSObject {
    /// 涨价颜色
    var increaseColor: UIColor = ThemeColor.MAIN_COLOR_E63130
    /// 降价颜色
    var decreaseColor: UIColor = ThemeColor.STOCK_DOWN_GREEN_COLOR_0EAE4E
    /// 柱状图位置、大小
    var frames: [CGRect] = []
    /// 填充色
    var fillcolor = UIColor.black
}
