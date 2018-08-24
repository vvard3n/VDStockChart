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
    var borderColor: UIColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
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
    private var turnoverTitleLbl = CATextLayer()
    private var turnoverLbl = UILabel()
    private var topInfoLabel = UILabel()
    private var topPriceLabel = UILabel()
    private var bottomPriceLabel = UILabel()
    private var topPriceRoteLabel = UILabel()
    private var bottomPriceRoteLabel = UILabel()
    private var centerPriceLabel = UILabel()
    private var centerPriceRoteLabel = UILabel()
    private var xAxisLayer = AxisLayer()
    private var xAxisTextBackLayer = CALayer()
    private var xAxisCenterTextBackLayer = CALayer()
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
//        borderLayer.fillColor = UIColor.yellow.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        
        rightViewBorderLayer.fillColor = UIColor.clear.cgColor
        rightViewBorderLayer.strokeColor = borderColor.cgColor
        
        turnoverTitleLbl.contentsScale = UIScreen.main.scale
        turnoverTitleLbl.alignmentMode = kCAAlignmentCenter
        turnoverTitleLbl.fontSize = 10
        turnoverTitleLbl.string = "成交量"
        turnoverTitleLbl.foregroundColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        turnoverTitleLbl.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9921568627, blue: 1, alpha: 1)
        turnoverTitleLbl.borderColor = ThemeColor.LIGHT_LINE_COLOR_EEEEEE.cgColor
        turnoverTitleLbl.borderWidth = CGFloatFromPixel(pixel: 1)
        turnoverTitleLbl.cornerRadius = 2
        turnoverTitleLbl.masksToBounds = true
        
        turnoverLbl.font = UIFont.systemFont(ofSize: 10)
        turnoverLbl.text = ""
        turnoverLbl.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        topInfoLabel.font = UIFont.systemFont(ofSize: 10)
        topInfoLabel.textColor = #colorLiteral(red: 0.05490196078, green: 0.6823529412, blue: 0.3058823529, alpha: 1)
        
        topPriceLabel.font = UIFont.systemFont(ofSize: 10)
        topPriceLabel.textColor = #colorLiteral(red: 0.8980392157, green: 0.3607843137, blue: 0.3607843137, alpha: 1)
        
        centerPriceLabel.font = UIFont.systemFont(ofSize: 10)
        centerPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        bottomPriceLabel.font = UIFont.systemFont(ofSize: 10)
        bottomPriceLabel.textColor = #colorLiteral(red: 0.05490196078, green: 0.6823529412, blue: 0.3058823529, alpha: 1)
        
        topPriceRoteLabel.font = UIFont.systemFont(ofSize: 10)
        topPriceRoteLabel.textColor = #colorLiteral(red: 0.8980392157, green: 0.3607843137, blue: 0.3607843137, alpha: 1)
        topPriceRoteLabel.textAlignment = .right
        
        centerPriceRoteLabel.font = UIFont.systemFont(ofSize: 10)
        centerPriceRoteLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        centerPriceRoteLabel.textAlignment = .right
        
        bottomPriceRoteLabel.font = UIFont.systemFont(ofSize: 10)
        bottomPriceRoteLabel.textColor = #colorLiteral(red: 0.05490196078, green: 0.6823529412, blue: 0.3058823529, alpha: 1)
        bottomPriceRoteLabel.textAlignment = .right
        
        targetLayer.fillColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        targetLayer.strokeColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
//        xAxisTextBackLayer.backgroundColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
        xAxisTextBackLayer.backgroundColor = UIColor.white.cgColor
        xAxisCenterTextBackLayer.backgroundColor = UIColor.white.cgColor
        
//        timeLineBusinessAmountDataSet.fillcolor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        
        increaseBusinessAmountDataSet.fillcolor = increaseBusinessAmountDataSet.increaseColor
        decreaseBusinessAmountDataSet.fillcolor = decreaseBusinessAmountDataSet.decreaseColor
        timeLineDataSet.lineColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 1)
        timeLineDataSet.fillColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 0.1)
        avgTimeLineDataSet.lineColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0.03921568627, alpha: 1)
    }
    
    var layers: [CALayer] {
        return [borderLayer, rightViewBorderLayer, xAxisTextBackLayer, timeLineChart, xAxisLayer, avgTimeLineChart, barLineChart, bottomLineChart, targetLayer, xAxisCenterTextBackLayer, turnoverTitleLbl]
    }
    
    var views: [UIView] {
        return [rightView, topInfoLabel, topPriceLabel, bottomPriceLabel, topPriceRoteLabel, bottomPriceRoteLabel, centerPriceLabel, centerPriceRoteLabel, turnoverLbl]
    }
    
    func layout() {
        borderLayer.frame = container.bounds.zoomOut(UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 120)).zoomOut(borderWidth)
