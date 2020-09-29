//
//  ViewController.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit
import VDStockChart

class ViewController: UIViewController {
    
    var kLineNodes = [KlineNode]()
    var timeLineNodes = [TimeLineNode]()
    var klineRenderer: VDChartRenderer!
    var timeLineRenderer: VDChartRenderer!
    var chartView: VDChartView!
    var priceView: VDChartPriceView!
    var stockView: VDStockCharBasicView!
    
    var rehabilitationType = ["none", "before", "behind"]
    var selectedRehabilitationType: Int = 0
    var closePrice: Double? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
//        let tabView = VDTabView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.size.width, height: 30))
//        tabView.titles = ["分时", "日K", "周K", "月K"]
//        tabView.isScrollEnabled = false
//        tabView.didTapTabLabel = { index in
//            if index == 0 {
//                self.chartView.renderer = self.timeLineRenderer
//                self.priceView.titles = ["开", "高", "幅", "成交"]
//            }
//            else if index == 1 {
//                self.chartView.renderer = self.klineRenderer
//                self.priceView.titles = ["开", "高", "幅", "成交", "收", "低", "额", "振幅"]
//            }
//            else {
//                self.chartView.renderer = self.klineRenderer
//                self.priceView.titles = ["开", "高", "幅", "成交", "收", "低", "额", "振幅"]
//            }
//        }
//        view.addSubview(tabView)
        
        loadKLineData(filename: "day_kline.json")
        loadTimeLineData(filename: "timeline.json")
//        chartView = VDChartView(frame: CGRect(x: 0, y: 80, width: UIScreen.main.bounds.size.width, height: 300))
//        chartView.delegate = self
//        chartView.backgroundColor = UIColor.white
//        klineRenderer = VDKLineChartRenderer(container: chartView, dataSource: self)
//        timeLineRenderer = VDTimeChartLineRenderer(container: chartView, dataSource: self)
////        chartView.renderer = klineRenderer
//        chartView.renderer = timeLineRenderer
//        view.addSubview(chartView)
        
        priceView = VDChartPriceView(frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.size.width, height: 44))
        priceView.titles = ["开", "高", "幅", "成交"]
        priceView.backgroundColor = UIColor.white
        priceView.isHidden = true
        view.addSubview(priceView)
        
        stockView = VDStockCharBasicView(frame: CGRect(x: 0, y: 200, width: UIScreen.main.bounds.size.width, height: 330), dataSource: self, delegate: self)
        stockView.delegate = self
        view.addSubview(stockView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadKLineData(filename: String) {
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: filename, ofType: nil)!))
        let json = try! JSON(data: jsonData)
        kLineNodes = json["data"]["k_data"].map { key, json -> KlineNode in
            let node = KlineNode()
            node.time = json[0].stringValue
            node.open = json[1].floatValue
            node.close = json[2].floatValue
            node.high = json[3].floatValue
            node.low = json[4].floatValue
            node.businessAmount = json[5].floatValue
            return node
        }
        
        VDStockDataHandle.calculateIndicator(kLineNodes)
    }
    
    func loadTimeLineData(filename: String) {
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: filename, ofType: nil)!))
        let json = try! JSON(data: jsonData)
//        var beforeNode =
        var nodes: [TimeLineNode] = []
        for i in 0..<json["data"]["line"].count {
            let json = json["data"]["line"][i]
            let value = json.stringValue.split(separator: " ")
            let node = TimeLineNode()
            node.time = String(value[0])
            node.price = Float(value[1]) ?? 0
            node.businessAmount = Float(value[2]) ?? 0
            if i == 0 {
                node.closePrice = 1000
            }
            else {
                node.beforeNode = nodes[i - 1]
            }
            nodes.append(node)
        }
        timeLineNodes = nodes
//        timeLineNodes = json["data"]["line"].map({ key, json -> TimeLineNode in
//            let value = json.stringValue.split(separator: " ")
//            let node = TimeLineNode()
//            node.time = String(value[0])
//            node.price = Float(value[1]) ?? 0
//            node.businessAmount = Float(value[2]) ?? 0
//            return node
//        })
        
        VDStockDataHandle.calculateAvgTimeLine(timeLineNodes)
    }
}

