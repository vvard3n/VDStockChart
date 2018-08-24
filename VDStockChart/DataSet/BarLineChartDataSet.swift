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
    var increaseColor: UIColor = #colorLiteral(red: 0.8980392157, green: 0.3607843137, blue: 0.3607843137, alpha: 1)
    /// 降价颜色
    var decreaseColor: UIColor = #colorLiteral(red: 0.05490196078, green: 0.6823529412, blue: 0.3058823529, alpha: 1)
    /// 柱状图位置、大小
    var frames: [CGRect] = []
    /// 填充色
    var fillcolor = UIColor.black
}
