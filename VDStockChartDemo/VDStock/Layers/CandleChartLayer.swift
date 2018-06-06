//
//  CandleChartLayer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class CandleChartLayer: BaseChartLayer {
    let increaseLayer = CAShapeLayer()
    let decreaseLayer = CAShapeLayer()
    var textLayers: [CATextLayer] = []
    
    override init() {
        super.init()
        addSublayer(increaseLayer)
        addSublayer(decreaseLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        increaseLayer.frame = bounds
        decreaseLayer.frame = bounds
    }
    
    func draw(_ dataSet: CandleChartDataSet) {
        clearText()
        let increasePath = UIBezierPath()
        increaseLayer.fillColor = dataSet.increaseColor.cgColor
        increaseLayer.strokeColor = UIColor.clear.cgColor
        
        let decreasePath = UIBezierPath()
        decreaseLayer.fillColor = dataSet.decreaseColor.cgColor
        decreaseLayer.strokeColor = UIColor.clear.cgColor
        
        for point in dataSet.points {
            add(point, dataSet: dataSet, to: point.isIncrease ? increasePath : decreasePath)
            if point.remarks != nil {
                let textLayer = CATextLayer()
                textLayer.fontSize = dataSet.remarksFontSize
                textLayer.foregroundColor = dataSet.remarksColor.cgColor
                textLayer.contentsScale = UIScreen.main.scale
                
                var x = point.x + dataSet.barWidth
                if x + dataSet.remarksSize.width > bounds.width {
                    x = point.x - dataSet.remarksSize.width
                    textLayer.string = "\(point.remarks!)→"
                    textLayer.alignmentMode = kCAAlignmentRight
                } else {
                    textLayer.string = "←\(point.remarks!)"
                    textLayer.alignmentMode = kCAAlignmentLeft
                }
                textLayer.frame = CGRect(x: x, y: point.remarksLocation == .top ? point.lineTop - dataSet.remarksSize.height : point.lineBottom, width: dataSet.remarksSize.width, height: dataSet.remarksSize.height)
                
                addSublayer(textLayer)
                textLayers.append(textLayer)
            }
        }
        
        increaseLayer.path = increasePath.cgPath
        decreaseLayer.path = decreasePath.cgPath
    }
    
    private func add(_ point: CandleChartPoint, dataSet: CandleChartDataSet , to path: UIBezierPath) {
        path.move(to: CGPoint(x: point.x, y: point.barTop))
        path.addLine(to: CGPoint(x: point.x + dataSet.barWidth, y: point.barTop))
        path.addLine(to: CGPoint(x: point.x + dataSet.barWidth, y: point.barBottom))
        path.addLine(to: CGPoint(x: point.x, y: point.barBottom))
        path.close()
        
        let lineX = point.x + dataSet.barWidth * 0.5 - dataSet.lineWidth * 0.5
        path.move(to: CGPoint(x: lineX, y: point.lineTop))
        path.addLine(to: CGPoint(x: lineX + dataSet.lineWidth, y: point.lineTop))
        path.addLine(to: CGPoint(x: lineX + dataSet.lineWidth, y: point.lineBottom))
        path.addLine(to: CGPoint(x: lineX, y: point.lineBottom))
        path.close()
    }
    
    private func clearText() {
        textLayers.forEach { $0.removeFromSuperlayer() }
        textLayers = []
    }
}