//        borderLayer.backgroundColor = UIColor.yellow.cgColor
        targetLayer.frame = borderLayer.frame
//        mainChartFrame = CGRect(x: borderLayer.frame.minX, y: borderLayer.frame.minY + 5, width: borderLayer.bounds.width, height: borderLayer.bounds.height * 0.7 - 5)
        mainChartFrame = CGRect(x: borderLayer.frame.minX, y: borderLayer.frame.minY, width: borderLayer.bounds.width, height: borderLayer.bounds.height * 0.7)
        timeLineChart.frame = mainChartFrame.zoomOut(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
//        timeLineChart.backgroundColor = UIColor.red.cgColor
        
        rightViewBorderLayer.frame = CGRect(x: borderLayer.frame.maxX, y: borderLayer.frame.minY, width: container.bounds.width - borderLayer.frame.maxX - 5, height: borderLayer.bounds.height)
        rightView.frame = CGRect(x: borderLayer.frame.maxX, y: borderLayer.frame.minY, width: container.bounds.width - borderLayer.frame.maxX - 5, height: borderLayer.bounds.height)
        
        turnoverTitleLbl.frame = CGRect(x: borderLayer.frame.minX, y: mainChartFrame.maxY + 3, width: 33, height: 14)
        turnoverLbl.frame = CGRect(x: turnoverTitleLbl.frame.maxX + 2, y: turnoverTitleLbl.frame.minY, width: 200, height: 14)
        
        topInfoLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: 3, width: mainChartFrame.width - 2, height: 14)
        
        topPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: timeLineChart.frame.minY, width: 100, height: 14)
        centerPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: timeLineChart.frame.minY + timeLineChart.bounds.height * 0.5 - 14, width: 100, height: 14)
        bottomPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: timeLineChart.frame.maxY - 14, width: 100, height: 14)
        topPriceRoteLabel.frame = CGRect(x: borderLayer.frame.maxX - 100, y: timeLineChart.frame.minY, width: 100, height: 14)
        centerPriceRoteLabel.frame = CGRect(x: borderLayer.frame.maxX - 100, y: timeLineChart.frame.minY + timeLineChart.bounds.height * 0.5 - 14, width: 100, height: 14)
        bottomPriceRoteLabel.frame = CGRect(x: borderLayer.frame.maxX - 100, y: timeLineChart.frame.maxY - 14, width: 100, height: 14)
//        xAxisLayer.frame = mainChartFrame.zoomIn(UIEdgeInsets(top: 5, left: 0, bottom: 5 + 14, right: 0))
        
//        xAxisLayer.frame = mainChartFrame.zoomIn(UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0))
        xAxisLayer.frame = targetLayer.frame.zoomOut(UIEdgeInsets(top: 0, left: 0, bottom: -14, right: 0))
        xAxisTextBackLayer.frame = CGRect(x: xAxisLayer.frame.minX, y: xAxisLayer.frame.maxY - 14, width: xAxisLayer.bounds.width, height: 14)
        xAxisCenterTextBackLayer.frame = CGRect(x: 0, y: timeLineChart.frame.maxY, width: mainChartFrame.width + 5, height: 14 + 3 * 2)
        barLineChart.frame = CGRect(x: borderLayer.frame.minX, y: mainChartFrame.maxY + 14 + 3 * 2, width: mainChartFrame.width, height: borderLayer.bounds.height - timeLineChart.bounds.height - 14 - 3 * 2)
//        barLineChart.backgroundColor = UIColor.red.cgColor
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
        
        topInfoLabel.text = String(format: "最新: %.2f %.2f", nodes.last!.price, nodes.last!.price - ((nodes.last!.beforeNode != nil) ? nodes.last!.beforeNode!.price : nodes.last!.closePrice))
        
        topPriceLabel.text = String(topPrice)
        centerPriceLabel.text = String(format: "%.2f", (topPrice + bottomPrice) * 0.5)
        bottomPriceLabel.text = String(bottomPrice)
        topPriceRoteLabel.text = String(format: "%.2f%%", (topPrice - yesterdayClosePrice) / yesterdayClosePrice * 100)
        centerPriceRoteLabel.text = "0.00%"
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
        turnoverLbl.text = ""
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
        
