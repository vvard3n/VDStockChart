//
//  VDStockDataHandle.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

public class VDStockDataHandle {
    /// 统计节点信息
    public static func calculate(_ nodes: [KlineNode]) -> KlineCalculateResult {
        var minPrice = Float.greatestFiniteMagnitude
        var maxPrice = -Float.greatestFiniteMagnitude
        var maxHigh = -Float.greatestFiniteMagnitude
        var minLow = Float.greatestFiniteMagnitude
        var maxBusinessAmount = -Float.greatestFiniteMagnitude
        var minBusinessAmount = Float.greatestFiniteMagnitude
        var maxMACD = -Double.greatestFiniteMagnitude
        var minMACD = Double.greatestFiniteMagnitude
        var minKDJ = Double.greatestFiniteMagnitude
        var maxKDJ = -Double.greatestFiniteMagnitude
        var maxWR = -Double.greatestFiniteMagnitude
        var minWR = Double.greatestFiniteMagnitude
        var minRSI = Double.greatestFiniteMagnitude
        var maxRSI = -Double.greatestFiniteMagnitude
        nodes.forEach {
            minLow = Swift.min(minLow, $0.low)
            maxHigh = Swift.max(maxHigh, $0.high)
            minPrice = min(minPrice, $0.low, $0.MA5, $0.MA10, $0.MA30)
            maxPrice = max(maxPrice, $0.high, $0.MA5, $0.MA10, $0.MA30)
            minBusinessAmount = Swift.min(minBusinessAmount, $0.businessAmount)
            maxBusinessAmount = Swift.max(maxBusinessAmount, $0.businessAmount)
            minMACD = min(minMACD, $0.DIFF, $0.DEA, $0.MACD)
            maxMACD = max(maxMACD, $0.DIFF, $0.DEA, $0.MACD)
            minKDJ = min(minKDJ, $0.K, $0.D, $0.J)
            maxKDJ = max(maxKDJ, $0.K, $0.D, $0.J)
            minWR = Swift.min(minWR, $0.WR)
            maxWR = Swift.max(maxWR, $0.WR)
            minRSI = min(minRSI, $0.RSI6, $0.RSI12, $0.RSI24)
            maxRSI = max(maxRSI, $0.RSI6, $0.RSI12, $0.RSI24)
        }
        
        return KlineCalculateResult(minPrice: minPrice, maxPrice: maxPrice, minLow: minLow, maxHigh: maxHigh, maxBusinessAmount: maxBusinessAmount, minBusinessAmount: minBusinessAmount, minMACD: minMACD, maxMACD: maxMACD, minKDJ: minKDJ, maxKDJ: maxKDJ, minWR: minWR, maxWR: maxWR, minRSI: minRSI, maxRSI: maxRSI)
    }
    
    public static func calculate(_ nodes: [TimeLineNode]) -> TimeLineCalculateResult {
        var minPrice = Float.greatestFiniteMagnitude
        var maxPrice = -Float.greatestFiniteMagnitude
        var minBusinessAmount = Float.greatestFiniteMagnitude
        var maxBusinessAmount = -Float.greatestFiniteMagnitude
        nodes.forEach {
            minPrice = Swift.min(minPrice, $0.price)
            maxPrice = Swift.max(maxPrice, $0.price)
            minBusinessAmount = Swift.min(minBusinessAmount, $0.businessAmount)
            maxBusinessAmount = Swift.max(maxBusinessAmount, $0.businessAmount)
        }
        
        return TimeLineCalculateResult(minPrice: minPrice, maxPrice: maxPrice, maxBusinessAmount: maxBusinessAmount, minBusinessAmount: minBusinessAmount)
    }
    
    public static func calculateIndicator(_ nodes: [KlineNode]) {
        nodes.enumerated().forEach { index, node in
            node.MA5 = MA(5, currentIndex: index, in: nodes)
            node.MA10 = MA(10, currentIndex: index, in: nodes)
            node.MA30 = MA(30, currentIndex: index, in: nodes)
            
            if index > 0 {
                let yesterdayEMA1 = nodes[index - 1].EMA1 == 0 ? Double(nodes[index - 1].close) : nodes[index - 1].EMA1
                let yesterdayEMA2 = nodes[index - 1].EMA2 == 0 ? Double(nodes[index - 1].close) : nodes[index - 1].EMA2
                node.EMA1 = EMA(12, close: node.close, yesterdayEMA: yesterdayEMA1)
                node.EMA2 = EMA(26, close: node.close, yesterdayEMA: yesterdayEMA2)
                node.DIFF = node.EMA1 - node.EMA2
                node.DEA = nodes[index - 1].DEA * 8 / 10 + node.DIFF * 2 / 10
                node.MACD = (node.DIFF - node.DEA) * 2
            }
            
            (node.K, node.D, node.J) = KDJ(currentIndex: index, in: nodes)
            node.WR = WR(14, currentIndex: index, in: nodes)
            node.RSI6 = RSI(6, currentIndex: index, in: nodes)
            //            node.RSI12 = RSI(12, currentIndex: index, in: nodes)
            //            node.RSI24 = RSI(24, currentIndex: index, in: nodes)
        }
    }
    
