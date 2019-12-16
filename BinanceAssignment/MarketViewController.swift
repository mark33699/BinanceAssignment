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
let maxDisplayOrderCount = 14
let maxDisplayHistoryCount = 14
let segmentBarHeight: CGFloat = 40

enum MarketLoseDigitRange: Int
{
    case threeLose  = 0
    case twoLose
    case oneLose
    case noLose
}

class MarketViewController: BABassViewController, UITableViewDataSource, UITableViewDelegate
{
    let popoverVC = DigitSelectViewController()
    
    let orderVM = MarketOrderViewModel()
    let orderTableView = BATableView()
    
    let historyVM = MarketHistroyViewModel()
    let historyTableView = BATableView()
    
    var currentLoseDigit: MarketLoseDigitRange = .noLose
    var didSelectDigit: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = symbol
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        layoutUI()
        dataBinding()
    }
    
    func dataBinding()
    {
        orderVM.completionHandler =
        {[weak self] in
            self?.orderTableView.reloadData()
        }
        
        historyVM.completionHandler =
        {[weak self] in
            self?.historyTableView.reloadData()
        }
    }
    
    private func layoutUI()
    {
        let scrollHeight = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - segmentBarHeight
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.generalBackground
        scrollView.contentSize = .init(width: view.frame.width * 2, height: scrollHeight)
        scrollView.snp.makeConstraints
        { (maker) in
            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(segmentBarHeight)
            maker.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        orderTableView.frame = .init(x: 0, y: 0, width: view.frame.width, height: scrollHeight)
        scrollView.addSubview(orderTableView)
        orderTableView.dataSource = self
        orderTableView.delegate = self
        orderTableView.register(OrderBookTblCell.self, forCellReuseIdentifier: "\(OrderBookTblCell.self)")
        orderTableView.register(OrderBookHeader.self, forHeaderFooterViewReuseIdentifier: "\(OrderBookHeader.self)")
        orderTableView.sectionHeaderHeight = 40
        orderTableView.isScrollEnabled = false
        
        historyTableView.frame = .init(x: view.frame.width, y: 0, width: view.frame.width, height: scrollHeight)
        scrollView.addSubview(historyTableView)
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.register(MarketHistoryTblCell.self, forCellReuseIdentifier: "\(MarketHistoryTblCell.self)")
        historyTableView.register(MarketHistoryHeader.self, forHeaderFooterViewReuseIdentifier: "\(MarketHistoryHeader.self)")
        historyTableView.sectionHeaderHeight = 40
        historyTableView.isScrollEnabled = false
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
                cell.updateUI(history: historyVM.historys[safe: indexPath.row] ?? MarketHistory(time: 0, price: "", quantity: "", isBuyer: true))
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
                header.digitLoseBtn.setTitle(didSelectDigit ?? "\(orderVM.priceDigits)", for: .normal)
                header.digitLoseBtn.addTarget(self, action: #selector(digitSelect), for: .touchUpInside)
                return header
            }
        }
        else if tableView == historyTableView
        {
            return tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(MarketHistoryHeader.self)")
        }
        return nil
    }
    
    @objc func digitSelect(btn: UIButton)
    {
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: digitSelectMenuWidth, height: orderVM.priceDigitsCount * digitSelectButtonHeight)
        popoverVC.popoverPresentationController?.delegate = self
        popoverVC.popoverPresentationController?.sourceRect = .init(x: 20, y: 25, width: 0, height: 0)
        popoverVC.popoverPresentationController?.sourceView = btn
        popoverVC.popoverPresentationController?.permittedArrowDirections = .up
        popoverVC.popoverPresentationController?.backgroundColor = .clear
        popoverVC.setupButtonsTitle(from: orderVM.priceDigits - orderVM.priceDigitsCount + 1)
        
        popoverVC.didSelectDigitHandler =
        {[weak self] (index, title) in
            
            if let self = self
            {
                self.didSelectDigit = title
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
