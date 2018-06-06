//
//  StockDealInfoView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/30.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class StockDealInfoView: UIView {

    var labels = [UILabel]()
    
    let tabView = VDTabView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let leftText = NSMutableAttributedString(string: "买1", attributes: [.foregroundColor:UIColor.black, .font:UIFont.systemFont(ofSize: 10)])
        let centerText = NSAttributedString(string: "8.88", attributes: [.foregroundColor:UIColor.green, .font:UIFont.systemFont(ofSize: 10)])
        let rightText = NSAttributedString(string: "8888", attributes: [.foregroundColor:UIColor.black, .font:UIFont.systemFont(ofSize: 10)])
        
        for i in 0..<10 {
            let labelLeft = UILabel()
            labelLeft.layer.borderWidth = 0.5
            labelLeft.layer.borderColor = UIColor.green.cgColor
            labelLeft.attributedText = leftText
            labelLeft.textAlignment = .left
            addSubview(labelLeft)
            
            let labelCenter = UILabel()
            labelCenter.layer.borderWidth = 0.5
            labelCenter.layer.borderColor = UIColor.green.cgColor
            labelCenter.attributedText = centerText
            labelCenter.textAlignment = .center
            labelCenter.tag = i
            labels.append(labelCenter)
            addSubview(labelCenter)
            
            let labelRight = UILabel()
            labelRight.layer.borderWidth = 0.5
            labelRight.layer.borderColor = UIColor.green.cgColor
            labelRight.attributedText = rightText
            labelRight.textAlignment = .right
            addSubview(labelRight)
        }
        
        //Tab
        tabView.isScrollEnabled = false
        tabView.didTapTabLabel = {
            print($0)
        }
        addSubview(tabView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let itemHeight = (frame.height - 30) / 10
        subviews.enumerated().forEach { (index, label) in
            guard let label : UILabel = label as? UILabel else { return }
            label.frame = CGRect(x: 0, y: CGFloat(index / 3) * itemHeight, width: frame.width, height: itemHeight)
        }
        
        tabView.frame = CGRect(x: 0, y: frame.height - 30, width: frame.width, height: 30)
        tabView.titles = ["五档", "明细", "大单"]
    }
}
