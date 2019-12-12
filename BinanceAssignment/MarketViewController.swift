//
//  MarketViewController.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/10.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit
import SnapKit

class MarketViewController: BABassViewController, UITableViewDataSource
{
    let socketManager = WebSocketManager()
    let viewModel = MarketViewModel()
    let marketTableView = BATableView()
    
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
        marketTableView.dataSource = self
        marketTableView.register(OrderBookTblCell.self, forCellReuseIdentifier: "\(OrderBookTblCell.self)")
        marketTableView.snp.makeConstraints
        { (maker) in
            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            maker.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1000 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderBookTblCell.self)", for: indexPath) as? OrderBookTblCell
        {
            cell.updateUI()
            let p: CGFloat = CGFloat(indexPath.row + 1) / CGFloat(2000)
            cell.updateBackgroundProportion(green: p, red: p)
            return cell
        }
        
        return UITableViewCell()
    }
}
