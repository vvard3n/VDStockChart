//
//  VDTimeLineChartRenderer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

public protocol VDTimeLineChartRendererDataSource: class {
    func numberOfNodes(in renderer: VDTimeChartLineRenderer) -> Int
    func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, nodeAt index: Int) -> TimeLineNode
    func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, xAxisTextAt index: Int) -> String?
    func yesterdayClosePrice(in renderer: VDTimeChartLineRenderer) -> Float
}

public class VDTimeChartLineRenderer: VDChartRenderer {

    private(set) var container: VDChartContainer
    /// 数据源
    weak var dataSource: VDTimeLineChartRendererDataSource?
    /// Style
    var borderWidth: CGFloat = CGFloatFromPixel(pixel: 1)
    var borderColor: UIColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
    let borderLayer = CAShapeLayer()
    private let rightViewBorderLayer = CAShapeLayer()
    /// ChartRenderer
    var numberOfNodes: Int = 0
    var yesterdayClosePrice: Float = 0
    var mainChartFrame: CGRect = .zero
    var widthOfNode: CGFloat = 1
    var gapOfNode: CGFloat = 0
    /// Charts
    private var timeLineChart = LineChartLayer()
    private var avgTimeLineChart = LineChartLayer()
    private var barLineChart = BarLineChartLayer()
    private var bottomLineChart = LineChartLayer()
    private var topPriceLabel = UILabel()
    private var bottomPriceLabel = UILabel()
    private var topPriceRoteLabel = UILabel()
    private var bottomPriceRoteLabel = UILabel()
    private var xAxisLayer = AxisLayer()
    private var xAxisTextBackLayer = CALayer()
    private var rightView = StockDealInfoView()
    private let targetLayer = CAShapeLayer()
    /// DataSet
    private var timeLineDataSet = LineChartDataSet()
    private var avgTimeLineDataSet = LineChartDataSet()
//    private var timeLineBusinessAmountDataSet = BarLineChartDataSet()
    private var increaseBusinessAmountDataSet = BarLineChartDataSet()
    private var decreaseBusinessAmountDataSet = BarLineChartDataSet()
    private var xAxisDataSet = AxisDataSet()
    private var maxPrice: Float = 0
    private var minPrice: Float = 0
    private var maxBusinessAmount: Float = 0
    private var minBusinessAmount: Float = 0
    /// status
    private var isTouching: Bool = false
    private var touchingTargetPoint: CGPoint = CGPoint()
    internal var selectedNodeIndex: Int = -1
    
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
        
        topPriceRoteLabel.font = UIFont.systemFont(ofSize: 10)
        topPriceRoteLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        topPriceRoteLabel.textAlignment = .right
        
        bottomPriceRoteLabel.font = UIFont.systemFont(ofSize: 10)
        bottomPriceRoteLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        bottomPriceRoteLabel.textAlignment = .right
        
