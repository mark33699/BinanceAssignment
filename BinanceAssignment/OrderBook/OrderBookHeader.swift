//
//  OrderBookHeader.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/16.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit
import SnapKit

class OrderBookHeader: UITableViewHeaderFooterView
{
    let digitLoseBtn = UIButton()
    
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .generalBackground
        
        let bid = UILabel()
        contentView.addSubview(bid)
        bid.text = "Bid"
        bid.textColor = .gray
        bid.snp.makeConstraints
        { (maker) in
            maker.left.top.bottom.equalToSuperview()
        }
        
        let ask = UILabel()
        contentView.addSubview(ask)
        ask.text = "Ask"
        ask.textColor = .gray
        ask.snp.makeConstraints
        { (maker) in
            maker.top.bottom.equalToSuperview()
            maker.width.equalTo(40)
            maker.centerX.equalToSuperview().offset(20)
        }
        
        contentView.addSubview(digitLoseBtn)
        digitLoseBtn.backgroundColor = .gray
        digitLoseBtn.snp.makeConstraints
        { (maker) in
            maker.right.equalToSuperview().offset(-10)
            maker.bottom.equalToSuperview().offset(-5)
            maker.top.equalToSuperview().offset(10)
            maker.width.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
}
