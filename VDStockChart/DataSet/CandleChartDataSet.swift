//
//  CandleChartDataSet.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class CandleChartDataSet {
    /// 线宽
    var lineWidth: CGFloat = 1
    /// 柱体宽度
    var barWidth: CGFloat = 3
    /// 间距
    var gap: CGFloat = 3
    /// 蜡烛图坐标
    var points = [CandleChartPoint]()
    /// 涨价颜色
    var increaseColor: UIColor = #colorLiteral(red: 0.8980392157, green: 0.3607843137, blue: 0.3607843137, alpha: 1)
    /// 降价颜色
    var decreaseColor: UIColor = #colorLiteral(red: 0.05490196078, green: 0.6823529412, blue: 0.3058823529, alpha: 1)
    /// 备注颜色
    var remarksColor: UIColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    /// 备注字体大小
    var remarksFontSize: CGFloat = 10
    /// 备注宽度
    var remarksSize = CGSize(width: 100, height: 14)
    /// 是否显示备注
    var isShowRemarks: Bool = true
    
    @discardableResult func addPoint(with node: KlineNode, nodeIndex: Int, result: KlineCalculateResult, offsetX: CGFloat, yLength: CGFloat) -> CandleChartPoint {
        let remarksHeight = isShowRemarks ? remarksSize.height : 0
        let point = CandleChartPoint(x: CGFloat(nodeIndex) * (barWidth + gap) - offsetX,
                                     lineTop: CGFloat(result.maxPrice - node.high) * yLength + remarksHeight,
                                     lineBottom: CGFloat(result.maxPrice - node.low) * yLength + remarksHeight,
                                     barTop: CGFloat(result.maxPrice - max(node.open, node.close)) * yLength + remarksHeight,
                                     barBottom: CGFloat(result.maxPrice - min(node.open, node.close)) * yLength + remarksHeight,
                                     isIncrease: node.isIncrease)
        if point.lineTop == point.lineBottom && point.barTop == point.barBottom && point.lineTop == point.barTop {
            point.barBottom += 1
        }
        if isShowRemarks {
            if node.high == result.maxHigh {
                point.remarks = String(node.high)
                point.remarksLocation = .top
            } else if node.low == result.minLow {
                point.remarks = String(node.low)
                point.remarksLocation = .bottom
            }
        }
        points.append(point)
        return point
    }
}

class CandleChartPoint {
    var x: CGFloat
    var lineTop: CGFloat
    var lineBottom: CGFloat
    var barTop: CGFloat
    var barBottom: CGFloat
    /// 是否涨价
    var isIncrease: Bool
    /// 备注
    var remarks: String?
    enum RemarksLocation {
        case top
        case bottom
    }
    /// 备注位置
    var remarksLocation: RemarksLocation = .top
    
    init(x: CGFloat, lineTop: CGFloat, lineBottom: CGFloat, barTop: CGFloat, barBottom: CGFloat, isIncrease: Bool) {
        self.x = x
        self.lineTop = lineTop
        self.lineBottom = lineBottom
        self.barTop = barTop
        self.barBottom = barBottom
        self.isIncrease = isIncrease
    }
}
