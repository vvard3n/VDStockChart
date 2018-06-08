//
//  AxisLayer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class AxisLayer: BaseChartLayer {
    func draw(_ dataSet: AxisDataSet) {
        clear()
        if dataSet.points.isEmpty { return }
        
        
        let linePath = dataSet.lineWidth > 0 ? UIBezierPath() : nil
        
        for point in dataSet.points {
            linePath?.move(to: CGPoint(x: point.centerX, y: 0))
            linePath?.addLine(to: CGPoint(x: point.centerX, y: bounds.maxY - dataSet.textSize.height))
            
            let textLayer = CATextLayer()
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.alignmentMode = kCAAlignmentCenter
            textLayer.fontSize = dataSet.fontSize
            textLayer.string = point.text
            textLayer.foregroundColor = dataSet.textColor.cgColor
            
            var frame = CGRect(x: point.centerX - dataSet.textSize.width * 0.5, y: bounds.maxY - dataSet.textSize.height + dataSet.textGap, width: dataSet.textSize.width, height: dataSet.textSize.height)
            if frame.maxX > bounds.maxX {
                frame.origin.x = point.centerX - dataSet.textSize.width
                textLayer.alignmentMode = kCAAlignmentRight
            } else if frame.minX < bounds.minX {
                frame.origin.x = point.centerX
                textLayer.alignmentMode = kCAAlignmentLeft
            }
            textLayer.frame = frame
            addSublayer(textLayer)
        }
        
        let lineLayer = dataSet.lineWidth > 0 ? CAShapeLayer() : nil
        lineLayer?.fillColor = UIColor.clear.cgColor
        lineLayer?.strokeColor = dataSet.lineColor.cgColor
        lineLayer?.lineWidth = dataSet.lineWidth
        if lineLayer != nil { addSublayer(lineLayer!) }
        lineLayer?.path = linePath?.cgPath
    }
}
