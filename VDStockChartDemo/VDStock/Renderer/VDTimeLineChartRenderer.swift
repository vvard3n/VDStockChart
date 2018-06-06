//
//  VDTimeLineChartRenderer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

protocol VDTimeLineChartRendererDataSource: class {
    func numberOfNodes(in renderer: VDTimeChartLineRenderer) -> Int
    func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, nodeAt index: Int) -> TimeLineNode
    func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, xAxisTextAt index: Int) -> String?
    func yesterdayClosePrice(in renderer: VDTimeChartLineRenderer) -> Float
}

class VDTimeChartLineRenderer: VDChartRenderer {
    var selectedNodeIndex: Int = 0
    
    func clearTouchTarget() {
        
    }
    
    func renderingTouchTarget(point: CGPoint) {
        
    }
    
    
    private(set) var container: VDChartContainer
    /// 数据源
    weak var dataSource: VDTimeLineChartRendererDataSource?
    /// Style
    var borderWidth: CGFloat = CGFloatFromPixel(pixel: 1)
    var borderColor: UIColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
    private let borderLayer = CAShapeLayer()
    private let rightViewBorderLayer = CAShapeLayer()
    /// ChartRenderer
    var numberOfNodes: Int = 0
    var yesterdayClosePrice: Float = 0
    var mainChartFrame: CGRect = .zero
    var widthOfNode: CGFloat = 1
    var gapOfNode: CGFloat = 1.5
    /// Charts
    private var timeLineChart = LineChartLayer()
    private var avgTimeLineChart = LineChartLayer()
    private var barLineChart = BarLineChartLayer()
    private var bottomLineChart = LineChartLayer()
    private var topPriceLabel = UILabel()
    private var bottomPriceLabel = UILabel()
    private var xAxisLayer = AxisLayer()
    private var xAxisTextBackLayer = CALayer()
    private var rightView = StockDealInfoView()
    /// DataSet
    private var timeLineDataSet = LineChartDataSet()
    private var avgTimeLineDataSet = LineChartDataSet()
    private var timeLineBusinessAmountDataSet = BarLineChartDataSet()
    private var xAxisDataSet = AxisDataSet()
    
    init(container: VDChartContainer, dataSource: VDTimeLineChartRendererDataSource) {
        self.container = container
        self.dataSource = dataSource
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        
        rightViewBorderLayer.fillColor = UIColor.clear.cgColor
        rightViewBorderLayer.strokeColor = borderColor.cgColor
        
        topPriceLabel.font = UIFont.systemFont(ofSize: 10)
        topPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        bottomPriceLabel.font = UIFont.systemFont(ofSize: 10)
        bottomPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        xAxisTextBackLayer.backgroundColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
        
        timeLineBusinessAmountDataSet.fillcolor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        timeLineDataSet.lineColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        avgTimeLineDataSet.lineColor = #colorLiteral(red: 0.9221601486, green: 0.5313889384, blue: 0.1086233929, alpha: 1)
    }
    
    var layers: [CALayer] {
        return [borderLayer, rightViewBorderLayer, xAxisTextBackLayer, xAxisLayer, timeLineChart, avgTimeLineChart, barLineChart, bottomLineChart]
    }
    
    var views: [UIView] {
        return [rightView, topPriceLabel, bottomPriceLabel]
    }
    
