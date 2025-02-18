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
//let symbol = "ETHUSDT"
let maxDisplayOrderCount = 14
let maxDisplayHistoryCount = 14
let segmentBarHeight: CGFloat = 50

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
    
    let orderLabel = UILabel()
    let historyLabel = UILabel()
    let segmentBarIndicator = UIView()
    
    let orderVM = MarketOrderViewModel()
    let orderTableView = BATableView()
    
    let historyVM = MarketHistroyViewModel()
    let historyTableView = BATableView()
    
    var currentLoseDigit: MarketLoseDigitRange = .noLose
    var didSelectDigit: String?
    
    var shouldLayout = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = symbol
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if shouldLayout
        {
            shouldLayout = false
            
            layoutUI()
            dataBinding()
        }
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
        //MARK:- segmentBarUI
        view.addSubview(orderLabel)
        orderLabel.text = "Order Book"
        orderLabel.textColor = UIColor.binanceYellow
        orderLabel.textAlignment = .center
        orderLabel.snp.makeConstraints
        { (maker) in
            maker.top.left.equalTo(view.safeAreaLayoutGuide)
            maker.width.equalTo(view.frame.width / 2)
            maker.height.equalTo(segmentBarHeight)
        }
        
        view.addSubview(historyLabel)
        historyLabel.text = "Market History"
        historyLabel.textColor = UIColor.gray
        historyLabel.textAlignment = .center
        historyLabel.snp.makeConstraints
        { (maker) in
            maker.top.right.equalTo(view.safeAreaLayoutGuide)
            maker.width.height.equalTo(orderLabel)
        }
        
        view.addSubview(segmentBarIndicator)
        segmentBarIndicator.backgroundColor = UIColor.binanceYellow
        segmentBarIndicator.snp.makeConstraints
        { (maker) in
            maker.height.equalTo(2)
            maker.width.equalTo(view.frame.width / 4)
            maker.top.equalTo(orderLabel.snp.bottom)
            maker.centerX.equalTo(orderLabel.snp.centerX)
        }
        
        //MARK:- scrollViewUI
        let scrollHeight = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - segmentBarHeight
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.generalBackground
        scrollView.contentSize = .init(width: view.frame.width * 2, height: scrollHeight)
        scrollView.snp.makeConstraints
        { (maker) in
            maker.top.equalTo(orderLabel.snp.bottom).offset(2)
            maker.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        orderTableView.frame = .init(x: 0, y: 0, width: view.frame.width, height: scrollHeight)
        scrollView.addSubview(orderTableView)
        orderTableView.dataSource = self
        orderTableView.delegate = self
        orderTableView.register(OrderBookTblCell.self, forCellReuseIdentifier: "\(OrderBookTblCell.self)")
        orderTableView.register(OrderBookHeader.self, forHeaderFooterViewReuseIdentifier: "\(OrderBookHeader.self)")
        
        historyTableView.frame = .init(x: view.frame.width, y: 0, width: view.frame.width, height: scrollHeight)
        scrollView.addSubview(historyTableView)
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.register(MarketHistoryTblCell.self, forCellReuseIdentifier: "\(MarketHistoryTblCell.self)")
        historyTableView.register(MarketHistoryHeader.self, forHeaderFooterViewReuseIdentifier: "\(MarketHistoryHeader.self)")
    }
    
    private func moveIndicator(isLeft: Bool)
    {
        segmentBarIndicator.snp.removeConstraints()
        segmentBarIndicator.snp.makeConstraints
        { (maker) in
            maker.height.equalTo(2)
            maker.width.equalTo(view.frame.width / 4)
            maker.top.equalTo(historyLabel.snp.bottom)
            maker.centerX.equalTo(isLeft ? orderLabel.snp.centerX : historyLabel.snp.centerX)
        }
    }

    //MARK:- delegate func
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView.contentOffset.x == 0
        {
            orderLabel.textColor = UIColor.binanceYellow
            historyLabel.textColor = UIColor.gray
            moveIndicator(isLeft: true)
        }
        else if scrollView.contentOffset.x == view.frame.width
        {
            orderLabel.textColor = UIColor.gray
            historyLabel.textColor = UIColor.binanceYellow
            moveIndicator(isLeft: false)
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
                
                cell.updateUI(bidOrder: bo,
                              askOrder: ao,
                              qtyDigit: orderVM.quantityDigits,
                              priceDigit: orderVM.priceDigits)
                
                //I don't know real rule, But I will do it
                cell.updateBackgroundProportion(green: calculateProportion(currentQty: bo.quantity, isAsk: false),
                                                red: calculateProportion(currentQty: ao.quantity, isAsk: true))
                
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

    //MARK:- selector
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
    
    //MARK:- instance func
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
    
    private func calculateProportion(currentQty: String ,isAsk: Bool) -> CGFloat
    {
        if currentQty == "" { return 0 }
        
        let currntOrders = getCurrentOrder(isAsk: isAsk)
        let topCount = min(currntOrders.count, maxDisplayOrderCount)
        let topOrders = Array(currntOrders[0..<topCount]).map{ Double($0.quantity) }
        let sum = topOrders.reduce(0.0){ $0 + ($1 ?? 0.0) }
        let qty = Double(currentQty) ?? 0.0
        let p = qty / sum
        return CGFloat(p / 2)
    }
}
