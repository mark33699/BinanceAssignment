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
    
    var c: ConstraintMakerEditable!
    func layoutUI()
    {
        contentView.addSubview(bidBG)
        bidBG.backgroundColor = .orderBackgroundGreen
        contentView.addSubview(askBG)
        askBG.backgroundColor = .orderBackgroundRed

        contentView.addSubview(bidQty)
        bidQty.textColor = .white
        bidQty.snp.makeConstraints
        { (maker) in
            maker.top.bottom.left.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
        }
        
        contentView.addSubview(bidPrice)
        bidPrice.textAlignment = .right
        bidPrice.textColor = .orderTextGreen
        bidPrice.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
            maker.left.equalTo(bidQty.snp.right)
        }

        contentView.addSubview(askPrice)
        askPrice.textColor = .orderTextRed
        askPrice.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
            maker.left.equalTo(bidPrice.snp.right)
        }

        contentView.addSubview(askQty)
        askQty.textAlignment = .right
        askQty.textColor = .white
        askQty.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
            maker.left.equalTo(askPrice.snp.right)
        }
    }
    
    func updateUI()
    {
        bidQty.text = "123"
        bidPrice.text = "0.00000123"
        askPrice.text = "0.00000456"
        askQty.text = "456"
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
