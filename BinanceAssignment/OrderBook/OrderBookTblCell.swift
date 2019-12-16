//
//  OrderBookTblCell.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/12.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit
import SnapKit

class OrderBookTblCell: BATableViewCell
{
    var bidBG = UIView()
    var askBG = UIView()
    var bidQty = UILabel()
    var bidPrice = UILabel()
    var askPrice = UILabel()
    var askQty = UILabel()
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutUI()
    }
    
    func layoutUI()
    {
        contentView.addSubview(bidBG)
        bidBG.backgroundColor = .orderBackgroundGreen
        contentView.addSubview(askBG)
        askBG.backgroundColor = .orderBackgroundRed
        
        let font = UIFont.boldSystemFont(ofSize: 13)

        contentView.addSubview(bidQty)
        bidQty.font = font
        bidQty.textColor = .white
        bidQty.snp.makeConstraints
        { (maker) in
            maker.top.bottom.left.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
        }
        
        contentView.addSubview(bidPrice)
        bidPrice.font = font
        bidPrice.textAlignment = .right
        bidPrice.textColor = .orderTextGreen
        bidPrice.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
            maker.left.equalTo(bidQty.snp.right)
        }

        contentView.addSubview(askPrice)
        askPrice.font = font
        askPrice.textColor = .orderTextRed
        askPrice.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
            maker.left.equalTo(bidPrice.snp.right)
        }

        contentView.addSubview(askQty)
        askQty.font = font
        askQty.textAlignment = .right
        askQty.textColor = .white
        askQty.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
            maker.left.equalTo(askPrice.snp.right)
        }
    }
    
    func updateUI(bidOrder: Order, askOrder: Order, qtyDigit: Int = 8)
    {
        //數量的精度也可以做在資料面, 但考量到有可能取不到ExchangeInfo的情況, 還是做在UI面
        //TODO: sum完之後qty會變成.0
//        let lose = qtyDigit == 0 ? maxDigits + 1 : maxDigits - qtyDigit
//        let bqStr = bidOrder.quantity
//        let bqEnd = bqStr.index(bqStr.endIndex, offsetBy: -lose)
//        let bq = bqStr[bqStr.startIndex..<bqEnd]
//        bidQty.text = String(bq)
//        let aqStr = askOrder.quantity
//        let aqEnd = aqStr.index(aqStr.endIndex, offsetBy: -lose)
//        let aq = aqStr[aqStr.startIndex..<aqEnd]
//        askQty.text = String(aq)
        
        bidQty.text = bidOrder.quantity
        askQty.text = askOrder.quantity
        bidPrice.text = bidOrder.priceLevel
        askPrice.text = askOrder.priceLevel
    }
    
    func updateBackgroundProportion(green: CGFloat, red: CGFloat)
    {
        bidBG.snp.removeConstraints()
        bidBG.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.centerX.equalToSuperview().multipliedBy(1 - green)
            maker.width.equalToSuperview().multipliedBy(green)
        }
        
        askBG.snp.removeConstraints()
        askBG.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.left.equalTo(bidBG.snp.right)
            maker.width.equalToSuperview().multipliedBy(red)
        }
    }
}
