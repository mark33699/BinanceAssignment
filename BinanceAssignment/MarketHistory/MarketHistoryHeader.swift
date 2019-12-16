//
//  MarketHistoryHeader.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/16.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit

class MarketHistoryHeader: UITableViewHeaderFooterView
{
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .generalBackground
        
        let time = UILabel()
        contentView.addSubview(time)
        time.text = "Time"
        time.textColor = .gray
        time.snp.makeConstraints
        { (maker) in
            maker.bottom.top.left.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
        }
        
        let price = UILabel()
        contentView.addSubview(price)
        price.text = "Price"
        price.textColor = .gray
        price.snp.makeConstraints
        { (maker) in
            maker.bottom.top.equalToSuperview()
            maker.left.equalTo(time.snp.right)
            maker.width.equalToSuperview().multipliedBy(0.4)
        }
        
        let quantity = UILabel()
        contentView.addSubview(quantity)
        quantity.text = "Quantity"
        quantity.textColor = .gray
        quantity.textAlignment = .right
        quantity.snp.makeConstraints
        { (maker) in
            maker.bottom.top.right.equalToSuperview()
            maker.left.equalTo(price.snp.right)
        }
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
}
