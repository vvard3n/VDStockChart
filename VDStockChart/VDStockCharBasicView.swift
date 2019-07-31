//
//  VDStockCharBasicView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/6/8.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

public enum StockChartRendererType: Int {
    case timeline = 0
    case day = 1
    case week = 2
    case month = 3
    case year = 4
}

public enum VDStockCharType {
    case index
    case stock
}

//public protocol VDStockCharBasicViewDelegate: VDChartViewDelegate {}
public protocol VDStockCharBasicViewDelegate: NSObjectProtocol {
    func chartViewDidClickRehabilitationBtn(_ chartView: VDChartView, sender: UIButton, currentStatus: Int)
    func chartViewDidChangeTab(index: Int)
}

//public protocol VDStockCharBasicViewDataSource: VDKLineChartRendererDataSource, VDTimeLineChartRendererDataSource {}
public protocol VDStockCharBasicViewDataSource: NSObjectProtocol {
    
    func sharesPerHand(in renderer: Any) -> Int
    func numberOfNodes(type: StockChartRendererType) -> Int
    func stockChartRenderer(type: StockChartRendererType, nodeAt index: Int) -> Any
    func stockChartRenderer(type: StockChartRendererType, xAxisTextAt index: Int) -> String?
    func yesterdayClosePrice(in renderer: VDTimeChartLineRenderer) -> Float
    func tradingData(type: StockChartRendererType) -> StockDealInfoViewModel?
}

public class VDStockCharBasicView: UIView {
    var type: VDStockCharType = .stock
    
    weak var delegate: VDStockCharBasicViewDelegate? = nil
    var dataSource: VDStockCharBasicViewDataSource? = nil
    
    //    var kLineNodes = [KlineNode]()
    //    var timeLineNodes = [TimeLineNode]()
    var dayKlineRenderer: VDChartRenderer!
    var weekKlineRenderer: VDChartRenderer!
    var monthKlineRenderer: VDChartRenderer!
    var yearKlineRenderer: VDChartRenderer!
    var timeLineRenderer: VDChartRenderer!
    var chartView: VDChartView!
    var priceView: VDChartPriceView!
    var tabView: VDTabView!
    var rehabilitationBtn: UIButton!
    public var selectedRehabilitationType = 0 {
        didSet {
            if selectedRehabilitationType == 0 {
                rehabilitationBtn.setTitle("不复权", for: .normal)
                rehabilitationBtn.tag = 0
            }
            else if selectedRehabilitationType == 1 {
                rehabilitationBtn.setTitle("前复权", for: .normal)
                rehabilitationBtn.tag = 1
            }
            else {
                rehabilitationBtn.setTitle("后复权", for: .normal)
                rehabilitationBtn.tag = 2
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    public init(frame: CGRect, dataSource: VDStockCharBasicViewDataSource, delegate: VDStockCharBasicViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.dataSource = dataSource
        initSubviews()
    }
    
    public init(frame: CGRect, type: VDStockCharType, dataSource: VDStockCharBasicViewDataSource, delegate: VDStockCharBasicViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.dataSource = dataSource
        self.type = type
        initSubviews()
    }
    
    private func initSubviews() {
        tabView = VDTabView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        tabView.titles = ["分时", "日K", "周K", "月K", "年K"]
        tabView.isScrollEnabled = false
        tabView.didTapTabLabel = { index in
            if index == 0 {
                self.timeLineRenderer.showRightView = self.type == .stock ? true : false
                self.chartView.renderer = self.timeLineRenderer
                //                self.priceView.titles = ["开", "高", "幅", "成交"]
                self.rehabilitationBtn.isHidden = true
            }
            else if index == 1 {
                self.chartView.renderer = self.dayKlineRenderer
                self.priceView.titles = ["开", "高", "幅", "", "收", "低", "量", "额"]
                self.rehabilitationBtn.isHidden = false
            }
            else if index == 2 {
                self.chartView.renderer = self.weekKlineRenderer
                self.priceView.titles = ["开", "高", "幅", "", "收", "低", "量", "额"]
                self.rehabilitationBtn.isHidden = false
            }
            else if index == 3 {
                self.chartView.renderer = self.monthKlineRenderer
                self.priceView.titles = ["开", "高", "幅", "", "收", "低", "量", "额"]
                self.rehabilitationBtn.isHidden = false
            }
            else if index == 4 {
                self.chartView.renderer = self.yearKlineRenderer
                self.priceView.titles = ["开", "高", "幅", "", "收", "低", "量", "额"]
                self.rehabilitationBtn.isHidden = false
            }
            self.delegate?.chartViewDidChangeTab(index: index)
        }
        addSubview(tabView)
        
        chartView = VDChartView(frame: CGRect(x: 0, y: 30, width: UIScreen.main.bounds.size.width, height: frame.size.height - 30))
        chartView.delegate = self
        chartView.backgroundColor = UIColor.white
        dayKlineRenderer = VDKLineChartRenderer(container: chartView, dataSource: self)
        dayKlineRenderer.rendererType = .day
        weekKlineRenderer = VDKLineChartRenderer(container: chartView, dataSource: self)
        weekKlineRenderer.rendererType = .week
        monthKlineRenderer = VDKLineChartRenderer(container: chartView, dataSource: self)
        monthKlineRenderer.rendererType = .month
        yearKlineRenderer = VDKLineChartRenderer(container: chartView, dataSource: self)
        yearKlineRenderer.rendererType = .year
        timeLineRenderer = VDTimeChartLineRenderer(container: chartView, dataSource: self, showRightView: type == .stock ? true : false)
        timeLineRenderer.showAvgLine = (type == .stock)
        chartView.renderer = timeLineRenderer
        addSubview(chartView)
        
        priceView = VDChartPriceView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: tabView.bounds.size.height))
        priceView.titles = ["开", "高", "幅", "成交"]
        priceView.backgroundColor = UIColor.white
        priceView.isHidden = true
        addSubview(priceView)
        
        rehabilitationBtn = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 80, y: tabView.frame.maxY, width: 80, height: 20))
        rehabilitationBtn.backgroundColor = UIColor.white
        rehabilitationBtn.setTitle("不复权", for: .normal)
        rehabilitationBtn.titleLabel?.font = .systemFont(ofSize: 12)
        rehabilitationBtn.setTitleColor(UIColor(red: 51/255.0, green: 49/255.0, blue: 49/255.0, alpha: 1), for: .normal)
        rehabilitationBtn.isHidden = true
        rehabilitationBtn.addTarget(self, action: #selector(rehabilitationBtnDidClick(sender:)), for: .touchUpInside)
        rehabilitationBtn.tag = 0
        addSubview(rehabilitationBtn)
    }
    