//extension ViewController: VDChartViewDelegate {
//    func chartViewDidTouchTarget(_ chartView: VDChartView, touchPoint: CGPoint, nodeIndex: Int) {
////        priceView.isHidden = false
////
////        if chartView.renderer is VDKLineChartRenderer {
////            let nodeData = kLineNodes[nodeIndex]
////            let strArr = [String(format: "%.2f", nodeData.open), String(format: "%.2f", nodeData.high), String(format: "%.2f", nodeData.open), String(format: "%@手", VDStockDataHandle.converNumberToString(number: nodeData.businessAmount)), String(format: "%.2f", nodeData.close), String(format: "%.2f", nodeData.low), String(format: "%.2f", nodeData.open), String(format: "%.2f%%", nodeData.open)]
////            priceView.nodeData = strArr
////        }
////        if chartView.renderer is VDTimeChartLineRenderer {
////            let nodeData = timeLineNodes[nodeIndex]
////            let strArr = [String(format: "%@", nodeData.time), String(format: "%.2f", nodeData.avgPrice), String(format: "%.2f", nodeData.price), String(format: "%.2f手", nodeData.businessAmount)]
////            priceView.nodeData = strArr
////        }
//    }
//
//    func chartViewDidCancelTouchTarget(_ chartView: VDChartView) {
////        priceView.isHidden = true
//    }
//}
//
//extension ViewController: VDKLineChartRendererDataSource {
//    func sharesPerHand(in renderer: VDKLineChartRenderer) -> Int {
//        return 100;
//    }
//
//    func numberOfNodes(in renderer: VDKLineChartRenderer) -> Int {
//        return kLineNodes.count
//    }
//
//    func klineChartRenderer(_ renderer: VDKLineChartRenderer, nodeAt index: Int) -> KlineNode {
//        return kLineNodes[index]
//    }
//
//    func klineChartRenderer(_ renderer: VDKLineChartRenderer, xAxisTextAt index: Int) -> String? {
//        let node = kLineNodes[index]
//        let str1 = node.time[..<node.time.index(node.time.startIndex, offsetBy: 6)]
//        if index - 1 < 0 { return String(str1) }
//
//        let preNode = kLineNodes[index - 1]
//        let str2 = preNode.time[..<preNode.time.index(preNode.time.startIndex, offsetBy: 6)]
//        if str1 != str2 { return String(str1) }
//
//        return nil
//    }
//}
//
//extension ViewController: VDTimeLineChartRendererDataSource {
//    func sharesPerHand(in renderer: VDTimeChartLineRenderer) -> Int {
//        return 100;
//    }
//
//    func numberOfNodes(in renderer: VDTimeChartLineRenderer) -> Int {
//        return timeLineNodes.count
//    }
//
//    func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, nodeAt index: Int) -> TimeLineNode {
//        return timeLineNodes[index]
//    }
//
//    func timeLineChartRenderer(_ renderer: VDTimeChartLineRenderer, xAxisTextAt index: Int) -> String? {
//        let node = timeLineNodes[index]
//        let str1 = node.time[..<node.time.index(node.time.startIndex, offsetBy: 6)]
//        if index - 1 < 0 { return String(str1) }
//
//        let preNode = timeLineNodes[index - 1]
//        let str2 = preNode.time[..<preNode.time.index(preNode.time.startIndex, offsetBy: 6)]
//        if str1 != str2 { return String(str1) }
//
//        return nil
//    }
//
//    func yesterdayClosePrice(in renderer: VDTimeChartLineRenderer) -> Float {
//        return 3190.32
//    }
//}

extension ViewController: VDStockCharBasicViewDelegate, VDStockCharBasicViewDataSource {
    func chartViewDidChangeTab(index: Int) {
        stockView.reloadData()
    }
    
    func sharesPerHand(in renderer: Any) -> Int {
        return 100
    }
    
