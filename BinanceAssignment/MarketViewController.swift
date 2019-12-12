//
//  MarketViewController.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/10.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit
import SnapKit

class MarketViewController: BABassViewController
{
    let socketManager = WebSocketManager()
    let viewModel = MarketViewModel()
    let marketTableView = UITableView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        layoutUI()
        
        viewModel.requestOrderBookSnapshot
        {
            
        }
    }
    
    func layoutUI()
    {
        view.addSubview(marketTableView)
        marketTableView.backgroundColor = .systemRed
        marketTableView.snp.makeConstraints
        { (maker) in
            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            maker.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
}

