//
//  VDChartContainer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

public protocol VDChartContainer {
    var bounds: CGRect { get }
    var offsetX: CGFloat { get set }
    var scale: CGFloat { get }
}