    public static func calculateAvgTimeLine(_ nodes: [TimeLineNode]) {
        var priceSum: Float = 0
        var volumeSum: Float = 0
        nodes.enumerated().forEach { index, node in
            priceSum += node.price * node.businessAmount
            volumeSum += node.businessAmount
            node.avgPrice = priceSum / volumeSum
            print("priceSum: \(priceSum) volumeSum:\(volumeSum) avgPrice:\(node.avgPrice)")
        }
    }
    
    static func converNumberToString(number: Float) -> String {
        if number >= 10000 && number < 100000000  {
            return String(format: "%.2f万", number / 10000)
        }
        if number >= 100000000 && number < 1000000000000 {
            return String(format: "%.2f亿", number / 100000000)
        }
        if number >= 1000000000000 {
            return String(format: "%.2f万亿", number / 1000000000000)
        }
        return "\(number)"
    }
    
    private static func KDJ(currentIndex: Int, in nodes: [KlineNode]) -> (K: Double, D: Double, J: Double) {
        if currentIndex == 0 { return (K: 100, D: 100, J: 100) }
        let startIndex = Swift.max(currentIndex - 9 + 1, 0)
        var maxHigh = -Float.greatestFiniteMagnitude
        var minLow = Float.greatestFiniteMagnitude
        for i in startIndex...currentIndex {
            maxHigh = Swift.max(maxHigh, nodes[i].high)
            minLow = Swift.min(minLow, nodes[i].low)
        }
        let rsv = Double(nodes[currentIndex].close - minLow) / Double(maxHigh - minLow) * 100
        let K = 2 / 3 * nodes[currentIndex - 1].K + 1 / 3 * rsv
        let D = 2 / 3 * nodes[currentIndex - 1].D + 1 / 3 * K
        let J = 3 * K - 2 * D
        return (K, D, J)
    }
    
    private static func RSI(_ days: Int, currentIndex: Int, in nodes: [KlineNode]) -> Double {
        if currentIndex + 1 - days < 0 { return 100 }
        let startIndex = currentIndex - days + 1
        var sumIncrease: Double = 0
        var sumDecrease: Double = 0
        for i in (startIndex + 1)...currentIndex {
            //            sumIncrease += Double(nodes[i].close - nodes[i - 1].close)
            //            sumDecrease += Double(abs(nodes[i].close - nodes[i - 1].close))
            
            if nodes[i].close >= nodes[i - 1].close {
                sumIncrease += Double(nodes[i].close - nodes[i - 1].close)
            } else {
                sumDecrease += Double(nodes[i - 1].close - nodes[i].close)
            }
        }
        ////        sumDecrease += 20.56
        //
        ////        if nodes[currentIndex].close >= nodes[currentIndex - 1].close {
        ////            sumIncrease = sumIncrease * 5 / 6 + Double(nodes[currentIndex].close - nodes[currentIndex - 1].close) / 6
        ////        } else {
        ////            sumDecrease = sumDecrease * 5 / 6 + Double(nodes[currentIndex - 1].close - nodes[currentIndex].close) / 6
        ////        }
        ////
        //
        ////        print(sumIncrease, sumDecrease)
        ////        sumIncrease = sumIncrease / Double(days)
        ////        sumDecrease = sumDecrease  / Double(days)
        //        sumIncrease += -20.56
        sumDecrease += 20.56
        //        print(sumIncrease, sumDecrease)
        //        let rs = sumDecrease == 0 ? 0 : sumIncrease / sumDecrease
        return sumIncrease / (sumIncrease + sumDecrease) * 100 //100 - 100 / (1 + rs) //rs / (1 + rs) * 100
    }
    
