//
//  MarketViewController.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/10.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit

class MarketViewController: UIViewController
{
    let socketManager = WebSocketManager()
    let viewModel = MarketViewModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        viewModel.requestOrderBookSnapshot
        {
            
        }
    }
}

