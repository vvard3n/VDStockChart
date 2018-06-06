//
//  VDKLineChartRenderer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

enum VDKLineChartIndicatorType {
    case businessAmount
    case MACD
    case KDJ
    case WR
    case RSI
}

protocol VDKLineChartRendererDataSource: class {
    func numberOfNodes(in renderer: VDKLineChartRenderer) -> Int
    func klineChartRenderer(_ renderer: VDKLineChartRenderer, nodeAt index: Int) -> KlineNode
    func klineChartRenderer(_ renderer: VDKLineChartRenderer, xAxisTextAt index: Int) -> String?
}

class VDKLineChartRenderer: VDChartRenderer {
    

    private(set) var container: VDChartContainer
    /// 数据源
    weak var dataSource: VDKLineChartRendererDataSource?
    var indicatorType: VDKLineChartIndicatorType = .businessAmount
    /// Style
    var borderWidth: CGFloat = CGFloatFromPixel(pixel: 1)
    var borderColor: UIColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
    private let borderLayer = CAShapeLayer()
    /// ChartRenderer
    var numberOfNodes: Int = 0
    var mainChartFrame: CGRect = .zero
    var widthOfNode: CGFloat = 5.5
    var gapOfNode: CGFloat = 1.5
    /// Charts
    private let candlestickChart = CandleChartLayer()
    private var maLineChart = LineChartLayer()
    private var barLineChart = BarLineChartLayer()
    private var bottomLineChart = LineChartLayer()
    private var topPriceLabel = UILabel()
    private var bottomPriceLabel = UILabel()
    private var xAxisLayer = AxisLayer()
    private var xAxisTextBackLayer = CALayer()
    
    private let targetLayer = CAShapeLayer()
    /// DataSet
    private let candlestickDataSet = CandleChartDataSet()
    private var ma5LineDataSet = LineChartDataSet()
    private var ma10LineDataSet = LineChartDataSet()
    private var ma20LineDataSet = LineChartDataSet()
    private var xAxisDataSet = AxisDataSet()
    private var increaseBusinessAmountDataSet = BarLineChartDataSet()
    private var decreaseBusinessAmountDataSet = BarLineChartDataSet()
    private var increaseMACDDataSet = BarLineChartDataSet()
    private var decreaseMACDDataSet = BarLineChartDataSet()
    private var DEADataSet = LineChartDataSet()
    private var DIFFDataSet = LineChartDataSet()
    private var KLineDataSet = LineChartDataSet()
    private var DLineDataSet = LineChartDataSet()
    private var JLineDataSet = LineChartDataSet()
    private var WRDataSet = LineChartDataSet()
    private var RSI6DataSet = LineChartDataSet()
    private var RSI12DataSet = LineChartDataSet()
    private var RSI24DataSet = LineChartDataSet()
    private var maxPrice: Float = 0
    private var minPrice: Float = 0
    private var maxBusinessAmount: Float = 0
    private var minBusinessAmount: Float = 0
    /// status
    private var isTouching: Bool = false
    private var touchingTargetPoint: CGPoint = CGPoint()
    var selectedNodeIndex: Int = -1
    
    init(container: VDChartContainer, dataSource: VDKLineChartRendererDataSource) {
        self.container = container
        self.dataSource = dataSource
        
        candlestickDataSet.remarksColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        ma5LineDataSet.lineColor = #colorLiteral(red: 0.0431372549, green: 0.4705882353, blue: 0.8901960784, alpha: 1)
        ma10LineDataSet.lineColor = #colorLiteral(red: 0.9647058824, green: 0.3725490196, blue: 0.3490196078, alpha: 1)
        ma20LineDataSet.lineColor = #colorLiteral(red: 1, green: 0.7137254902, blue: 0.2823529412, alpha: 1)
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        
        targetLayer.fillColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        targetLayer.strokeColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        xAxisTextBackLayer.backgroundColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
        
        topPriceLabel.font = UIFont.systemFont(ofSize: 10)
        topPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        bottomPriceLabel.font = UIFont.systemFont(ofSize: 10)
        bottomPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        increaseBusinessAmountDataSet.fillcolor = candlestickDataSet.increaseColor
        decreaseBusinessAmountDataSet.fillcolor = candlestickDataSet.decreaseColor
        increaseMACDDataSet.fillcolor = candlestickDataSet.increaseColor
        decreaseMACDDataSet.fillcolor = candlestickDataSet.decreaseColor
        DEADataSet.lineColor = UIColor.red
        DIFFDataSet.lineColor = UIColor.green
        KLineDataSet.lineColor = UIColor.red
        DLineDataSet.lineColor = UIColor.green
        JLineDataSet.lineColor = UIColor.blue
        
        RSI6DataSet.lineColor = UIColor.red
        RSI12DataSet.lineColor = UIColor.green
        RSI24DataSet.lineColor = UIColor.blue
    }
    
