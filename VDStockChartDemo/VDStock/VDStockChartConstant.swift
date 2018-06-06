//
//  VDStockChartConstant.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

/// K线最小厚度
let VDStockChartLineMinThick : Float = 0.5
let VDStockChartLineMaxWidth : Float = 20
let VDStockChartLineMinWidth : Float = 3
let VDStockChartTimeLineWidth : Float = 1
let VDStockChartShadowLineWidth : Float = 1.2
let VDStockChartMALineWidth : Float = 1.2
let VDStockChartPointRadius : Float = 3
let VDStockChartMainViewMinY : Float = 2
let VDStockChartVolumeViewMinY : Float = 2
let VDStockChartDayHeight : Float = 20
let VDStockChartTopBarViewHeight : Float = 40
let VDStockChartTopBarViewWidth : Float = 94
let VDStockChartViewGap : Float = 1
let VDStockChartFiveRecordViewWidth : Float = 95
let VDStockChartFiveRecordViewHeight : Float = 175
let VDStockChartScaleBound : Float = 0.03
let VDStockChartScaleFactor : Float = 0.06

/// K线种类
///
/// - kLine: k线图
/// - timeLine: 分时图
/// - other: 其他
enum VDStockChartType {
    case kLine
    case timeLine
    case other
}

/// accessory指标种类
///
/// - MACD: MACD线
/// - KDJ: KDJ线
/// - accessoryClose: 关闭Accessory线
/// - MA: MA线
/// - EMA: EMA线
/// - MAClose: MA关闭线
enum VDStockChartTargetLineStatus {
    case MACD
    case KDJ
    case accessoryClose
    case MA
    case EMA
    case MAClose
}

/// iPhone设备
let isIPhone = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? true : false)
/// iPad设备
let isIPad = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? true : false)
/// iPhoneX设备
let isIPhoneX = (max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.height) == 812.0 ? true : false)

let SAFE_AREA_BOTTOM : CGFloat = isIPhoneX ? 34.0 : 0.0

let SAFE_AREA_TOP : CGFloat = isIPhoneX ? 24.0 : 0.0

let NAVIGATIONBAR_HEIGHT : CGFloat = UIApplication.shared.statusBarFrame.size.height + 44

let TABBAR_HEIGHT : CGFloat = SAFE_AREA_BOTTOM + 49

/// Get point from pixel value
///
/// - Parameter pixel: pixel value
/// - Returns: point value
func CGFloatFromPixel(pixel: CGFloat) -> CGFloat {
    return pixel / UIScreen.main.scale
}

struct ThemeColor {
    /// color F7F8FA
    static let MAIN_BACKGROUND_COLOR_F7F8FA : UIColor = #colorLiteral(red: 0.968627451, green: 0.9725490196, blue: 0.9803921569, alpha: 1)
    /// color eeeeee
    static let LIGHT_LINE_COLOR_EEEEEE : UIColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
    
    /// color 333131
    static let CONTENT_TEXT_COLOR_333131 : UIColor = #colorLiteral(red: 0.2, green: 0.1921568627, blue: 0.1921568627, alpha: 1)
    /// color 666060
    static let CONTENT_TEXT_COLOR_666060 : UIColor = #colorLiteral(red: 0.4, green: 0.3764705882, blue: 0.3764705882, alpha: 1)
    /// color 999090
    static let CONTENT_TEXT_COLOR_999090 : UIColor = #colorLiteral(red: 0.6, green: 0.5647058824, blue: 0.5647058824, alpha: 1)
    
    /// color 0EAE4E
    static let STOCK_DOWN_GREEN_COLOR_0EAE4E : UIColor = #colorLiteral(red: 0.05490196078, green: 0.6823529412, blue: 0.3058823529, alpha: 1)
    /// color E55C5C
    static let STOCK_UP_RED_COLOR_E55C5C : UIColor = #colorLiteral(red: 0.8980392157, green: 0.3607843137, blue: 0.3607843137, alpha: 1)
    
    /// color E63130
    static let MAIN_COLOR_E63130 : UIColor = #colorLiteral(red: 0.9019607843, green: 0.1921568627, blue: 0.1882352941, alpha: 1)
    /// color DBDBDB
    static let GRAY_COLOR_DBDBDB : UIColor = #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8588235294, alpha: 1)
}
