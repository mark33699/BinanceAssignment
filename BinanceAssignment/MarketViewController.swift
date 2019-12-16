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

enum MarketLoseDigitRange: Int
{
    case threeLose  = 0
    case twoLose
    case oneLose
    case noLose
}

class MarketViewController: BABassViewController, UITableViewDataSource, UITableViewDelegate
{
    let viewModel = MarketViewModel()
    let marketTableView = BATableView()
    
    var currentLoseDigit: MarketLoseDigitRange = .noLose
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        layoutUI()
        
        viewModel.completionHandler =
        {[weak self] in
            
            self?.marketTableView.reloadData()
        }
    }
    
    func layoutUI()
    {
        view.addSubview(marketTableView)
        marketTableView.dataSource = self
        marketTableView.delegate = self
        marketTableView.register(OrderBookTblCell.self, forCellReuseIdentifier: "\(OrderBookTblCell.self)")
        marketTableView.register(OrderBookHeader.self, forHeaderFooterViewReuseIdentifier: "\(OrderBookHeader.self)")
        marketTableView.sectionHeaderHeight = 40
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
            
            switch currentLoseDigit
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(OrderBookHeader.self)") as? OrderBookHeader
        {
            header.digitLoseBtn.addTarget(self, action: #selector(digitSelect), for: .touchUpInside)
            return header
        }
        return nil
    }
    
    @objc func digitSelect(btn: UIButton)
    {
        let popoverVC = DigitSelectViewController()
        
        popoverVC.modalPresentationStyle = .popover
        popoverVC.preferredContentSize = CGSize(width: digitSelectMenuWidth, height: viewModel.priceDigitsCount * digitSelectButtonHeight)
        popoverVC.popoverPresentationController?.delegate = self
        popoverVC.popoverPresentationController?.sourceRect = .init(x: 20, y: 25, width: 0, height: 0)
        popoverVC.popoverPresentationController?.sourceView = btn
        popoverVC.popoverPresentationController?.permittedArrowDirections = .up
        popoverVC.popoverPresentationController?.backgroundColor = .clear
        popoverVC.setupButtonsTitle(from: viewModel.priceDigits - viewModel.priceDigitsCount + 1)
        
        popoverVC.didSelectDigitHandler =
        {[weak self] (index) in
            
            if let self = self
            {
                self.currentLoseDigit = MarketLoseDigitRange.init(rawValue: index) ?? self.currentLoseDigit
                self.marketTableView.reloadData()
            }
        }
        
        present(popoverVC, animated: true, completion: nil)
    }
}