    var layers: [CALayer] {
        return [borderLayer, xAxisTextBackLayer, xAxisLayer, candlestickChart, maLineChart, barLineChart, bottomLineChart, targetLayer]
    }
    
    var views: [UIView] {
        return [topPriceLabel, bottomPriceLabel]
    }
    
    func layout() {
        borderLayer.frame = container.bounds.zoomOut(UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5)).zoomOut(borderWidth)
        targetLayer.frame = borderLayer.frame
        mainChartFrame = CGRect(x: borderLayer.frame.minX, y: borderLayer.frame.minY + 14, width: borderLayer.bounds.width, height: borderLayer.bounds.height * 0.7 - 34)
        candlestickChart.frame = mainChartFrame
        maLineChart.frame = mainChartFrame.zoomOut(UIEdgeInsets(top: candlestickDataSet.remarksSize.height, left: 0, bottom: candlestickDataSet.remarksSize.height, right: 0))
        topPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: borderLayer.frame.minY, width: 100, height: 14)
        bottomPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: candlestickChart.frame.maxY, width: 100, height: 14)
        xAxisLayer.frame = mainChartFrame.zoomIn(UIEdgeInsets(top: 14, left: 0, bottom: 34, right: 0))
        xAxisTextBackLayer.frame = CGRect(x: xAxisLayer.frame.minX, y: xAxisLayer.frame.maxY - 14, width: xAxisLayer.bounds.width, height: 14)
        barLineChart.frame = CGRect(x: borderLayer.frame.minX, y: xAxisLayer.frame.maxY + 3, width: mainChartFrame.width, height: borderLayer.bounds.height - xAxisLayer.frame.height - 3)
        bottomLineChart.frame = barLineChart.frame
    }
    
    func prepareRendering() {
        guard let dataSource = dataSource else { return }
        candlestickDataSet.points = []
        ma5LineDataSet.points = []
        ma10LineDataSet.points = []
        ma20LineDataSet.points = []
        xAxisDataSet.points = []
        increaseBusinessAmountDataSet.frames = []
        decreaseBusinessAmountDataSet.frames = []
        increaseMACDDataSet.frames = []
        decreaseMACDDataSet.frames = []
        DEADataSet.points = []
        DIFFDataSet.points = []
        KLineDataSet.points = []
        DLineDataSet.points = []
        JLineDataSet.points = []
        WRDataSet.points = []
        RSI6DataSet.points = []
        RSI12DataSet.points = []
        RSI24DataSet.points = []
        
        let lIndex = leftIndex
        let rIndex = rightIndex
        let nodes = (lIndex...rIndex).map { dataSource.klineChartRenderer(self, nodeAt: $0) }
        let result = VDStockDataHandle.calculate(nodes)
        maxPrice = result.maxPrice
        minPrice = result.minPrice
        maxBusinessAmount = result.maxBusinessAmount
        minBusinessAmount = result.minBusinessAmount
        
        let yLength = maLineChart.bounds.height / CGFloat(result.maxPrice - result.minPrice)
        let businessAmountYLength = barLineChart.bounds.height / CGFloat(result.maxBusinessAmount)
        let MACDYLength = barLineChart.bounds.height / CGFloat(abs(result.maxMACD - result.minMACD))
        let KDJYLength = bottomLineChart.bounds.height / CGFloat(result.maxKDJ - result.minKDJ)
        let WRYLength = bottomLineChart.bounds.height / CGFloat(result.maxWR - result.minWR)
        let RSIYLength = bottomLineChart.bounds.height / CGFloat(result.maxRSI - result.minRSI)
        
        candlestickDataSet.barWidth = widthOfNode * container.scale
        candlestickDataSet.gap = gapOfNode * container.scale
        candlestickDataSet.lineWidth = 1
        
        // 使用CATextLayer这么用会出现BUG
        if isTouching {
            topPriceLabel.text = ""
            bottomPriceLabel.text = ""
        }
        else {
            let priceForPt = (maxPrice - minPrice) / Float(mainChartFrame.height - 14 * 2)
            topPriceLabel.text = String(result.maxPrice + priceForPt * (14 + 14))
            bottomPriceLabel.text = String(result.minPrice - priceForPt * Float(34))
        }
        
        for i in lIndex...rIndex {
            let node = nodes[i - lIndex]
            let candlestickPoint = candlestickDataSet.addPoint(with: node, nodeIndex: i, result: result, offsetX: container.offsetX, yLength: yLength)
            let maLineX = candlestickPoint.x + candlestickDataSet.barWidth * 0.5
            
            calculateMA(node.MA5, maxPrice: result.maxPrice, x: maLineX, yLength: yLength) { ma5LineDataSet.points.append($0) }
            calculateMA(node.MA10, maxPrice: result.maxPrice, x: maLineX, yLength: yLength) { ma10LineDataSet.points.append($0) }
            calculateMA(node.MA20, maxPrice: result.maxPrice, x: maLineX, yLength: yLength) { ma20LineDataSet.points.append($0) }
//            if isTouching {
//                calculateTouchingXAxis(centerX: touchingTargetPoint.x, text: node.time)
//            }
//            else {
            calculateXAxis(centerX: maLineX, index: i)
//            }
            
            switch indicatorType {
            case .businessAmount:
                calculateBusinessAmount(result: result, node: node, x: candlestickPoint.x, yLength: businessAmountYLength, width: candlestickDataSet.barWidth)
            case .MACD:
                calculateMACD(node: node, maxMACD: result.maxMACD, x: maLineX, yLength: MACDYLength, width: 1)
            case .KDJ:
                calculateKDJ(node: node, maxKDJ: result.maxKDJ, x: maLineX, yLength: KDJYLength)
            case .WR:
                calculateWR(node: node, maxWR: result.maxWR, x: maLineX, yLength: WRYLength)
            case .RSI:
                calculateRSI(node: node, maxRSI: result.maxRSI, x: maLineX, yLength: RSIYLength)
            }
        }
    }
    
    func rendering() {
        renderingBorder()
        candlestickChart.draw(candlestickDataSet)
        maLineChart.draw([ma5LineDataSet, ma10LineDataSet, ma20LineDataSet])
        xAxisLayer.draw(xAxisDataSet)
        barLineChart.draw([increaseBusinessAmountDataSet, decreaseBusinessAmountDataSet,increaseMACDDataSet, decreaseMACDDataSet])
        bottomLineChart.draw([DEADataSet, DIFFDataSet, KLineDataSet, DLineDataSet, JLineDataSet, WRDataSet, RSI6DataSet, RSI12DataSet, RSI24DataSet])
    }
    
    func reRendering() {
        prepareRendering()
        rendering()
    }
    
    func renderingTouchTarget(point: CGPoint) {
        
        let point = CGPoint(x: point.x - borderLayer.frame.minX, y: point.y - borderLayer.frame.minY)
        isTouching = true
        touchingTargetPoint = point
        reRendering()
        
        if point.x < 0 || point.x > borderLayer.bounds.width { return }
        if point.y < 0 || point.y > borderLayer.bounds.height { return }
        let path = UIBezierPath()
        path.lineWidth = 1
        
        path.move(to: CGPoint(x: 0, y: point.y))
        path.addLine(to: CGPoint(x: borderLayer.bounds.width, y: point.y))
        
        var node : KlineNode? = nil
        let lIndex = leftIndex
        let rIndex = rightIndex
        var targetPointX: CGFloat = 0
        for i in lIndex...rIndex {
            let p = candlestickDataSet.points[i - lIndex]
            guard i - lIndex + 1 < candlestickDataSet.points.count else {
                targetPointX = p.x
                node = dataSource?.klineChartRenderer(self, nodeAt: i)
                selectedNodeIndex = i
                break
            }
            let pNext = candlestickDataSet.points[i - lIndex + 1]
            if point.x > p.x && point.x < pNext.x && pNext.x != 0 {
                targetPointX = p.x
                node = dataSource?.klineChartRenderer(self, nodeAt: i)
                selectedNodeIndex = i
                break
            }
        }
        
        guard let selectedNode = node else { return }
        
        let x = targetPointX + widthOfNode * container.scale * 0.5
        
        if x < 0 || x > borderLayer.bounds.width { return }
        
        targetLayer.sublayers?.removeAll()
        
        path.move(to: CGPoint(x: x, y: 0))
        path.addLine(to: CGPoint(x: x, y: borderLayer.bounds.height))
        
        targetLayer.path = path.cgPath
        
        let dateBackgroundLayer = CALayer()
        dateBackgroundLayer.backgroundColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
        dateBackgroundLayer.frame = CGRect(x: 0, y: xAxisLayer.bounds.maxY - 14, width: xAxisLayer.bounds.width, height: 14)
        targetLayer.addSublayer(dateBackgroundLayer)
        
        let dateText = selectedNode.time
        let dateTextLayer = CATextLayer()
        dateTextLayer.contentsScale = UIScreen.main.scale
        dateTextLayer.alignmentMode = kCAAlignmentCenter
        dateTextLayer.fontSize = 10
        dateTextLayer.string = dateText
        dateTextLayer.foregroundColor = UIColor.black.cgColor
        let textWidth = NSString(string: dateText).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 10)], context: nil).size.width
        var dateX = x - textWidth * 0.5
        if dateX + textWidth > mainChartFrame.width {
            dateX = dateBackgroundLayer.bounds.width - textWidth
        }
        if dateX < 0 {
            dateX = 0
        }
