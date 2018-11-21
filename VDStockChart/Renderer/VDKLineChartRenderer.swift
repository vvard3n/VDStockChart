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

public protocol VDKLineChartRendererDataSource: class {
    func numberOfNodes(in renderer: VDKLineChartRenderer) -> Int
    func klineChartRenderer(_ renderer: VDKLineChartRenderer, nodeAt index: Int) -> KlineNode
    func klineChartRenderer(_ renderer: VDKLineChartRenderer, xAxisTextAt index: Int) -> String?
    func sharesPerHand(in renderer: VDKLineChartRenderer) -> Int
}

public class VDKLineChartRenderer: VDChartRenderer {
    var rendererType: StockChartRendererType = .day
    var showAvgLine: Bool = false // unused
    
    private(set) var container: VDChartContainer
    /// 数据源
    weak var dataSource: VDKLineChartRendererDataSource?
    var indicatorType: VDKLineChartIndicatorType = .businessAmount
    /// Style
    var showRightView: Bool = false
    var borderWidth: CGFloat = CGFloatFromPixel(pixel: 1)
    var borderColor: UIColor = #colorLiteral(red: 0.8904301524, green: 0.88513726, blue: 0.8944990039, alpha: 1)
    let borderLayer = CAShapeLayer()
    /// ChartRenderer
    var sharesPerHand: Int = 100
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
    private var centerTopPriceLabel = UILabel()
    private var centerPriceLabel = UILabel()
    private var centerBottomPriceLabel = UILabel()
    private var bottomPriceLabel = UILabel()
    private var turnoverTitleLbl = CATextLayer()
    private var turnoverLbl = UILabel()
    private var topInfoLabel = UILabel()
    private var xAxisLayer = AxisLayer()
    private var xAxisTextBackLayer = CALayer()
    private var xAxisCenterTextBackLayer = CALayer()
    private var topTurnoverLabel = UILabel()
    private let targetLayer = CAShapeLayer()
    /// DataSet
    private let candlestickDataSet = CandleChartDataSet()
    private var ma5LineDataSet = LineChartDataSet()
    private var ma10LineDataSet = LineChartDataSet()
    private var ma30LineDataSet = LineChartDataSet()
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
    internal var selectedNodeIndex: Int = -1
    
