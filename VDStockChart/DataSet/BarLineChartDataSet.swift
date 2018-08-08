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
    var increaseColor: UIColor = #colorLiteral(red: 0.9647058824, green: 0.3725490196, blue: 0.3490196078, alpha: 1)
    /// 降价颜色
    var decreaseColor: UIColor = #colorLiteral(red: 0.2745098039, green: 0.8352941176, blue: 0.5960784314, alpha: 1)
    /// 柱状图位置、大小
    var frames: [CGRect] = []
    /// 填充色
    var fillcolor = UIColor.black
}
