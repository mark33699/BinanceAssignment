//
//  MarketViewController.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/10.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit
import SnapKit

let symbol = "BNBBTC"
//let symbol = "LINKBTC"
let maxDisplayOrderCount = 15
let maxDisplayHistoryCount = 15

enum MarketLoseDigitRange: Int
{
    case threeLose  = 0
    case twoLose
    case oneLose
    case noLose
}

class MarketViewController: BABassViewController, UITableViewDataSource, UITableViewDelegate
{
    let orderVM = MarketOrderViewModel()
    let orderTableView = BATableView()
    
    let historyVM = MarketHistroyViewModel()
    let historyTableView = BATableView()
    
    var currentLoseDigit: MarketLoseDigitRange = .noLose
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        layoutUI()
        
//        orderVM.completionHandler =
//        {[weak self] in
//            self?.orderTableView.reloadData()
//        }
        
        historyVM.completionHandler =
        {[weak self] in
            self?.historyTableView.reloadData()
        }
    }
    
    private func layoutUI()
    {
//        view.addSubview(orderTableView)
//        orderTableView.dataSource = self
//        orderTableView.delegate = self
//        orderTableView.register(OrderBookTblCell.self, forCellReuseIdentifier: "\(OrderBookTblCell.self)")
//        orderTableView.register(OrderBookHeader.self, forHeaderFooterViewReuseIdentifier: "\(OrderBookHeader.self)")
//        orderTableView.sectionHeaderHeight = 40
//        orderTableView.snp.makeConstraints
//        { (maker) in
//            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
//            maker.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
//        }
        
        view.addSubview(historyTableView)
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.register(MarketHistoryTblCell.self, forCellReuseIdentifier: "\(MarketHistoryTblCell.self)")
//        historyTableView.register(OrderBookHeader.self, forHeaderFooterViewReuseIdentifier: "\(OrderBookHeader.self)")
        historyTableView.sectionHeaderHeight = 40
        historyTableView.snp.makeConstraints
        { (maker) in
            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
            maker.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == orderTableView
        {
            return maxDisplayOrderCount
        }
        else if tableView == historyTableView
        {
            return maxDisplayHistoryCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView == orderTableView
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderBookTblCell.self)", for: indexPath) as? OrderBookTblCell
            {
                let bo = getCurrentOrder(isAsk: false)[safe: indexPath.row] ?? Order(priceLevel: "", quantity: "")
                let ao = getCurrentOrder(isAsk: true)[safe: indexPath.row] ?? Order(priceLevel: "", quantity: "")
                
                cell.updateUI(bidOrder: bo, askOrder: ao, qtyDigit: orderVM.quantityDigits)
                
    //            let p: CGFloat = CGFloat(indexPath.row + 1) / CGFloat(2000)
    //            cell.updateBackgroundProportion(green: p, red: p)
                
                return cell
            }
        }
        else if tableView == historyTableView
        {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "\(MarketHistoryTblCell.self)", for: indexPath) as? MarketHistoryTblCell
            {
                cell.updateUI(history: historyVM.historys[safe: indexPath.row] ?? MarketHistory(price: "", quantity: "", isBuyer: true))
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == orderTableView
        {
            if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(OrderBookHeader.self)") as? OrderBookHeader
            {
                header.digitLoseBtn.addTarget(self, action: #selector(digitSelect), for: .touchUpInside)
                return header
            }
        }
        else if tableView == historyTableView
        {
            
        }
        return nil
    }
    
    @objc func digitSelect(btn: UIButton)
    {
        let popoverVC = DigitSelectViewController()
        
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: digitSelectMenuWidth, height: orderVM.priceDigitsCount * digitSelectButtonHeight)
        popoverVC.popoverPresentationController?.delegate = self
        popoverVC.popoverPresentationController?.sourceRect = .init(x: 20, y: 25, width: 0, height: 0)
        popoverVC.popoverPresentationController?.sourceView = btn
        popoverVC.popoverPresentationController?.permittedArrowDirections = .up
        popoverVC.popoverPresentationController?.backgroundColor = .clear
        popoverVC.setupButtonsTitle(from: orderVM.priceDigits - orderVM.priceDigitsCount + 1)
        
        popoverVC.didSelectDigitHandler =
        {[weak self] (index) in
            
            if let self = self
            {
                self.currentLoseDigit = MarketLoseDigitRange.init(rawValue: index) ?? self.currentLoseDigit
                self.orderTableView.reloadData()
            }
        }
        
        present(popoverVC, animated: true, completion: nil)
    }
    
    private func getCurrentOrder(isAsk: Bool) -> [Order]
    {
        var currentAskOrders = [Order]()
        var currentBidOrders = [Order]()
        
        switch currentLoseDigit
        {
            case .noLose:
                currentAskOrders = orderVM.askOrders
                currentBidOrders = orderVM.bidOrders
            case .oneLose:
                currentAskOrders = orderVM.askOrdersLose1
                currentBidOrders = orderVM.bidOrdersLose1
            case .twoLose:
                currentAskOrders = orderVM.askOrdersLose2
                currentBidOrders = orderVM.bidOrdersLose2
            case .threeLose:
                currentAskOrders = orderVM.askOrdersLose3
                currentBidOrders = orderVM.bidOrdersLose3
        }
        
        return isAsk ? currentAskOrders : currentBidOrders
    }
}