    @objc private func rehabilitationBtnDidClick(sender: UIButton) {
        delegate?.chartViewDidClickRehabilitationBtn(chartView, sender: sender, currentStatus: rehabilitationBtn.tag)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func reloadData() {
        chartView.reload()
    }
}

extension VDStockCharBasicView: VDChartViewDelegate {
    
    public func chartViewDidTouchTarget(_ chartView: VDChartView, touchPoint: CGPoint, nodeIndex: Int) {
        
        if chartView.renderer === dayKlineRenderer {
            priceView.isHidden = false
            let nodeData = klineChartRenderer(dayKlineRenderer as! VDKLineChartRenderer, nodeAt: nodeIndex)
            priceView.sharesPerHand = sharesPerHand(in: dayKlineRenderer as! VDKLineChartRenderer)
            priceView.node = nodeData
        }
        else if chartView.renderer === weekKlineRenderer {
            priceView.isHidden = false
            let nodeData = klineChartRenderer(weekKlineRenderer as! VDKLineChartRenderer, nodeAt: nodeIndex)
            priceView.sharesPerHand = sharesPerHand(in: weekKlineRenderer as! VDKLineChartRenderer)
            priceView.node = nodeData
        }
        else if chartView.renderer === monthKlineRenderer {
            priceView.isHidden = false
            let nodeData = klineChartRenderer(monthKlineRenderer as! VDKLineChartRenderer, nodeAt: nodeIndex)
            priceView.sharesPerHand = sharesPerHand(in: monthKlineRenderer as! VDKLineChartRenderer)
            priceView.node = nodeData
        }
        else if chartView.renderer === yearKlineRenderer {
            priceView.isHidden = false
            let nodeData = klineChartRenderer(yearKlineRenderer as! VDKLineChartRenderer, nodeAt: nodeIndex)
            priceView.sharesPerHand = sharesPerHand(in: yearKlineRenderer as! VDKLineChartRenderer)
            priceView.node = nodeData
        }
    }
    
    public func chartViewDidCancelTouchTarget(_ chartView: VDChartView) {
        priceView.isHidden = true
    }
}

extension VDStockCharBasicView: VDKLineChartRendererDataSource {
    public func sharesPerHand(in renderer: VDKLineChartRenderer) -> Int {
        return dataSource?.sharesPerHand(in: renderer) ?? 100
    }
    
    public func numberOfNodes(in renderer: VDKLineChartRenderer) -> Int {
        return dataSource?.numberOfNodes(type: renderer.rendererType) ?? 0
    }
    
    public func klineChartRenderer(_ renderer: VDKLineChartRenderer, nodeAt index: Int) -> KlineNode {
        return dataSource?.stockChartRenderer(type: renderer.rendererType, nodeAt: index) as? KlineNode ?? KlineNode()
    }
    
    public func klineChartRenderer(_ renderer: VDKLineChartRenderer, xAxisTextAt index: Int) -> String? {
        return dataSource?.stockChartRenderer(type: renderer.rendererType, xAxisTextAt: index)
    }
}

extension VDStockCharBasicView: VDTimeLineChartRendererDataSource {
    public func sharesPerHand(in renderer: VDTimeChartLineRenderer) -> Int {
        return dataSource?.sharesPerHand(in: renderer) ?? 100
    }
    
    public func numberOfNodes(in renderer: VDTimeChartLineRenderer) -> Int {
        return dataSource?.numberOfNodes(type: renderer.rendererType) ?? 0
    }
    
    public func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, nodeAt index: Int) -> TimeLineNode {
        return dataSource?.stockChartRenderer(type: renderer.rendererType, nodeAt: index) as? TimeLineNode ?? TimeLineNode()
    }
    
    public func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, xAxisTextAt index: Int) -> String? {
        return dataSource?.stockChartRenderer(type: renderer.rendererType, xAxisTextAt: index)
    }
    
    public func yesterdayClosePrice(in renderer: VDTimeChartLineRenderer) -> Float {
        return dataSource?.yesterdayClosePrice(in: renderer) ?? 0
    }
    
    public func timeLineChartRendererRightData(_ renderer: VDTimeChartLineRenderer) -> StockDealInfoViewModel? {
        return dataSource?.tradingData(type: renderer.rendererType)
    }
}