        targetLayer.fillColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        targetLayer.strokeColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        xAxisTextBackLayer.backgroundColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
        
//        timeLineBusinessAmountDataSet.fillcolor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        increaseBusinessAmountDataSet.fillcolor = increaseBusinessAmountDataSet.increaseColor
        decreaseBusinessAmountDataSet.fillcolor = decreaseBusinessAmountDataSet.decreaseColor
        timeLineDataSet.lineColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        avgTimeLineDataSet.lineColor = #colorLiteral(red: 0.9221601486, green: 0.5313889384, blue: 0.1086233929, alpha: 1)
    }
    
    var layers: [CALayer] {
        return [borderLayer, rightViewBorderLayer, xAxisTextBackLayer, xAxisLayer, timeLineChart, avgTimeLineChart, barLineChart, bottomLineChart, targetLayer]
    }
    
    var views: [UIView] {
        return [rightView, topPriceLabel, bottomPriceLabel, topPriceRoteLabel, bottomPriceRoteLabel]
    }
    
    func layout() {
        borderLayer.frame = container.bounds.zoomOut(UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 120)).zoomOut(borderWidth)
        targetLayer.frame = borderLayer.frame
        mainChartFrame = CGRect(x: borderLayer.frame.minX, y: borderLayer.frame.minY + 5, width: borderLayer.bounds.width, height: borderLayer.bounds.height * 0.7 - 5)
        timeLineChart.frame = mainChartFrame.zoomOut(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        rightViewBorderLayer.frame = CGRect(x: borderLayer.frame.maxX + 5, y: borderLayer.frame.minY, width: container.bounds.width - borderLayer.frame.maxX - 5 * 2, height: borderLayer.bounds.height)
        rightView.frame = CGRect(x: borderLayer.frame.maxX + 5, y: borderLayer.frame.minY, width: container.bounds.width - borderLayer.frame.maxX - 5 * 2, height: borderLayer.bounds.height)
        topPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: timeLineChart.frame.minY, width: 100, height: 14)
        bottomPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: timeLineChart.frame.maxY - 14, width: 100, height: 14)
        topPriceRoteLabel.frame = CGRect(x: borderLayer.frame.maxX - 100, y: timeLineChart.frame.minY, width: 100, height: 14)
        bottomPriceRoteLabel.frame = CGRect(x: borderLayer.frame.maxX - 100, y: timeLineChart.frame.maxY - 14, width: 100, height: 14)
        xAxisLayer.frame = mainChartFrame.zoomIn(UIEdgeInsets(top: 5, left: 0, bottom: 5 + 14, right: 0))
        xAxisTextBackLayer.frame = CGRect(x: xAxisLayer.frame.minX, y: xAxisLayer.frame.maxY - 14, width: xAxisLayer.bounds.width, height: 14)
        barLineChart.frame = CGRect(x: borderLayer.frame.minX, y: xAxisLayer.frame.maxY + 3, width: mainChartFrame.width, height: borderLayer.bounds.height - xAxisLayer.frame.height - 3)
        bottomLineChart.frame = barLineChart.frame
    }
    
    func prepareRendering() {
        guard let dataSource = dataSource else { return }
        //清空计算的绘制位置
        timeLineDataSet.points = []
        avgTimeLineDataSet.points = []
        xAxisDataSet.points = []
//        timeLineBusinessAmountDataSet.frames = []
        increaseBusinessAmountDataSet.frames = []
        decreaseBusinessAmountDataSet.frames = []
        
        let nodes = (0..<numberOfNodes).map { dataSource.timeLineChartRenderer(self, nodeAt: $0) }
        let result = VDStockDataHandle.calculate(nodes)
        maxBusinessAmount = result.maxBusinessAmount
        minBusinessAmount = result.minBusinessAmount
        
        let itemXLength = timeLineChart.bounds.width / (4 * 60)
//        print(itemXLength)
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
            
            maxPrice = result.maxPrice
            minPrice = yesterdayClosePrice - abs(result.maxPrice - yesterdayClosePrice)
        }
        else {
            topPrice = yesterdayClosePrice + abs(yesterdayClosePrice - result.minPrice)
            bottomPrice = result.minPrice
            
            maxPrice = yesterdayClosePrice + abs(yesterdayClosePrice - result.minPrice)
            minPrice = result.minPrice
        }
        
        topPriceLabel.text = String(topPrice)
        bottomPriceLabel.text = String(bottomPrice)
        topPriceRoteLabel.text = String(format: "%.2f%%", (topPrice - yesterdayClosePrice) / yesterdayClosePrice * 100)
        bottomPriceRoteLabel.text = String(format: "%.2f%%", (bottomPrice - yesterdayClosePrice) / yesterdayClosePrice * 100)
        
        
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
        barLineChart.draw([increaseBusinessAmountDataSet, decreaseBusinessAmountDataSet])
