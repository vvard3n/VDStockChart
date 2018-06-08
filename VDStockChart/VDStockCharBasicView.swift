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
    var delegate: VDStockCharBasicViewDelegate? = nil
    var dataSource: VDStockCharBasicViewDataSource? = nil
    
    var kLineNodes = [KlineNode]()
    var timeLineNodes = [TimeLineNode]()
    var klineRenderer: VDChartRenderer!
    var timeLineRenderer: VDChartRenderer!
    var chartView: VDChartView!
    var priceView: VDChartPriceView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSubviews()
    }
    
    init(frame: CGRect, dataSource: VDStockCharBasicViewDataSource, delegate: VDStockCharBasicViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.dataSource = dataSource
        initSubviews()
    }
    
    private func initSubviews() {
        let tabView = VDTabView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        tabView.titles = ["分时", "五日", "日K", "周K", "月K", "季K", "年K", "分钟"]
        tabView.isScrollEnabled = false
        tabView.didTapTabLabel = { index in
            if index == 0 {
                self.chartView.renderer = self.timeLineRenderer
                self.priceView.titles = ["开", "高", "幅", "成交"]
            }
            else if index == 1 {
                self.chartView.renderer = self.klineRenderer
                self.priceView.titles = ["开", "高", "幅", "成交", "收", "低", "额", "振幅"]
            }
            else {
                self.chartView.renderer = self.klineRenderer
                self.priceView.titles = ["开", "高", "幅", "成交", "收", "低", "额", "振幅"]
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
        
        priceView = VDChartPriceView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
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
        delegate?.chartViewDidTouchTarget(chartView, touchPoint: touchPoint, nodeIndex: nodeIndex)
    }
    
    public func chartViewDidCancelTouchTarget(_ chartView: VDChartView) {
        delegate?.chartViewDidCancelTouchTarget(chartView)
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