    func layout() {
        borderLayer.frame = container.bounds.zoomOut(UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 120)).zoomOut(borderWidth)
        mainChartFrame = CGRect(x: borderLayer.frame.minX, y: borderLayer.frame.minY + 5, width: borderLayer.bounds.width, height: borderLayer.bounds.height * 0.7 - 5)
        timeLineChart.frame = mainChartFrame.zoomOut(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        rightViewBorderLayer.frame = CGRect(x: borderLayer.frame.maxX + 5, y: borderLayer.frame.minY, width: container.bounds.width - borderLayer.frame.maxX - 5 * 2, height: borderLayer.bounds.height)
        rightView.frame = CGRect(x: borderLayer.frame.maxX + 5, y: borderLayer.frame.minY, width: container.bounds.width - borderLayer.frame.maxX - 5 * 2, height: borderLayer.bounds.height)
        topPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: timeLineChart.frame.minY, width: 100, height: 14)
        bottomPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: timeLineChart.frame.maxY - 14, width: 100, height: 14)
        xAxisLayer.frame = mainChartFrame.zoomIn(UIEdgeInsets(top: 0, left: 0, bottom: 5 + 14, right: 0))
        xAxisTextBackLayer.frame = CGRect(x: xAxisLayer.frame.minX, y: xAxisLayer.frame.maxY - 14, width: xAxisLayer.bounds.width, height: 14)
        barLineChart.frame = CGRect(x: borderLayer.frame.minX, y: xAxisLayer.frame.maxY + 3, width: mainChartFrame.width, height: borderLayer.bounds.height - xAxisLayer.frame.height - 3 - 5)
        bottomLineChart.frame = barLineChart.frame
    }
    
    func prepareRendering() {
        guard let dataSource = dataSource else { return }
        //清空计算的绘制位置
        timeLineDataSet.points = []
        avgTimeLineDataSet.points = []
        xAxisDataSet.points = []
        timeLineBusinessAmountDataSet.frames = []
        
        let nodes = (0..<numberOfNodes).map { dataSource.timeLineChartRenderer(self, nodeAt: $0) }
        let result = VDStockDataHandle.calculate(nodes)
        print(result, timeLineChart.bounds)
        let itemXLength = timeLineChart.bounds.width / (4 * 60)
        print(itemXLength)
//        if(ABS(当前分时线中最大值 - 昨日收盘价)) >= (ABS(昨日收盘价-当前分时线中最小值))
//        {
//            最上侧价格 = 当前分时线中最大值；
//            最下侧价格 = 昨日收盘价 - ABS(当前分时线中最大值 - 昨日收盘价);
//        }else
//        {
//            最上侧价格 = 昨日收盘价 + ABS(昨日收盘价-当前分时线中最小值);
//            最下侧价格 = 当前分时线中最小值；
//        }
        var topPrice: Float = 0
        var bottomPrice: Float = 0
        if abs(result.maxPrice - yesterdayClosePrice) >= abs(yesterdayClosePrice - result.minPrice) {
            topPrice = result.maxPrice
            bottomPrice = yesterdayClosePrice - abs(result.maxPrice - yesterdayClosePrice)
        }
        else {
            topPrice = yesterdayClosePrice + abs(yesterdayClosePrice - result.minPrice)
            bottomPrice = result.minPrice
        }
        
        topPriceLabel.text = String(topPrice)
        bottomPriceLabel.text = String(bottomPrice)
        
        let yLength = timeLineChart.bounds.height / CGFloat(topPrice - bottomPrice)
        let businessAmountYLength = barLineChart.bounds.height / CGFloat(result.maxBusinessAmount)
        
        for i in 0...4 {
            calculateXAxis(centerX: timeLineChart.bounds.width / 4 * CGFloat(i), index: i)
        }
        
        for i in 0..<nodes.count {
            let node = nodes[i]
            let lineX = CGFloat(i) * itemXLength
            calculateTimeLine(node.price, maxPrice: result.maxPrice, x: lineX, yLength: yLength) { timeLineDataSet.points.append($0) }
            calculateAvgTimeLine(node.avgPrice, maxPrice: result.maxPrice, x: lineX, yLength: yLength, completion: { avgTimeLineDataSet.points.append($0) })
            calculateBusinessAmount(result: result, node: node, x: lineX, yLength: businessAmountYLength, width: widthOfNode)
        }
    }
    
    func rendering() {
        renderingBorder()
        timeLineChart.draw([timeLineDataSet, avgTimeLineDataSet])
        xAxisLayer.draw(xAxisDataSet)
        barLineChart.draw([timeLineBusinessAmountDataSet])
//        bottomLineChart.draw([DEADataSet, DIFFDataSet, KLineDataSet, DLineDataSet, JLineDataSet, WRDataSet, RSI6DataSet, RSI12DataSet, RSI24DataSet])
    }
    
    func reload() {
        guard let dataSource = dataSource else { return }
        let oldContentWidth = contentWidth
        numberOfNodes = dataSource.numberOfNodes(in: self)
        yesterdayClosePrice = dataSource.yesterdayClosePrice(in: self)
        let newOffsetX = container.offsetX + contentWidth - oldContentWidth
        container.offsetX = max(newOffsetX, 0)
    }
    
    private func calculateTimeLine(_ price: Float, maxPrice: Float, x: CGFloat, yLength: CGFloat, completion: (CGPoint) -> Void) {
        if price == 0 { return }
        completion(CGPoint(x: x, y: CGFloat(maxPrice - price) * yLength))
    }
    
    private func calculateXAxis(centerX: CGFloat, index: Int) {
        let texts = ["9:30", "", "11:30/13:00", "", "15:00"]
        let point = AxisPoint(centerX: centerX, text: texts[index])
        xAxisDataSet.points.append(point)
    }
    
    private func calculateBusinessAmount(result: TimeLineCalculateResult, node: TimeLineNode, x: CGFloat, yLength: CGFloat, width: CGFloat) {
        let y = CGFloat(result.maxBusinessAmount - node.businessAmount) * yLength
        let frame = CGRect(x: x, y: y, width: width, height: barLineChart.bounds.height - y)
        timeLineBusinessAmountDataSet.frames.append(frame)
    }
    
    private func calculateAvgTimeLine(_ avgPrice: Float, maxPrice: Float, x: CGFloat, yLength: CGFloat, completion: (CGPoint) -> Void) {
        if avgPrice == 0 { return }
        completion(CGPoint(x: x, y: CGFloat(maxPrice - avgPrice) * yLength))
    }
    
    private func renderingBorder() {
        let path = UIBezierPath(rect: borderLayer.bounds.zoomIn(borderWidth * 0.5))
        
        path.move(to: CGPoint(x: 0, y: timeLineChart.frame.minX))
        path.addLine(to: CGPoint(x: timeLineChart.bounds.width, y: timeLineChart.frame.minX))
        
        path.move(to: CGPoint(x: 0, y: timeLineChart.frame.minX + timeLineChart.bounds.height * 0.5))
        path.addLine(to: CGPoint(x: timeLineChart.bounds.width, y: timeLineChart.frame.minX + timeLineChart.bounds.height * 0.5))
        
        path.move(to: CGPoint(x: 0, y: timeLineChart.frame.minX + timeLineChart.bounds.height))
        path.addLine(to: CGPoint(x: timeLineChart.bounds.width, y: timeLineChart.frame.minX + timeLineChart.bounds.height))
        borderLayer.path = path.cgPath
        
        
        let pathRight = UIBezierPath(rect: rightViewBorderLayer.bounds.zoomIn(borderWidth * 0.5))
        rightViewBorderLayer.path = pathRight.cgPath
    }
}
