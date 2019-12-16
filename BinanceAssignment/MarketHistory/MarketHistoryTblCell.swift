//
//  MarketHistoryTblCell.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/16.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit
import SnapKit

class MarketHistoryTblCell: BATableViewCell
{
    let time = UILabel()
    let price = UILabel()
    let quantity = UILabel()
    
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
        contentView.addSubview(time)
        time.textColor = .white
        time.snp.makeConstraints
        { (maker) in
            maker.bottom.top.left.equalToSuperview()
            maker.width.equalToSuperview().multipliedBy(0.25)
        }
        
        contentView.addSubview(price)
        price.snp.makeConstraints
        { (maker) in
            maker.bottom.top.equalToSuperview()
            maker.left.equalTo(time.snp.right)
            maker.width.equalToSuperview().multipliedBy(0.4)
        }
        
        contentView.addSubview(quantity)
        quantity.textColor = .white
        quantity.textAlignment = .right
        quantity.snp.makeConstraints
        { (maker) in
            maker.bottom.top.right.equalToSuperview()
            maker.left.equalTo(price.snp.right)
        }
    }
    
    func updateUI(history: MarketHistory)
    {
        guard history.price != "" && history.quantity != "" else { return }
        
        let date = Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm:ss"
        
        time.text = fmt.string(from: date)
        price.text = history.price
        quantity.text = history.quantity
        price.textColor = history.isBuyer ? UIColor.orderTextRed : UIColor.orderTextGreen
    }
}