//        print(dateX)
        dateTextLayer.frame = CGRect(x: dateX, y: 0, width: textWidth, height: 14)
        dateBackgroundLayer.addSublayer(dateTextLayer)
        
        if point.y < xAxisLayer.bounds.maxY - 14 {
            let priceForPt = (maxPrice - minPrice) / Float(mainChartFrame.height - 14 * 2)
            let price = maxPrice + priceForPt * (14 + 14) - priceForPt * Float(point.y)
            let priceTextLayer = CATextLayer()
            priceTextLayer.contentsScale = UIScreen.main.scale
            priceTextLayer.alignmentMode = kCAAlignmentCenter
            priceTextLayer.fontSize = 10
            priceTextLayer.string = "\(price)"
            priceTextLayer.foregroundColor = UIColor.black.cgColor
            priceTextLayer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            priceTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - 50 : 0, y: point.y - 7.5, width: 50, height: 15)
            targetLayer.addSublayer(priceTextLayer)
        }
        if point.y > xAxisLayer.bounds.maxY {
            let businessAmountForPt = (maxBusinessAmount) / Float(barLineChart.bounds.height)
            let businessAmount = maxBusinessAmount + businessAmountForPt * 3 - businessAmountForPt * Float(point.y - xAxisLayer.bounds.maxY)
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
            businessAmountTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - 50 : 0, y: point.y - 7.5, width: 50, height: 15)
            targetLayer.addSublayer(businessAmountTextLayer)
        }
        
        let maText = CATextLayer()
        maText.contentsScale = UIScreen.main.scale
        maText.alignmentMode = kCAAlignmentCenter
        maText.fontSize = 10
        maText.string = "MA5:\(selectedNode.MA5) MA10:\(selectedNode.MA10) MA20:\(selectedNode.MA20)"
        maText.foregroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        let maTextWidth = (maText.string as! NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 10)], context: nil).size.width
        maText.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - maTextWidth : 0, y: 0, width: maTextWidth, height: 15)
        targetLayer.addSublayer(maText)
        
        let businessAmountText = VDStockDataHandle.converNumberToString(number: selectedNode.businessAmount)
        let businessAmountTextLayer = CATextLayer()
        businessAmountTextLayer.contentsScale = UIScreen.main.scale
        businessAmountTextLayer.alignmentMode = kCAAlignmentCenter
        businessAmountTextLayer.fontSize = 10
        businessAmountTextLayer.string = "\(businessAmountText)手"
        businessAmountTextLayer.foregroundColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        let businessTextWidth = (businessAmountTextLayer.string as! NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 10)], context: nil).size.width
        businessAmountTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - businessTextWidth : 0, y: xAxisLayer.bounds.maxY, width: businessTextWidth, height: 15)
        targetLayer.addSublayer(businessAmountTextLayer)
    }

    func clearTouchTarget() {
        isTouching = false
        touchingTargetPoint = CGPoint()
        targetLayer.path = nil
        targetLayer.sublayers?.removeAll()
    }
    
    func reload() {
        guard let dataSource = dataSource else { return }
        let oldContentWidth = contentWidth
        numberOfNodes = dataSource.numberOfNodes(in: self)
        let newOffsetX = container.offsetX + contentWidth - oldContentWidth
        container.offsetX = max(newOffsetX, 0)
    }
    
    private func calculateMA(_ ma: Float, maxPrice: Float, x: CGFloat, yLength: CGFloat, completion: (CGPoint) -> Void) {
        if ma == 0 { return }
        completion(CGPoint(x: x, y: CGFloat(maxPrice - ma) * yLength))
    }
    
    private func calculateXAxis(centerX: CGFloat, index: Int) {
        if let text = dataSource?.klineChartRenderer(self, xAxisTextAt: index) {
            if index == 0 { return }
            let point = AxisPoint(centerX: centerX, text: text)
            xAxisDataSet.points.append(point)
        }
    }
    
    private func calculateTouchingXAxis(centerX: CGFloat, text: String) {
//        xAxisDataSet.points.removeAll()
//        let point = AxisPoint(centerX: centerX, text: text)
//        xAxisDataSet.points.append(point)
    }
    
    private func calculateBusinessAmount(result: KlineCalculateResult, node: KlineNode, x: CGFloat, yLength: CGFloat, width: CGFloat) {
        let y = CGFloat(result.maxBusinessAmount - node.businessAmount) * yLength
        let frame = CGRect(x: x, y: CGFloat(y), width: width, height: barLineChart.bounds.height - CGFloat(y))
        if node.isIncrease {
            increaseBusinessAmountDataSet.frames.append(frame)
        } else {
            decreaseBusinessAmountDataSet.frames.append(frame)
        }
    }
    
    /// 计算MACD指标坐标点
    private func calculateMACD(node: KlineNode, maxMACD: Double, x: CGFloat, yLength: CGFloat, width: CGFloat) {
        /// MACD以中心点为起点，正数向上 负数向下
        let height = CGFloat(abs(node.MACD)) * yLength * 0.5
        if node.MACD > 0 {
            increaseMACDDataSet.frames.append(CGRect(x: x, y: barLineChart.bounds.midY - height, width: width, height: height))
        } else {
            decreaseMACDDataSet.frames.append(CGRect(x: x, y: barLineChart.bounds.midY, width: width, height: height))
        }
        
        DIFFDataSet.points.append(CGPoint(x: x, y: CGFloat(abs(maxMACD - node.DIFF)) * yLength))
        DEADataSet.points.append(CGPoint(x: x, y: CGFloat(abs(maxMACD - node.DEA)) * yLength))
    }
    
    /// 计算KDJ指标坐标点
    private func calculateKDJ(node: KlineNode, maxKDJ: Double, x: CGFloat, yLength: CGFloat) {
        KLineDataSet.points.append(CGPoint(x: x, y: CGFloat(maxKDJ - node.K) * yLength))
        DLineDataSet.points.append(CGPoint(x: x, y: CGFloat(maxKDJ - node.D) * yLength))
        JLineDataSet.points.append(CGPoint(x: x, y: CGFloat(maxKDJ - node.J) * yLength))
    }
    
    private func calculateWR(node: KlineNode, maxWR: Double, x: CGFloat, yLength: CGFloat) {
        WRDataSet.points.append(CGPoint(x: x, y: CGFloat(maxWR - node.WR) * yLength))
    }
    
    private func calculateRSI(node: KlineNode, maxRSI: Double, x: CGFloat, yLength: CGFloat) {
        RSI6DataSet.points.append(CGPoint(x: x, y: CGFloat(maxRSI - node.RSI6) * yLength))
        RSI12DataSet.points.append(CGPoint(x: x, y: CGFloat(maxRSI - node.RSI12) * yLength))
        RSI24DataSet.points.append(CGPoint(x: x, y: CGFloat(maxRSI - node.RSI24) * yLength))
    }
    
    private func renderingBorder() {
        let path = UIBezierPath(rect: borderLayer.bounds.zoomIn(borderWidth * 0.5))
        borderLayer.path = path.cgPath
    }

}
