//
//  VDStockCharBasicView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/6/8.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

public protocol VDStockCharBasicViewDelegate: VDChartViewDelegate {}

public protocol VDStockCharBasicViewDataSource: VDKLineChartRendererDataSource, VDTimeLineChartRendererDataSource {}

public class VDStockCharBasicView: UIView {
    weak var delegate: VDStockCharBasicViewDelegate? = nil
    var dataSource: VDStockCharBasicViewDataSource? = nil
    
//    var kLineNodes = [KlineNode]()
//    var timeLineNodes = [TimeLineNode]()
    var klineRenderer: VDChartRenderer!
    var timeLineRenderer: VDChartRenderer!
    var chartView: VDChartView!
    var priceView: VDChartPriceView!
    
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
    
    private func initSubviews() {
        let tabView = VDTabView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        tabView.titles = ["分时", "日K", "周K", "月K"]
        tabView.isScrollEnabled = false
        tabView.didTapTabLabel = { index in
            if index == 0 {
                self.chartView.renderer = self.timeLineRenderer
//                self.priceView.titles = ["开", "高", "幅", "成交"]
            }
            else {
                self.chartView.renderer = self.klineRenderer
                self.priceView.titles = ["开", "高", "幅", "", "收", "低", "量", "额"]
            }
        }
        addSubview(tabView)
        
        chartView = VDChartView(frame: CGRect(x: 0, y: 30, width: UIScreen.main.bounds.size.width, height: frame.size.height - 30))
        chartView.delegate = self
        chartView.backgroundColor = UIColor.white
        klineRenderer = VDKLineChartRenderer(container: chartView, dataSource: self)
        timeLineRenderer = VDTimeChartLineRenderer(container: chartView, dataSource: self)
        chartView.renderer = timeLineRenderer
        addSubview(chartView)
        
        priceView = VDChartPriceView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: tabView.bounds.size.height))
        priceView.titles = ["开", "高", "幅", "成交"]
        priceView.backgroundColor = UIColor.white
        priceView.isHidden = true
        addSubview(priceView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VDStockCharBasicView: VDChartViewDelegate {
    public func chartViewDidTouchTarget(_ chartView: VDChartView, touchPoint: CGPoint, nodeIndex: Int) {
        
        if chartView.renderer is VDKLineChartRenderer {
            priceView.isHidden = false
            let nodeData = klineChartRenderer(klineRenderer as! VDKLineChartRenderer, nodeAt: nodeIndex)
            let strArr = [String(format: "%.2f", nodeData.open), String(format: "%.2f", nodeData.high), String(format: "%.2f", nodeData.open), String(format: "%@手", VDStockDataHandle.converNumberToString(number: nodeData.businessAmount)), String(format: "%.2f", nodeData.close), String(format: "%.2f", nodeData.low), String(format: "%.2f", nodeData.open), String(format: "%.2f%%", nodeData.open)]
            priceView.nodeData = strArr
        }
    }
    
    public func chartViewDidCancelTouchTarget(_ chartView: VDChartView) {
        priceView.isHidden = true
    }
}

extension VDStockCharBasicView: VDKLineChartRendererDataSource {
    public func numberOfNodes(in renderer: VDKLineChartRenderer) -> Int {
        return dataSource?.numberOfNodes(in: renderer) ?? 0
    }
    
    public func klineChartRenderer(_ renderer: VDKLineChartRenderer, nodeAt index: Int) -> KlineNode {
        return dataSource?.klineChartRenderer(renderer, nodeAt: index) ?? KlineNode()
    }
    
    public func klineChartRenderer(_ renderer: VDKLineChartRenderer, xAxisTextAt index: Int) -> String? {
        return dataSource?.klineChartRenderer(renderer, xAxisTextAt: index)
    }
}

extension VDStockCharBasicView: VDStockCharBasicViewDataSource {
    public func numberOfNodes(in renderer: VDTimeChartLineRenderer) -> Int {
        return dataSource?.numberOfNodes(in: renderer) ?? 0
    }
    
    public func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, nodeAt index: Int) -> TimeLineNode {
        return dataSource?.timeLineChartRenderer(renderer, nodeAt: index) ?? TimeLineNode()
    }
    
    public func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, xAxisTextAt index: Int) -> String? {
        return dataSource?.timeLineChartRenderer(renderer, xAxisTextAt: index)
    }
    
    public func yesterdayClosePrice(in renderer: VDTimeChartLineRenderer) -> Float {
        return dataSource?.yesterdayClosePrice(in: renderer) ?? 0
    }
}