//        let dateBackgroundLayer = CALayer()
//        dateBackgroundLayer.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 0.2)
//        dateBackgroundLayer.frame = CGRect(x: 0, y: xAxisLayer.frame.maxY - 14 - borderLayer.frame.minY, width: xAxisLayer.bounds.width, height: 14)
//        targetLayer.addSublayer(dateBackgroundLayer)
        
        let dateText = selectedNode.time
        let dateTextLayer = CATextLayer()
        dateTextLayer.contentsScale = UIScreen.main.scale
        dateTextLayer.alignmentMode = kCAAlignmentCenter
        dateTextLayer.fontSize = 10
        let dateStr = "\(dateText[..<dateText.index(dateText.startIndex, offsetBy: 2)]):\(dateText[dateText.index(dateText.startIndex, offsetBy: 2)...])"
        dateTextLayer.string = dateStr
        dateTextLayer.foregroundColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 1)
        dateTextLayer.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9921568627, blue: 1, alpha: 1)
        dateTextLayer.borderColor = ThemeColor.LIGHT_LINE_COLOR_EEEEEE.cgColor
        dateTextLayer.borderWidth = CGFloatFromPixel(pixel: 1)
        dateTextLayer.cornerRadius = 2
        dateTextLayer.masksToBounds = true
        let textWidth = NSString(string: dateStr).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 10)], context: nil).size.width
        var dateX = x - textWidth * 0.5
        if dateX + textWidth > mainChartFrame.width {
            dateX = borderLayer.bounds.width - textWidth
        }
        if dateX < 0 {
            dateX = 0
        }
        
//        dateTextLayer.frame = CGRect(x: dateX, y: 0, width: textWidth, height: 14)
        dateTextLayer.frame = CGRect(x: dateX, y: xAxisLayer.frame.maxY - 14 - borderLayer.frame.minY, width: 28, height: 14)
