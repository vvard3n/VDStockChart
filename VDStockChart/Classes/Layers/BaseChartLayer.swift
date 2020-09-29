//
//  BaseChartLayer.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/28.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class BaseChartLayer: CALayer {
    override init() {
        super.init()
        masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        masksToBounds = true
    }
    
    func clear() {
        guard let sublayers = self.sublayers else { return }
        for layer in sublayers {
            layer.removeFromSuperlayer()
        }
    }
    
    /// 关闭隐式动画
    open override func action(forKey event: String) -> CAAction? {
        return nil
    }
}