    init(container: VDChartContainer, dataSource: VDKLineChartRendererDataSource) {
        self.container = container
        self.dataSource = dataSource
        
        candlestickDataSet.remarksColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
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
        topInfoLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        ma5LineDataSet.lineColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0.03921568627, alpha: 1)
        ma10LineDataSet.lineColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 1)
        ma30LineDataSet.lineColor = #colorLiteral(red: 0.831372549, green: 0.2862745098, blue: 0.6509803922, alpha: 1)
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        
        targetLayer.fillColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
        targetLayer.strokeColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
        
        topTurnoverLabel.font = UIFont.systemFont(ofSize: 10)
        topTurnoverLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        xAxisTextBackLayer.backgroundColor = UIColor.white.cgColor
        xAxisCenterTextBackLayer.backgroundColor = UIColor.white.cgColor
        
        topPriceLabel.font = UIFont.systemFont(ofSize: 10)
        topPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        centerTopPriceLabel.font = UIFont.systemFont(ofSize: 10)
        centerTopPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        centerPriceLabel.font = UIFont.systemFont(ofSize: 10)
        centerPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
        centerBottomPriceLabel.font = UIFont.systemFont(ofSize: 10)
        centerBottomPriceLabel.textColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
        
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
        return [borderLayer, xAxisTextBackLayer, xAxisLayer, candlestickChart, maLineChart, barLineChart, bottomLineChart, targetLayer, xAxisCenterTextBackLayer, turnoverTitleLbl]
    }
    
    var views: [UIView] {
        return [topPriceLabel, centerTopPriceLabel, centerPriceLabel, centerBottomPriceLabel, bottomPriceLabel, turnoverLbl, topInfoLabel, topTurnoverLabel]
    }
    
    func layout() {
        borderLayer.frame = container.bounds.zoomOut(UIEdgeInsets(top: 20, left: 5, bottom: 20, right: 5)).zoomOut(borderWidth)
        targetLayer.frame = borderLayer.frame
        mainChartFrame = CGRect(x: borderLayer.frame.minX, y: borderLayer.frame.minY, width: borderLayer.bounds.width, height: borderLayer.bounds.height * 0.7)
        candlestickChart.frame = mainChartFrame
        maLineChart.frame = mainChartFrame.zoomOut(UIEdgeInsets(top: candlestickDataSet.remarksSize.height, left: 0, bottom: candlestickDataSet.remarksSize.height, right: 0))
        
        topPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: borderLayer.frame.minY, width: 100, height: 14)
        centerTopPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: candlestickChart.frame.minY + candlestickChart.bounds.height * 0.25 - 14, width: 100, height: 14)
        centerPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: candlestickChart.frame.minY + candlestickChart.bounds.height * 0.5 - 14, width: 100, height: 14)
        centerBottomPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: candlestickChart.frame.minY + candlestickChart.bounds.height * 0.75 - 14, width: 100, height: 14)
        bottomPriceLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: candlestickChart.frame.maxY - 14, width: 100, height: 14)
        
        turnoverTitleLbl.frame = CGRect(x: borderLayer.frame.minX, y: mainChartFrame.maxY + 3, width: 33, height: 14)
        turnoverLbl.frame = CGRect(x: turnoverTitleLbl.frame.maxX + 2, y: turnoverTitleLbl.frame.minY, width: 200, height: 14)
        
        topInfoLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: 3, width: mainChartFrame.width - 2, height: 14)
        
        xAxisLayer.frame = targetLayer.frame.zoomOut(UIEdgeInsets(top: 0, left: 0, bottom: -14, right: 0))
        xAxisTextBackLayer.frame = CGRect(x: xAxisLayer.frame.minX, y: xAxisLayer.frame.maxY - 14, width: xAxisLayer.bounds.width, height: 14)
        xAxisCenterTextBackLayer.frame = CGRect(x: 0, y: candlestickChart.frame.maxY + borderWidth * 0.5, width: mainChartFrame.width + 5, height: 14 + 3 * 2 - borderWidth)
        barLineChart.frame = CGRect(x: borderLayer.frame.minX, y: mainChartFrame.maxY + 14 + 3 * 2, width: mainChartFrame.width, height: borderLayer.bounds.height - candlestickChart.bounds.height - 14 - 3 * 2)
        topTurnoverLabel.frame = CGRect(x: borderLayer.frame.minX + 2, y: barLineChart.frame.minY, width: 100, height: 14)
        bottomLineChart.frame = barLineChart.frame
    }
    
    func prepareRendering() {
        guard let dataSource = dataSource else { return }
        candlestickDataSet.points = []
        ma5LineDataSet.points = []
        ma10LineDataSet.points = []
        ma30LineDataSet.points = []
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
        if dataSource.numberOfNodes(in: self) == 0 { return }
        let nodes = (lIndex...rIndex).map { dataSource.klineChartRenderer(self, nodeAt: $0) }
        sharesPerHand = dataSource.sharesPerHand(in: self)
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
            centerTopPriceLabel.text = ""
            centerPriceLabel.text = ""
            centerBottomPriceLabel.text = ""
            bottomPriceLabel.text = ""
        }
        else {
            let priceForPt = (maxPrice - minPrice) / Float(mainChartFrame.height)
            topPriceLabel.text = String(format: "%.2f", result.maxPrice)
            centerTopPriceLabel.text = String(format: "%.2f", maxPrice - Float(candlestickChart.bounds.height) * 0.25 * priceForPt)
            centerPriceLabel.text = String(format: "%.2f", maxPrice - Float(candlestickChart.bounds.height) * 0.5 * priceForPt)
            centerBottomPriceLabel.text = String(format: "%.2f", maxPrice - Float(candlestickChart.bounds.height) * 0.75 * priceForPt)
            bottomPriceLabel.text = String(format: "%.2f", result.minPrice)
        }
        
        if let lastNode = nodes.last {
            let mAttStr = NSMutableAttributedString()
            mAttStr.append(NSAttributedString(string: String(format: "MA5:%@", lastNode.MA5 == 0 ? "--" : String(format: "%.2f", lastNode.MA5)), attributes: [NSAttributedStringKey.foregroundColor : ma5LineDataSet.lineColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]))
            mAttStr.append(NSAttributedString(string: String(format: " MA10:%@", lastNode.MA10 == 0 ? "--" : String(format: "%.2f", lastNode.MA10)), attributes: [NSAttributedStringKey.foregroundColor : ma10LineDataSet.lineColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]))
            mAttStr.append(NSAttributedString(string: String(format: " MA30:%@", lastNode.MA30 == 0 ? "--" : String(format: "%.2f", lastNode.MA30)), attributes: [NSAttributedStringKey.foregroundColor : ma30LineDataSet.lineColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]))
            topInfoLabel.attributedText = mAttStr
            
            turnoverLbl.text = String(format: "%@手", VDStockDataHandle.converNumberToString(number: lastNode.businessAmount / Float(sharesPerHand), decimal: false))
        }
        
        for i in lIndex...rIndex {
            let node = nodes[i - lIndex]
            let candlestickPoint = candlestickDataSet.addPoint(with: node, nodeIndex: i, result: result, offsetX: container.offsetX, yLength: yLength)
            let maLineX = candlestickPoint.x + candlestickDataSet.barWidth * 0.5
            
            calculateMA(node.MA5, maxPrice: result.maxPrice, x: maLineX, yLength: yLength) { ma5LineDataSet.points.append($0) }
            calculateMA(node.MA10, maxPrice: result.maxPrice, x: maLineX, yLength: yLength) { ma10LineDataSet.points.append($0) }
            calculateMA(node.MA30, maxPrice: result.maxPrice, x: maLineX, yLength: yLength) { ma30LineDataSet.points.append($0) }
            calculateXAxis(centerX: maLineX, index: i)
            
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
        
        if xAxisDataSet.points.count > 4 {
            let p1 = xAxisDataSet.points[0]
            let p2 = xAxisDataSet.points[Int(floor(Double(xAxisDataSet.points.count) / 4.0 * 2)) - 1]
            let p3 = xAxisDataSet.points[Int(floor(Double(xAxisDataSet.points.count) / 4.0 * 3)) - 1]
            let p4 = xAxisDataSet.points[xAxisDataSet.points.count - 1]
            //            xAxisDataSet.points.removeAll()
            xAxisDataSet.points = [p1, p2, p3, p4]
        }
        
        topTurnoverLabel.text = "\(VDStockDataHandle.converNumberToString(number: result.maxBusinessAmount / Float(sharesPerHand), decimal: false))手"
    }
    
    func rendering() {
        renderingBorder()
        candlestickChart.draw(candlestickDataSet)
        maLineChart.draw([ma5LineDataSet, ma10LineDataSet, ma30LineDataSet])
        xAxisLayer.draw(xAxisDataSet)
        barLineChart.draw([increaseBusinessAmountDataSet, decreaseBusinessAmountDataSet,increaseMACDDataSet, decreaseMACDDataSet])
        bottomLineChart.draw([DEADataSet, DIFFDataSet, KLineDataSet, DLineDataSet, JLineDataSet, WRDataSet, RSI6DataSet, RSI12DataSet, RSI24DataSet])
    }
    
    func reRendering() {
        prepareRendering()
        rendering()
    }
    
    func renderingTouchTarget(point: CGPoint) {
        
        if dataSource?.numberOfNodes(in: self) == 0 { return }
        
        var point = CGPoint(x: point.x - borderLayer.frame.minX, y: point.y - borderLayer.frame.minY)
        isTouching = true
        touchingTargetPoint = point
        reRendering()
        
        //        if point.x < 0 || point.x > borderLayer.bounds.width { return }
        //        if point.y < 0 || point.y > borderLayer.bounds.height { return }
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
            if point.x >= p.x && point.x < pNext.x && pNext.x != 0 {
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
        //        dateBackgroundLayer.backgroundColor = UIColor.white.cgColor
        dateBackgroundLayer.frame = CGRect(x: 0, y: xAxisLayer.bounds.maxY - 14, width: xAxisLayer.bounds.width, height: 14)
        targetLayer.addSublayer(dateBackgroundLayer)
        
        let dateText = selectedNode.time
        let dateTextLayer = CATextLayer()
        dateTextLayer.contentsScale = UIScreen.main.scale
        dateTextLayer.alignmentMode = kCAAlignmentCenter
        dateTextLayer.fontSize = 10
        dateTextLayer.string = dateText
        dateTextLayer.foregroundColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 1)
        dateTextLayer.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9921568627, blue: 1, alpha: 1)
        dateTextLayer.borderColor = ThemeColor.LIGHT_LINE_COLOR_EEEEEE.cgColor
        dateTextLayer.borderWidth = CGFloatFromPixel(pixel: 1)
        dateTextLayer.cornerRadius = 2
        dateTextLayer.masksToBounds = true
        let textWidth = NSString(string: dateText).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14), options: .usesLineFragmentOrigin, attributes: [.font : UIFont.systemFont(ofSize: 10)], context: nil).size.width
        var dateX = x - textWidth * 0.5
        if dateX + textWidth > mainChartFrame.width {
            dateX = dateBackgroundLayer.bounds.width - textWidth
        }
        if dateX < 0 {
            dateX = 0
        }
        //        print(dateX)
        dateTextLayer.frame = CGRect(x: dateX, y: 0, width: textWidth + 5, height: 14)
        dateBackgroundLayer.addSublayer(dateTextLayer)
        
        if point.y < candlestickChart.bounds.height {
            let priceForPt = (maxPrice - minPrice) / Float(mainChartFrame.height)
            let price = maxPrice - priceForPt * Float(point.y)
            let priceTextLayer = CATextLayer()
            priceTextLayer.contentsScale = UIScreen.main.scale
            priceTextLayer.alignmentMode = kCAAlignmentCenter
            priceTextLayer.fontSize = 10
            priceTextLayer.string = String(format: "%.2f", price)
            priceTextLayer.foregroundColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 1)
            priceTextLayer.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9921568627, blue: 1, alpha: 1)
            priceTextLayer.borderColor = ThemeColor.LIGHT_LINE_COLOR_EEEEEE.cgColor
            priceTextLayer.borderWidth = CGFloatFromPixel(pixel: 1)
            priceTextLayer.cornerRadius = 2
            priceTextLayer.masksToBounds = true
            var y = point.y - 7.5 // 减去label半高
            print(y)
            if y < 0 { y = 0 }
            if y + 15 > candlestickChart.bounds.height { y = candlestickChart.bounds.height - 15 }
            priceTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - 50 : 0, y: y, width: 50, height: 15)
            targetLayer.addSublayer(priceTextLayer)
        }
        if point.y > candlestickChart.bounds.height + xAxisCenterTextBackLayer.bounds.height + borderWidth {
            let businessAmountForPt = (maxBusinessAmount) / Float(barLineChart.bounds.height)
            var businessAmount = maxBusinessAmount - businessAmountForPt * Float(point.y - candlestickChart.bounds.height - xAxisCenterTextBackLayer.bounds.height - borderWidth)
            if businessAmount < 0 { businessAmount = 0 }
            let businessAmountTextLayer = CATextLayer()
            businessAmountTextLayer.contentsScale = UIScreen.main.scale
            businessAmountTextLayer.alignmentMode = kCAAlignmentCenter
            businessAmountTextLayer.fontSize = 10
            let businessAmountText = String(format: "%@手", VDStockDataHandle.converNumberToString(number: businessAmount / Float(sharesPerHand), decimal: false))
            businessAmountTextLayer.string = businessAmountText
            businessAmountTextLayer.foregroundColor = #colorLiteral(red: 0.06666666667, green: 0.5450980392, blue: 1, alpha: 1)
            businessAmountTextLayer.backgroundColor = #colorLiteral(red: 0.9803921569, green: 0.9921568627, blue: 1, alpha: 1)
            businessAmountTextLayer.borderColor = ThemeColor.LIGHT_LINE_COLOR_EEEEEE.cgColor
            businessAmountTextLayer.borderWidth = CGFloatFromPixel(pixel: 1)
            businessAmountTextLayer.cornerRadius = 2
            businessAmountTextLayer.masksToBounds = true
            var y = point.y - 7.5
            if y < candlestickChart.bounds.height + xAxisCenterTextBackLayer.bounds.height + borderWidth { y = candlestickChart.bounds.height + xAxisCenterTextBackLayer.bounds.height + borderWidth }
            if y + 15 > targetLayer.bounds.height { y = targetLayer.bounds.height - 15 }
            businessAmountTextLayer.frame = CGRect(x: point.x < borderLayer.frame.width * 0.5 ? borderLayer.frame.width - 50 : 0, y: y, width: 50, height: 15)
            targetLayer.addSublayer(businessAmountTextLayer)
        }
        
        //        let businessAmountText = VDStockDataHandle.converNumberToString(number: selectedNode.businessAmount)
        
        turnoverLbl.text = String(format: "%@手", VDStockDataHandle.converNumberToString(number: selectedNode.businessAmount / Float(sharesPerHand), decimal: false))
        //        turnoverLbl.text = "\(businessAmountText)"
        
        
        let mAttStr = NSMutableAttributedString()
        mAttStr.append(NSAttributedString(string: String(format: "MA5:%@", selectedNode.MA5 == 0 ? "--" : String(format: "%.2f", selectedNode.MA5)), attributes: [NSAttributedStringKey.foregroundColor : ma5LineDataSet.lineColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]))
        mAttStr.append(NSAttributedString(string: String(format: " MA10:%@", selectedNode.MA10 == 0 ? "--" : String(format: "%.2f", selectedNode.MA10)), attributes: [NSAttributedStringKey.foregroundColor : ma10LineDataSet.lineColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]))
        mAttStr.append(NSAttributedString(string: String(format: " MA30:%@", selectedNode.MA30 == 0 ? "--" : String(format: "%.2f", selectedNode.MA30)), attributes: [NSAttributedStringKey.foregroundColor : ma30LineDataSet.lineColor, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)]))
        topInfoLabel.attributedText = mAttStr
    }
    
    func clearTouchTarget() {
        isTouching = false
        touchingTargetPoint = CGPoint()
        targetLayer.path = nil
        targetLayer.sublayers?.removeAll()
        turnoverLbl.text = ""
    }
    
    func reload() {
        guard let dataSource = dataSource else { return }
        let oldContentWidth = contentWidth
        numberOfNodes = dataSource.numberOfNodes(in: self)
        sharesPerHand = dataSource.sharesPerHand(in: self)
        let newOffsetX = container.offsetX + contentWidth - oldContentWidth
        container.offsetX = max(newOffsetX, 0)
    }
    
    private func calculateMA(_ ma: Float, maxPrice: Float, x: CGFloat, yLength: CGFloat, completion: (CGPoint) -> Void) {
        if ma == 0 { return }
        completion(CGPoint(x: x, y: CGFloat(maxPrice - ma) * yLength))
    }
    
    private func calculateXAxis(centerX: CGFloat, index: Int) {
        if dataSource?.numberOfNodes(in: self) == 0 { return }
        if let text = dataSource?.klineChartRenderer(self, xAxisTextAt: index) {
            if index == 0 { return }
            let point = AxisPoint(centerX: centerX, text: text)
            xAxisDataSet.points.append(point)
        }
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
        
        path.move(to: CGPoint(x: 0, y: candlestickChart.bounds.height * 0.25))
        path.addLine(to: CGPoint(x: candlestickChart.bounds.width, y: candlestickChart.bounds.height * 0.25))
        
        path.move(to: CGPoint(x: 0, y: candlestickChart.bounds.height * 0.5))
        path.addLine(to: CGPoint(x: candlestickChart.bounds.width, y: candlestickChart.bounds.height * 0.5))
        
        path.move(to: CGPoint(x: 0, y: candlestickChart.bounds.height * 0.75))
        path.addLine(to: CGPoint(x: candlestickChart.bounds.width, y: candlestickChart.bounds.height * 0.75))
        
        path.move(to: CGPoint(x: 0, y: candlestickChart.bounds.height))
        path.addLine(to: CGPoint(x: candlestickChart.bounds.width, y: candlestickChart.bounds.height))
        
        path.move(to: CGPoint(x: 0, y: borderLayer.bounds.height - barLineChart.bounds.height))
        path.addLine(to: CGPoint(x: barLineChart.bounds.width, y: borderLayer.bounds.height - barLineChart.bounds.height))
        
        path.move(to: CGPoint(x: 0, y: borderLayer.bounds.height - barLineChart.bounds.height + 0.5 * barLineChart.bounds.height))
        path.addLine(to: CGPoint(x: barLineChart.bounds.width, y: borderLayer.bounds.height - barLineChart.bounds.height + 0.5 * barLineChart.bounds.height))
        
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = borderWidth
    }
    
}
