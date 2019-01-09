//
//  StockDealInfoView.swift
//  VDStockChartDemo
//
//  Created by Harwyn T'an on 2018/5/30.
//  Copyright © 2018年 vvard3n. All rights reserved.
//

import UIKit

class StockDealInfoView: UIView {
    
    private var labels = [UILabel]()
    var sharesPerHand: Int = 100
    
    var data: StockDealInfoViewModel? = nil {
        didSet {
            guard let data = data else { return }
            for i in 0..<10 {
//                let labelLeft = labels[i * 3]
                let labelCenter = labels[i * 3 + 1]
                let labelRight = labels[i * 3 + 2]
                
                
                if i < 5 {
                    
                    var color: UIColor = ThemeColor.CONTENT_TEXT_COLOR_555555
                    if Double(data.offerGroup[i % 5].price) ?? 0 > data.closePrice {
                        color = ThemeColor.MAIN_COLOR_E63130
                    }
                    else if Double(data.offerGroup[i % 5].price) ?? 0 < data.closePrice {
                        color = ThemeColor.STOCK_DOWN_GREEN_COLOR_0EAE4E
                    }
                    
                    var centerText = NSAttributedString(string: String(format: "          %@", data.offerGroup[i % 5].price), attributes: [.foregroundColor:color, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
                    let amount = data.offerGroup[i % 5].amount / Double(sharesPerHand)
                    var amountStr = ""
                    if amount >= 10000 && amount < 100000000  {
                        amountStr = String(format: "%.2f万", amount / 10000)
                    }
                    else if amount >= 100000000 && amount < 1000000000000 {
                        amountStr = String(format: "%.2f亿", amount / 100000000)
                    }
                    else if amount >= 1000000000000 {
                        amountStr = String(format: "%.2f万亿", amount / 1000000000000)
                    }
                    else {
                        amountStr = String(format: "%.0f", amount)
                    }
                    var rightText = NSAttributedString(string: String(format: "%@", amountStr), attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
                    if data.offerGroup[i % 5].price == "0.00" && data.offerGroup[i % 5].amount == 0 {
                        centerText = NSAttributedString(string: "          --", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
                        rightText = NSAttributedString(string: "--", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
                    }
                    labelCenter.attributedText = centerText
                    labelRight.attributedText = rightText
                }
                else {
                    
                    var color: UIColor = ThemeColor.CONTENT_TEXT_COLOR_555555
                    if Double(data.bigGroup[i % 5].price) ?? 0 > data.closePrice {
                        color = ThemeColor.MAIN_COLOR_E63130
                    }
                    else if Double(data.bigGroup[i % 5].price) ?? 0 < data.closePrice {
                        color = ThemeColor.STOCK_DOWN_GREEN_COLOR_0EAE4E
                    }
                    
                    var centerText = NSAttributedString(string: String(format: "          %@", data.bigGroup[i % 5].price), attributes: [.foregroundColor:color, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
                    let amount = data.bigGroup[i % 5].amount / Double(sharesPerHand)
                    var amountStr = ""
                    if amount >= 10000 && amount < 100000000  {
                        amountStr = String(format: "%.2f万", amount / 10000)
                    }
                    else if amount >= 100000000 && amount < 1000000000000 {
                        amountStr = String(format: "%.2f亿", amount / 100000000)
                    }
                    else if amount >= 1000000000000 {
                        amountStr = String(format: "%.2f万亿", amount / 1000000000000)
                    }
                    else {
                        amountStr = String(format: "%.0f", amount)
                    }
                    var rightText = NSAttributedString(string: String(format: "%@", amountStr), attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
                    if data.bigGroup[i % 5].price == "0.00" && data.bigGroup[i % 5].amount == 0 {
                        centerText = NSAttributedString(string: "          --", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
                        rightText = NSAttributedString(string: "--", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
                    }
                    labelCenter.attributedText = centerText
                    labelRight.attributedText = rightText
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let centerText = NSAttributedString(string: "          --", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
        let rightText = NSAttributedString(string: "--", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)])
        
        for i in 0..<10 {
            let leftText = NSMutableAttributedString()
            if i < 5 {
                leftText.append(NSAttributedString(string: "卖", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)]))
                leftText.append(NSAttributedString(string: "\(5 - i)", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)]))
            }
            else {
                leftText.append(NSAttributedString(string: "买", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)]))
                leftText.append(NSAttributedString(string: "\(i - 5 + 1)", attributes: [.foregroundColor:ThemeColor.CONTENT_TEXT_COLOR_555555, .font:UIFont(name: "DIN Alternate", size: 12) ?? UIFont.systemFont(ofSize: 12)]))
            }
            let labelLeft = UILabel()
            labelLeft.attributedText = leftText
            labelLeft.textAlignment = .left
            labels.append(labelLeft)
            addSubview(labelLeft)
            
            let labelCenter = UILabel()
            labelCenter.attributedText = centerText
            labelCenter.textAlignment = .left
            labelCenter.tag = i
            labels.append(labelCenter)
            addSubview(labelCenter)
            
            let labelRight = UILabel()
            labelRight.attributedText = rightText
            labelRight.textAlignment = .right
            labels.append(labelRight)
            addSubview(labelRight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let itemHeight = frame.height / 10
        subviews.enumerated().forEach { (index, label) in
            guard let label : UILabel = label as? UILabel else { return }
            label.frame = CGRect(x: 5, y: CGFloat(index / 3) * itemHeight, width: frame.width - 5 * 2, height: itemHeight)
        }
    }
}

public class StockDealInfoViewModel: NSObject {
    public var closePrice: Double = 0
    public var offerGroup: [StockDealInfoViewItemModel] = []
    public var bigGroup: [StockDealInfoViewItemModel] = []
}

public class StockDealInfoViewItemModel: NSObject {
    public var price: String = "0.00"
    public var amount: Double = 0
}