    func chartViewDidClickRehabilitationBtn(_ chartView: VDChartView, sender: UIButton, currentStatus: Int) {
        //        self.showActivityMsg(in: self.view, text: "")
        if currentStatus == 0 {
            sender.setTitle("前复权", for: .normal)
            sender.tag = 1
            selectedRehabilitationType = 1
        }
        else if currentStatus == 1 {
            sender.setTitle("后复权", for: .normal)
            sender.tag = 2
            selectedRehabilitationType = 2
        }
        else {
            sender.setTitle("不复权", for: .normal)
            sender.tag = 0
            selectedRehabilitationType = 0
        }
        
        stockView.reloadData()
    }
    
    func tradingData(type: StockChartRendererType) -> StockDealInfoViewModel? {
        return nil
    }
    
    func numberOfNodes(type: StockChartRendererType) -> Int {
        if type == .timeline {
            return timeLineNodes.count
        }
        if type == .day {
            return kLineNodes.count
        }
        if type == .week {
            return kLineNodes.count
        }
        if type == .month {
            return kLineNodes.count
        }
        if type == .year {
            return kLineNodes.count
        }
        return 0
    }
    
    func stockChartRenderer(type: StockChartRendererType, nodeAt index: Int) -> Any {
        if type == .timeline {
            return timeLineNodes[index]
        }
        if type == .day {
            return kLineNodes[index]
        }
        if type == .week {
            return kLineNodes[index]
        }
        if type == .month {
            return kLineNodes[index]
        }
        if type == .year {
            return kLineNodes[index]
        }
        return timeLineNodes[index]
    }
    
    func stockChartRenderer(type: StockChartRendererType, xAxisTextAt index: Int) -> String? {
        if type == .timeline {
            let node = timeLineNodes[index]
            let str1 = node.time[..<node.time.index(node.time.startIndex, offsetBy: 6)]
            //            let str1 = node.time
            if index - 1 < 0 { return String(str1) }
            
            let preNode = timeLineNodes[index - 1]
            let str2 = preNode.time[..<preNode.time.index(preNode.time.startIndex, offsetBy: 6)]
            //            let str2 = preNode.time
            if str1 != str2 { return String(str1) }
            
            return nil
        }
        if type == .day {
            let node = kLineNodes[index]
            let str1 = node.time[..<node.time.index(node.time.startIndex, offsetBy: 6)]
            if index - 1 < 0 { return String(str1) }
            
            let preNode = kLineNodes[index - 1]
            let str2 = preNode.time[..<preNode.time.index(preNode.time.startIndex, offsetBy: 6)]
            if str1 != str2 { return String(str1) }
            
            return nil
        }
        if type == .week {
            let node = kLineNodes[index]
            let str1 = node.time[..<node.time.index(node.time.startIndex, offsetBy: 6)]
            if index - 1 < 0 { return String(str1) }
            
            let preNode = kLineNodes[index - 1]
            let str2 = preNode.time[..<preNode.time.index(preNode.time.startIndex, offsetBy: 6)]
            if str1 != str2 { return String(str1) }
            
            return nil
        }
        if type == .month {
            let node = kLineNodes[index]
            let str1 = node.time[..<node.time.index(node.time.startIndex, offsetBy: 6)]
            if index - 1 < 0 { return String(str1) }
            
            let preNode = kLineNodes[index - 1]
            let str2 = preNode.time[..<preNode.time.index(preNode.time.startIndex, offsetBy: 6)]
            if str1 != str2 { return String(str1) }
            
            return nil
        }
        if type == .year {
            let node = kLineNodes[index]
            let str1 = node.time[..<node.time.index(node.time.startIndex, offsetBy: 6)]
            if index - 1 < 0 { return String(str1) }
            
            let preNode = kLineNodes[index - 1]
            let str2 = preNode.time[..<preNode.time.index(preNode.time.startIndex, offsetBy: 6)]
            if str1 != str2 { return String(str1) }
            
            return nil
        }
        return nil
    }
    
    func chartViewDidTouchTarget(_ chartView: VDChartView, touchPoint: CGPoint, nodeIndex: Int) {
        
    }
    
    func chartViewDidCancelTouchTarget(_ chartView: VDChartView) {
        
    }
    
    func yesterdayClosePrice(in renderer: VDTimeChartLineRenderer) -> Float {
        closePrice = 123;
        return Float(closePrice ?? 0)
    }
}
