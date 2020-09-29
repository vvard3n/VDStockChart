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
    
    public var titles: [String] = [] { //["开", "高", "幅", "", "收", "低", "量", "额"]
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
            for i in 0..<lbls.count {
                lbls[i].text = nodeData[i]
            }
        }
    }
    
    var sharesPerHand: Int = 100
    
    var node: KlineNode? = nil {
        didSet {
            guard let node = node else { return }
            lbls[0].text = String(format: "%.2f", node.open)
            if node.open == 0 {
                lbls[0].textColor = UIColor(hex: "666060")
            }
            else if node.open > node.yesterdayClose {
                lbls[0].textColor = UIColor(hex: "E55C5C")
            }
            else if node.open == node.yesterdayClose {
                lbls[0].textColor = UIColor(hex: "666060")
            }
            else {
                lbls[0].textColor = UIColor(hex: "0EAE4E")
            }
            
            lbls[1].text = String(format: "%.2f", node.high)
            if node.high == 0 {
                lbls[1].textColor = UIColor(hex: "666060")
            }
            else if node.high > node.yesterdayClose {
                lbls[1].textColor = UIColor(hex: "E55C5C")
            }
            else if node.high == node.yesterdayClose {
                lbls[1].textColor = UIColor(hex: "666060")
            }
            else {
                lbls[1].textColor = UIColor(hex: "0EAE4E")
            }
            
            if node.changeRate > 0 {
                lbls[2].text = String(format: "+%.2f%%", node.changeRate)
                lbls[2].textColor = UIColor(hex: "E55C5C")
            }
            else if node.changeRate < 0 {
                lbls[2].text = String(format: "%.2f%%", node.changeRate)
                lbls[2].textColor = UIColor(hex: "0EAE4E")
            }
            else {
                lbls[2].text = String(format: "%.2f%%", node.changeRate)
                lbls[2].textColor = UIColor(hex: "666060")
            }
            lbls[3].text = String(format: "%@", node.time)
            lbls[4].text = String(format: "%.2f", node.close)
            if node.close == 0 {
                lbls[4].textColor = UIColor(hex: "666060")
            }
            else if node.close > node.yesterdayClose {
                lbls[4].textColor = UIColor(hex: "E55C5C")
            }
            else if node.close == node.yesterdayClose {
                lbls[4].textColor = UIColor(hex: "666060")
            }
            else {
                lbls[4].textColor = UIColor(hex: "0EAE4E")
            }
            
            lbls[5].text = String(format: "%.2f", node.low)
            if node.low == 0 {
                lbls[5].textColor = UIColor(hex: "666060")
            }
            else if node.low > node.yesterdayClose {
                lbls[5].textColor = UIColor(hex: "E55C5C")
            }
            else if node.low == node.yesterdayClose {
                lbls[5].textColor = UIColor(hex: "666060")
            }
            else {
                lbls[5].textColor = UIColor(hex: "0EAE4E")
            }
            
            lbls[6].text = String(format: "%@手", VDStockDataHandle.converNumberToString(number: node.businessAmount / Float(sharesPerHand), decimal: false))
            lbls[7].text = String(format: "%@", VDStockDataHandle.converNumberToString(number: node.businessBalance, decimal: false))
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
        
        let width = (frame.size.width - CGFloat(locCount) * titleLblWidth - 17 * 2) / CGFloat(locCount)
        let height = frame.size.height / 2
        
        //        let lblCount = rowCount * locCount
        for i in 0..<titles.count {
            let titleLabel = UILabel()
            titleLabel.font = UIFont.systemFont(ofSize: 10)
            titleLabel.textColor = UIColor(hex: "666060")
            titleLabel.text = titles[i]
            
            let infoLbl = UILabel()
            infoLbl.font = UIFont.systemFont(ofSize: 10)
            infoLbl.textColor = UIColor(hex: "666060")
            infoLbl.text = ""
            lbls.append(infoLbl)
            
            let row = CGFloat(i / locCount)
            let loc = CGFloat(i % locCount)
            let x = (titleLblWidth + width) * loc
            let y = row * height
            titleLabel.frame = CGRect(x: 17 + x, y: y, width: titleLblWidth, height: height)
            infoLbl.frame = CGRect(x: 17 + x + titleLblWidth, y: y, width: width, height: height)
            addSubview(titleLabel)
            addSubview(infoLbl)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue : UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    //返回随机颜色
    open class var randomColor:UIColor{
        get
        {
            let red = CGFloat(arc4random()%256)/255.0
            let green = CGFloat(arc4random()%256)/255.0
            let blue = CGFloat(arc4random()%256)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
