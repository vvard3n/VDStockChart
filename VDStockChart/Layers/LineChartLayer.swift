//
//  LineChartLayer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class LineChartLayer: BaseChartLayer {
    func draw(_ dataSets: [LineChartDataSet]) {
        clear()
        for dataSet in dataSets {
            draw(dataSet: dataSet)
        }
    }
    
    private func draw(dataSet: LineChartDataSet) {
        if dataSet.points.isEmpty { return }
        
        /// 创建线条图层
        let lineLayer = CAShapeLayer()
        lineLayer.frame = bounds
        lineLayer.lineWidth = dataSet.lineWidth
        lineLayer.strokeColor = dataSet.lineColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineJoin = CAShapeLayerLineJoin.round
        
        let path = UIBezierPath()
        path.move(to: dataSet.points[0])
        for point in dataSet.points { path.addLine(to: point) }
        lineLayer.path = path.cgPath
        
        // 设置填充颜色
        if dataSet.fillColor != nil || dataSet.fillColors != nil {
            path.addLine(to: CGPoint(x: dataSet.points.last!.x, y: bounds.maxY))
            path.addLine(to: CGPoint(x: dataSet.points[0].x, y: bounds.maxY))
            let fillLayer = CAShapeLayer()
            fillLayer.frame = bounds
            fillLayer.strokeColor = UIColor.clear.cgColor
            fillLayer.fillColor = dataSet.fillColor?.cgColor ?? UIColor.black.cgColor
            fillLayer.path = path.cgPath
            addSublayer(fillLayer)
            
            if dataSet.fillColors != nil {
                let gradientFilllayer = CAGradientLayer()
                gradientFilllayer.frame = bounds
                gradientFilllayer.colors = dataSet.fillColors
                gradientFilllayer.locations = dataSet.fillLocations
                gradientFilllayer.mask = fillLayer
                
                addSublayer(gradientFilllayer)
            }
        }
        
        addSublayer(lineLayer)
    }
}