//        bottomLineChart.draw([DEADataSet, DIFFDataSet, KLineDataSet, DLineDataSet, JLineDataSet, WRDataSet, RSI6DataSet, RSI12DataSet, RSI24DataSet])
    }
    
    func reRendering() {
        prepareRendering()
        rendering()
    }
    
    
    func clearTouchTarget() {
        isTouching = false
        touchingTargetPoint = CGPoint()
        targetLayer.path = nil
        targetLayer.sublayers?.removeAll()
    }
    
    func renderingTouchTarget(point: CGPoint) {
        var point = CGPoint(x: point.x - borderLayer.frame.minX, y: point.y - borderLayer.frame.minY)
        //        print(point)
        isTouching = true
        touchingTargetPoint = point
        reRendering()
        
        if point.x < 0 {
            point.x = 0
        }
        if point.x > borderLayer.bounds.width {
            point.x = borderLayer.bounds.width
        }
        if point.y < 0 {
            point.y = 0
        }
        if point.y > borderLayer.bounds.height {
            point.y = borderLayer.bounds.height
        }
        let path = UIBezierPath()
        path.lineWidth = 1
        
        path.move(to: CGPoint(x: 0, y: point.y))
        path.addLine(to: CGPoint(x: borderLayer.bounds.width, y: point.y))
        
        var node : TimeLineNode? = nil
        var targetPointX: CGFloat = 0
        for i in 0..<numberOfNodes {
            let p = timeLineDataSet.points[i]
            guard i + 1 < timeLineDataSet.points.count else {
                targetPointX = p.x
                node = dataSource?.timeLineChartRenderer(self, nodeAt: i)
                selectedNodeIndex = i
                break
            }
            let pNext = timeLineDataSet.points[i + 1]
            if point.x >= p.x && point.x < pNext.x && pNext.x != 0 {
                targetPointX = p.x
                node = dataSource?.timeLineChartRenderer(self, nodeAt: i)
                selectedNodeIndex = i
                break
            }
        }
        
        guard selectedNodeIndex != -1 else { return }
        guard let selectedNode = node else { return }
        
        let x = targetPointX + widthOfNode * container.scale * 0.5
        if x < 0 || x > borderLayer.bounds.width { return }
        
        targetLayer.sublayers?.removeAll()
        
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: borderLayer.bounds.height))
        
        targetLayer.path = path.cgPath
        
        let dateBackgroundLayer = CALayer()
        dateBackgroundLayer.backgroundColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
        dateBackgroundLayer.frame = CGRect(x: 0, y: xAxisLayer.frame.maxY - 14 - borderLayer.frame.minY, width: xAxisLayer.bounds.width, height: 14)
        targetLayer.addSublayer(dateBackgroundLayer)
        
        let dateText = selectedNode.time
        let dateTextLayer = CATextLayer()
        dateTextLayer.contentsScale = UIScreen.main.scale
        dateTextLayer.alignmentMode = kCAAlignmentCenter
        dateTextLayer.fontSize = 10
        let dateStr = "\(dateText[..<dateText.index(dateText.startIndex, offsetBy: 2)]):\(dateText[dateText.index(dateText.startIndex, offsetBy: 2)...])"
        dateTextLayer.string = dateStr
        dateTextLayer.foregroundColor = UIColor.black.cgColor
        let textWidth = NSString(string: dateStr).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 10)], context: nil).size.width
        var dateX = x - textWidth * 0.5
        if dateX + textWidth > mainChartFrame.width {
            dateX = dateBackgroundLayer.bounds.width - textWidth
        }
        if dateX < 0 {
            dateX = 0
        }
        
        dateTextLayer.frame = CGRect(x: dateX, y: 0, width: textWidth, height: 14)
        dateBackgroundLayer.addSublayer(dateTextLayer)
        
        if point.y < 5 + timeLineChart.bounds.height + 5 {
            let priceForPt = (maxPrice - minPrice) / Float(timeLineChart.bounds.height)
            let price = maxPrice + priceForPt * 5 - priceForPt * Float(point.y)
            let priceTextLayer = CATextLayer()
            priceTextLayer.contentsScale = UIScreen.main.scale
            priceTextLayer.alignmentMode = kCAAlignmentCenter
            priceTextLayer.fontSize = 10
            priceTextLayer.string = "\(price)"
            priceTextLayer.foregroundColor = UIColor.black.cgColor
            priceTextLayer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            var y = point.y - 7.5
            if y < 0 { y = 0 }
            priceTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - 50 : 0, y: y, width: 50, height: 15)
            targetLayer.addSublayer(priceTextLayer)
        }
        if point.y > 5 + timeLineChart.bounds.height + 5 + 14 {
            let businessAmountForPt = maxBusinessAmount / Float(barLineChart.bounds.height)
//            print(point.y - xAxisLayer.bounds.height)
            let businessAmount = maxBusinessAmount + businessAmountForPt * 3 - businessAmountForPt * Float(point.y - xAxisLayer.bounds.height)
            let businessAmountTextLayer = CATextLayer()
            businessAmountTextLayer.contentsScale = UIScreen.main.scale
            businessAmountTextLayer.alignmentMode = kCAAlignmentCenter
            businessAmountTextLayer.fontSize = 10
            var businessAmountText = ""
            if maxBusinessAmount >= 10000 && maxBusinessAmount < 100000000  {
                businessAmountText = String(format: "%.2f", businessAmount / 10000)
            }
            if maxBusinessAmount >= 100000000 && maxBusinessAmount < 1000000000000 {
                businessAmountText = String(format: "%.2f", businessAmount / 100000000)
            }
            if maxBusinessAmount >= 1000000000000 {
                businessAmountText = String(format: "%.2f", businessAmount / 1000000000000)
            }
            businessAmountTextLayer.string = businessAmountText
            businessAmountTextLayer.foregroundColor = UIColor.black.cgColor
            businessAmountTextLayer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            var y = point.y - 7.5
            if y + 15 > targetLayer.bounds.height { y = targetLayer.bounds.height - 15 }
            businessAmountTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - 50 : 0, y: y, width: 50, height: 15)
            targetLayer.addSublayer(businessAmountTextLayer)
        }
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
//        let y = CGFloat(result.maxBusinessAmount - node.businessAmount) * yLength
//        let frame = CGRect(x: x, y: y, width: width, height: barLineChart.bounds.height - y)
//        timeLineBusinessAmountDataSet.frames.append(frame)
        
        let y = CGFloat(result.maxBusinessAmount - node.businessAmount) * yLength
        let frame = CGRect(x: x, y: CGFloat(y), width: width, height: barLineChart.bounds.height - CGFloat(y))
        if node.isIncrease {
            increaseBusinessAmountDataSet.frames.append(frame)
        } else {
            decreaseBusinessAmountDataSet.frames.append(frame)
        }
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