    private static func WR(_ days: Int, currentIndex: Int, in nodes: [KlineNode]) -> Double {
        if currentIndex + 1 - days < 0 { return 0 }
        let startIndex = currentIndex - days + 1
        var maxHigh = -Float.greatestFiniteMagnitude
        var minLow = Float.greatestFiniteMagnitude
        for i in startIndex...currentIndex {
            maxHigh = Swift.max(maxHigh, nodes[i].high)
            minLow = Swift.min(minLow, nodes[i].low)
        }
        return Double(maxHigh - nodes[currentIndex].close) / Double(maxHigh - minLow) * 100
    }
    
    private static func min(_ numbers: Float...) -> Float {
        var number = Float.greatestFiniteMagnitude
        numbers.forEach { if $0 > 0 && number > $0 { number = $0 } }
        return number
    }
    
    private static func max(_ numbers: Float...) -> Float {
        var number = -Float.greatestFiniteMagnitude
        numbers.forEach { if number < $0 { number = $0 } }
        return number
    }
    
    private static func min(_ numbers: Double...) -> Double {
        var number = Double.greatestFiniteMagnitude
        numbers.forEach { if number > $0 { number = $0 } }
        return number
    }
    
    private static func max(_ numbers: Double...) -> Double {
        var number = -Double.greatestFiniteMagnitude
        numbers.forEach { if number < $0 { number = $0 } }
        return number
    }
    
    private static func MA(_ days: Int, currentIndex: Int, in nodes: [KlineNode]) -> Float {
        if currentIndex < days - 1 { return 0 }
        
        let sum = ((currentIndex + 1 - days)...currentIndex).reduce(0) {
            return $0 + nodes[$1].close
        }
        return sum / Float(days)
    }
    
    private static func EMA(_ days: Int, close: Float, yesterdayEMA: Double) -> Double {
        let a = 2 / Double(days + 1)
        return a * Double(close) + (1 - a) * yesterdayEMA
    }
}

public struct KlineCalculateResult {
    /// 节点中最低价格
    let minPrice: Float
    /// 节点中最高价格
    let maxPrice: Float
    let minLow: Float
    let maxHigh: Float
    /// 最高成交量
    let maxBusinessAmount: Float
    let minBusinessAmount: Float
    /// MACD指标最小值
    let minMACD: Double
    /// MACD指标最大值
    let maxMACD: Double
    
    /// KDJ指标
    let minKDJ: Double
    let maxKDJ: Double
    
    /// WR指标
    let minWR: Double
    let maxWR: Double
    
    let minRSI: Double
    let maxRSI: Double
}

public struct TimeLineCalculateResult {
    /// 节点中最低价格
    let minPrice: Float
    /// 节点中最高价格
    let maxPrice: Float
    /// 最高成交量
    let maxBusinessAmount: Float
    let minBusinessAmount: Float
}

public class KlineNode {
    /// 时间
    public var time = ""
    /// 最高价格
    public var high: Float = 0
    /// 最低价格
    public var low: Float = 0
    /// 开盘价
    public var open: Float = 0
    /// 收盘价
    public var close: Float = 0
    /// 成交量
    public var businessAmount: Float = 0
    /// 振幅
    public var amplitude: Float = -Float.greatestFiniteMagnitude
    /// 换手率
    public var turnoverRate: Float = -Float.greatestFiniteMagnitude
    
    /// 五日均价
    public var MA5: Float = 0
    /// 十日均价
    public var MA10: Float = 0
    /// 三十日均价
    public var MA30: Float = 0
    
    /// EMA12
    public var EMA1: Double = 0
    /// EMA26
    public var EMA2: Double = 0
    public var DIFF: Double = 0
    public var DEA: Double = 0
    public var MACD: Double = 0
    
    /// KDJ
    public var K: Double = 0
    public var D: Double = 0
    public var J: Double = 0
    
    /// WR
    public var WR: Double = 0
    
    /// RSI指标
    public var RSI6: Double = 0
    public var RSI12: Double = 0
    public var RSI24: Double = 0
    
    public var isIncrease: Bool { return close >= open }
    
    public init() { }
}

public class TimeLineNode {
    /// 昨收
    public var closePrice: Float = 0
    /// 前一个节点的价格（如果是第一个节点，使用昨收价）
    public var beforeNode: TimeLineNode?
    /// 时间
    public var time = ""
    /// 分时均价
    public var avgPrice: Float = 0
    /// 价格
    public var price: Float = 0
    /// 成交量
    public var businessAmount: Float = 0
    
    /// 涨 跌
    public var isIncrease: Bool {
        if let beforeNode = beforeNode {
            if price > beforeNode.price {
                return true
            }
            else if price == beforeNode.price {
                return beforeNode.isIncrease
            }
            else {
                return false
            }
        }
        else {
            return price >= closePrice
        }
    }
    
    public init() { }
}