//        dateBackgroundLayer.addSublayer(dateTextLayer)
        targetLayer.addSublayer(dateTextLayer)
        
        if point.y < timeLineChart.bounds.height {
            let priceForPt = (maxPrice - minPrice) / Float(timeLineChart.bounds.height)
            let price = maxPrice - priceForPt * Float(point.y)
            let priceTextLayer = CATextLayer()
            priceTextLayer.contentsScale = UIScreen.main.scale
            priceTextLayer.alignmentMode = kCAAlignmentCenter
            priceTextLayer.fontSize = 10
            priceTextLayer.string = "\(price)"
            priceTextLayer.foregroundColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 1)
            priceTextLayer.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9921568627, blue: 1, alpha: 1)
            priceTextLayer.borderColor = ThemeColor.LIGHT_LINE_COLOR_EEEEEE.cgColor
            priceTextLayer.borderWidth = CGFloatFromPixel(pixel: 1)
            priceTextLayer.cornerRadius = 2
            priceTextLayer.masksToBounds = true
            var y = point.y - 7.5
            if y < 0 { y = 0 }
            if y + 15 > timeLineChart.bounds.height { y = timeLineChart.bounds.height - 15 }
            priceTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - 50 : 0, y: y, width: 50, height: 15)
            targetLayer.addSublayer(priceTextLayer)
        }
        if point.y > timeLineChart.bounds.height + 14 + 3 * 2 {
            let businessAmountForPt = maxBusinessAmount / Float(barLineChart.bounds.height)
//            print(point.y - xAxisLayer.bounds.height)
            let businessAmount = maxBusinessAmount - businessAmountForPt * Float(point.y - xAxisLayer.bounds.height)
            let businessAmountTextLayer = CATextLayer()
            businessAmountTextLayer.contentsScale = UIScreen.main.scale
            businessAmountTextLayer.alignmentMode = kCAAlignmentCenter
            businessAmountTextLayer.fontSize = 10
            var businessAmountText = ""
            if maxBusinessAmount >= 10000 && maxBusinessAmount < 100000000  {
                businessAmountText = String(format: "%.2f万", businessAmount / 10000)
            }
            if maxBusinessAmount >= 100000000 && maxBusinessAmount < 1000000000000 {
                businessAmountText = String(format: "%.2f亿", businessAmount / 100000000)
            }
            if maxBusinessAmount >= 1000000000000 {
                businessAmountText = String(format: "%.2f万亿", businessAmount / 1000000000000)
            }
            businessAmountTextLayer.string = businessAmountText
            businessAmountTextLayer.foregroundColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 1)
            businessAmountTextLayer.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9921568627, blue: 1, alpha: 1)
            businessAmountTextLayer.borderColor = ThemeColor.LIGHT_LINE_COLOR_EEEEEE.cgColor
            businessAmountTextLayer.borderWidth = CGFloatFromPixel(pixel: 1)
            businessAmountTextLayer.cornerRadius = 2
            businessAmountTextLayer.masksToBounds = true
            var y = point.y - 7.5
            if y < timeLineChart.bounds.height + 14 + 3 * 2 { y = timeLineChart.bounds.height + 14 + 3 * 2 }
            if y + 15 > targetLayer.bounds.height { y = targetLayer.bounds.height - 15 }
            businessAmountTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - 50 : 0, y: y, width: 50, height: 15)
            targetLayer.addSublayer(businessAmountTextLayer)
        }
        
        if selectedNode.businessAmount >= 10000 && selectedNode.businessAmount < 100000000  {
            turnoverLbl.text = String(format: "%.2f万", selectedNode.businessAmount / 10000)
        }
        if selectedNode.businessAmount >= 100000000 && selectedNode.businessAmount < 1000000000000 {
            turnoverLbl.text = String(format: "%.2f亿", selectedNode.businessAmount / 100000000)
        }
        if selectedNode.businessAmount >= 1000000000000 {
            turnoverLbl.text = String(format: "%.2f万亿", selectedNode.businessAmount / 1000000000000)
        }
        
        let change = selectedNode.price - (selectedNode.beforeNode != nil ? selectedNode.beforeNode!.price : selectedNode.closePrice)
        var changeStr = String()
        if change > 0 {
            changeStr = String(format: "+%.2f", change)
            
            topInfoLabel.textColor = ThemeColor.STOCK_UP_RED_COLOR_E55C5C
        }
        else if change == 0 {
            changeStr = String(format: "%.2f", change)
            topInfoLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        }
        else {
            changeStr = String(format: "%.2f", change)
            topInfoLabel.textColor = ThemeColor.STOCK_DOWN_GREEN_COLOR_0EAE4E
        }
        let changeRate = change / (selectedNode.beforeNode != nil ? selectedNode.beforeNode!.price : selectedNode.closePrice) * 100
        topInfoLabel.text = String(format: "数值:%.2f %@ %.2f%%", selectedNode.price, changeStr, changeRate)
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
        
        path.move(to: CGPoint(x: 0, y: timeLineChart.bounds.height * 0.25))
        path.addLine(to: CGPoint(x: timeLineChart.bounds.width, y: timeLineChart.bounds.height * 0.25))
        
        path.move(to: CGPoint(x: 0, y: timeLineChart.bounds.height * 0.5))
        path.addLine(to: CGPoint(x: timeLineChart.bounds.width, y: timeLineChart.bounds.height * 0.5))
        
        path.move(to: CGPoint(x: 0, y: timeLineChart.bounds.height * 0.75))
        path.addLine(to: CGPoint(x: timeLineChart.bounds.width, y: timeLineChart.bounds.height * 0.75))
        
        path.move(to: CGPoint(x: 0, y: timeLineChart.bounds.height))
        path.addLine(to: CGPoint(x: timeLineChart.bounds.width, y: timeLineChart.bounds.height))
        
        path.move(to: CGPoint(x: 0, y: borderLayer.bounds.height - barLineChart.bounds.height))
        path.addLine(to: CGPoint(x: barLineChart.bounds.width, y: borderLayer.bounds.height - barLineChart.bounds.height))
        
        path.move(to: CGPoint(x: 0, y: borderLayer.bounds.height - barLineChart.bounds.height + 0.5 * barLineChart.bounds.height))
        path.addLine(to: CGPoint(x: barLineChart.bounds.width, y: borderLayer.bounds.height - barLineChart.bounds.height + 0.5 * barLineChart.bounds.height))
        
        borderLayer.path = path.cgPath
        
        let pathRight = UIBezierPath(rect: rightViewBorderLayer.bounds.zoomIn(borderWidth * 0.5))
        pathRight.move(to: CGPoint(x: 0, y: rightViewBorderLayer.bounds.height * 0.5))
        pathRight.addLine(to: CGPoint(x: rightViewBorderLayer.bounds.width, y: rightViewBorderLayer.bounds.height * 0.5))
        rightViewBorderLayer.path = pathRight.cgPath
    }
}
