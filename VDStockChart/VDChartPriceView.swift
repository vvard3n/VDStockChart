//
//  VDChartPriceView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/6/5.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

private let titleLblWidth: CGFloat = 25
private let rowCount: Int = 2
private let locCount: Int = 4

public class VDChartPriceView: UIView {
    
    var titles: [String] = [] { //["开", "高", "幅", "成交", "收", "低", "额", "振幅"]
        didSet {
            setupSubviews()
        }
    }
    
    var lbls: [UILabel] = []
    
    var nodeData: [String]? = nil {
        didSet {
            guard let nodeData = nodeData else {
                return
            }
            for i in 0..<nodeData.count {
                lbls[i].text = nodeData[i]
            }
        }
    }
    
//    var nodeData: TimeLineNode? = nil {
//        didSet {
//            lbls[0].text = String(format: "%.2f", nodeData.open)
//            lbls[1].text = String(format: "%.2f", nodeData.high)
//            lbls[2].text = String(format: "%.2f", nodeData.open)
//            lbls[3].text = String(format: "%@手", VDStockDataHandle.converNumberToString(number: nodeData.businessAmount))
//        }
//    }
    
    func setupSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
        lbls.removeAll()
        
        let width = (frame.size.width - CGFloat(locCount) * titleLblWidth) / CGFloat(locCount)
        let height = frame.size.height / 2
        
//        let lblCount = rowCount * locCount
        for i in 0..<titles.count {
            let titleLabel = UILabel()
            titleLabel.font = UIFont.systemFont(ofSize: 10)
            titleLabel.textColor = UIColor.black
            titleLabel.text = titles[i]
            
            let infoLbl = UILabel()
            infoLbl.font = UIFont.systemFont(ofSize: 10)
            infoLbl.textColor = UIColor.black
            infoLbl.text = "\(arc4random() % 1000)"
            lbls.append(infoLbl)
            
            let row = CGFloat(i / locCount)
            let loc = CGFloat(i % locCount)
            let x = (titleLblWidth + width) * loc
            let y = row * height
            titleLabel.frame = CGRect(x: x, y: y, width: titleLblWidth, height: height)
            infoLbl.frame = CGRect(x: x + titleLblWidth, y: y, width: width, height: height)
            addSubview(titleLabel)
            addSubview(infoLbl)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
