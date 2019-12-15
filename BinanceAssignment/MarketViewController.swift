//
//  MarketViewController.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/10.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit
import SnapKit

let symbol = "LINKBTC"

enum MarketLoseDigitRange
{
    case noLose
    case oneLose
    case twoLose
    case threeLose
}

class MarketViewController: BABassViewController, UITableViewDataSource
{
    let viewModel = MarketViewModel()
    let marketTableView = BATableView()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        layoutUI()
        
        viewModel.completionHandler =
        {
            self.marketTableView.reloadData()
        }
    }
    
    func layoutUI()
    {
        view.addSubview(marketTableView)
        marketTableView.dataSource = self
        marketTableView.register(OrderBookTblCell.self, forCellReuseIdentifier: "\(OrderBookTblCell.self)")
        marketTableView.snp.makeConstraints
        { (maker) in
            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            maker.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { maxDisplayOrderCount }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderBookTblCell.self)", for: indexPath) as? OrderBookTblCell
        {
            var currentAskOrders = [Order]()
            var currentBidOrders = [Order]()
            
            let loseDigitRange: MarketLoseDigitRange = .noLose
            switch loseDigitRange
            {
                case .noLose:
                    currentAskOrders = viewModel.askOrders
                    currentBidOrders = viewModel.bidOrders
                case .oneLose:
                    currentAskOrders = viewModel.askOrdersLose1
                    currentBidOrders = viewModel.bidOrdersLose1
                case .twoLose:
                    currentAskOrders = viewModel.askOrdersLose2
                    currentBidOrders = viewModel.bidOrdersLose2
                case .threeLose:
                    currentAskOrders = viewModel.askOrdersLose3
                    currentBidOrders = viewModel.bidOrdersLose3
            }
            
            let bo = currentBidOrders[safe: indexPath.row] ?? Order(priceLevel: "", quantity: "")
            let ao = currentAskOrders[safe: indexPath.row] ?? Order(priceLevel: "", quantity: "")
            
            cell.updateUI(bidOrder: bo, askOrder: ao, qtyDigit: viewModel.quantityDigits)
            
//            let p: CGFloat = CGFloat(indexPath.row + 1) / CGFloat(2000)
//            cell.updateBackgroundProportion(green: p, red: p)
            
            return cell
        }
        
        return UITableViewCell()
    }
}
