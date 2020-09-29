//
//  BarLineChartLayer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class BarLineChartLayer: BaseChartLayer {
    func draw(_ dataSets: [BarLineChartDataSet]) {
        clear()
        for dataSet in dataSets {
            draw(dataSet: dataSet)
        }
    }
    
    private func draw(dataSet: BarLineChartDataSet) {
        if dataSet.frames.isEmpty { return }
        
        let path = UIBezierPath()
        for frame in dataSet.frames {
            path.move(to: frame.origin)
            path.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
            path.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
            path.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
            path.addLine(to: frame.origin)
        }
        
        let barLineLayer = CAShapeLayer()
        barLineLayer.strokeColor = UIColor.clear.cgColor
        barLineLayer.fillColor = dataSet.fillcolor.cgColor
        
        barLineLayer.path = path.cgPath
        addSublayer(barLineLayer)
    }
}
