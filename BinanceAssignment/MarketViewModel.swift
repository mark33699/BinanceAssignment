//
//  MarketViewModel.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/12.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit

let maxDisplayOrderCount = 15
let zeroString = "0.00000000"
let maxDigits = 8

class MarketViewModel: BABassClass
{
    var completionHandler: (() -> Void)! = {}
    
    let socketManager = WebSocketManager.init(with: SocketUrl.orderBook)
    
    var askOrders = [Order]()
    var bidOrders = [Order]()
    var askOrdersLose1 = [Order]()
    var bidOrdersLose1 = [Order]()
    var askOrdersLose2 = [Order]()
    var bidOrdersLose2 = [Order]()
    var askOrdersLose3 = [Order]()
    var bidOrdersLose3 = [Order]()
    var snapshotLastUpdateId = 0
    var streamLastUpdateId = 0
    
    var priceDigits = maxDigits
    var quantityDigits = maxDigits
    
    override init()
    {
        super.init()
        
        requestExchangeInfo()
        requestOrderBookSnapshot()
        
        socketManager.didReceiveMessageHandler =
        { message -> () in
            
            if let stream = self.jsonStringToOrderBookStream(message)
            {
                if self.streamLastUpdateId == 0 ||
                (stream.firstUpdateID == self.streamLastUpdateId + 1)
                {
                    if self.snapshotLastUpdateId != 0 &&
                       stream.lastUpdateID >= self.snapshotLastUpdateId + 1
                    {
                        self.updateOrderBook(stream)
                    }
                }
                else
                {
//                    print("lose packet: \(self.streamLastUpdateId), \(stream.firstUpdateID)")
                    self.requestOrderBookSnapshot()
                }
                self.streamLastUpdateId = stream.lastUpdateID
            }
        }
    }
    
    private func requestExchangeInfo()
    {
        ApiManager.apiRequest(with: ApiUrl.exchangeInfo, objectType: ExchangeInfo.self)
        { (result) in

            switch result
            {
            case .success(let info):
                if let minTickSize = info.data.first?.minTickSize
                {
                    self.priceDigits = self.getDigits(by: minTickSize)
                }
                if let minTradeAmount = info.data.first?.minTradeAmount
                {
                    self.quantityDigits = self.getDigits(by: minTradeAmount)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func requestOrderBookSnapshot()
    {
        ApiManager.apiRequest(with: ApiUrl.orderBook, objectType: OrderBookSnapshot.self)
        { (result) in
            
            switch result
            {
            case .success(let snapshot):
                self.snapshotLastUpdateId = snapshot.lastUpdateId
                self.askOrders = self.stringArrayToOrderArray(snapshot.asks).filter { $0.quantity != zeroString }
                self.bidOrders = self.stringArrayToOrderArray(snapshot.bids).filter { $0.quantity != zeroString }

//                print("snapshot asks\n\(self.askOrders)")
                
                self.sumAllOrderBook()
                
                DispatchQueue.main.async
                {
                    self.completionHandler()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateOrderBook(_ stream: OrderBookStream)
    {
        let newAsks = self.stringArrayToOrderArray(stream.asks)
        let newBids = self.stringArrayToOrderArray(stream.bids)
        
//        print("stream asks\n\(newAsks)")
        updateOrder(newOrders: newAsks, originOrders: &askOrders, isAsk: true)
        updateOrder(newOrders: newBids, originOrders: &bidOrders, isAsk: false)
//        print("updated asks\n\(self.askOrders)")
        
        sumAllOrderBook()
        
        self.completionHandler()
    }
    
    private func updateOrder(newOrders: [Order],
                             originOrders: inout [Order],
                             isAsk: Bool)
    {
        for newOrder: Order in newOrders
        {
            if (isAsk && newOrder.priceLevel < originOrders.last!.priceLevel)
            || (!isAsk && newOrder.priceLevel > originOrders.last!.priceLevel)
            {
                var isSamePrice = false
                var newIndex = 0
                
                //replace
                for (offset, originOrder) in originOrders.enumerated()
                {
                    if newOrder.priceLevel == originOrder.priceLevel
                    {
                        if newOrder.quantity == zeroString
                        {
                            originOrders.remove(at: offset)
                        }
                        else
                        {
                            originOrders[offset] = newOrder
                        }
                        isSamePrice = true
                        break
                    }
                    
                    if (isAsk && newOrder.priceLevel < originOrder.priceLevel)
                    || (!isAsk && newOrder.priceLevel > originOrder.priceLevel)
                    {
                        newIndex = offset
                        break
                    }
                }
                
                //insert
                if isSamePrice == false && newOrder.quantity != zeroString
                {
                    originOrders.insert(newOrder, at: newIndex)
                }
            }
        }
    }
    
    private func sumAllOrderBook()
    {
        switch self.priceDigits
        {
        case 0:
            print("no need sum")
            
        case 1:
            self.askOrdersLose1 = self.sumOrderBook(self.askOrders, isAsk: true)
            self.bidOrdersLose1 = self.sumOrderBook(self.bidOrders, isAsk: false)
            
        case 2:
            self.askOrdersLose1 = self.sumOrderBook(self.askOrders, isAsk: true)
            self.bidOrdersLose1 = self.sumOrderBook(self.bidOrders, isAsk: false)
            self.askOrdersLose2 = self.sumOrderBook(self.askOrdersLose1, isAsk: true)
            self.bidOrdersLose2 = self.sumOrderBook(self.bidOrdersLose1, isAsk: false)
            
        default:
//            print("加前\(self.askOrders)")
            self.askOrdersLose1 = self.sumOrderBook(self.askOrders, isAsk: true)
            self.bidOrdersLose1 = self.sumOrderBook(self.bidOrders, isAsk: false)
            self.askOrdersLose2 = self.sumOrderBook(self.askOrdersLose1, isAsk: true)
            self.bidOrdersLose2 = self.sumOrderBook(self.bidOrdersLose1, isAsk: false)
            self.askOrdersLose3 = self.sumOrderBook(self.askOrdersLose2, isAsk: true)
            self.bidOrdersLose3 = self.sumOrderBook(self.bidOrdersLose2, isAsk: false)
//            print("加後\(self.askOrdersLose1)")
        }
    }
    
    private func sumOrderBook(_ orders: [Order],
                              isAsk: Bool) -> [Order]
    {
        let loseDigitOrderBook = isAsk ?
        orders.map
        { (order) -> Order in
            
            if order.priceLevel.last == "0"
            {
                return Order(priceLevel: self.getSubStringToSecondLast(order.priceLevel),
                             quantity: order.quantity)
            }
            else
            {
                let shouldDigit = order.priceLevel.components(separatedBy: ".").last!.count - 1
                let doublePrice = Double(order.priceLevel)!
                let ceilPrice = doublePrice.ceiling(toDecimal: shouldDigit)
                var newPrice = "\(ceilPrice)"
                while newPrice.components(separatedBy: ".").last!.count < shouldDigit
                {
                    newPrice = newPrice + "0"
                }
                return Order(priceLevel: newPrice, quantity: order.quantity)
            }
        } :
        orders.map
        { (order) -> Order in

            return Order(priceLevel: self.getSubStringToSecondLast(order.priceLevel),
                         quantity: order.quantity)
        }
        
        var sumOrderBook = [Order]()
        for order: Order in loseDigitOrderBook
        {
            if sumOrderBook.count == 0
            {
                sumOrderBook.append(order)
            }
            else
            {
                if sumOrderBook.last!.priceLevel == order.priceLevel
                {
                    var sumQty: Double = 0
                    if let lastQty = Double(sumOrderBook.last!.quantity),
                       let thisQty = Double(order.quantity)
                    {
                        sumQty = lastQty + thisQty
                    }
                    sumOrderBook[sumOrderBook.count - 1] = Order(priceLevel: order.priceLevel, quantity: "\(sumQty)")
                }
                else
                {
                    sumOrderBook.append(order)
                }
            }
        }

        return sumOrderBook
    }
    
    private func getSubStringToSecondLast(_ str: String) -> String
    {
        let end = str.index(str.endIndex, offsetBy: -1)
        let newString = str[str.startIndex..<end]
        return String(newString)
    }
    
    private func stringArrayToOrderArray(_ array: [[String]]) -> [Order]
    {
        array.map{ Order(priceLevel: $0.first!, quantity: $0.last!) }
    }
    
    private func jsonStringToOrderBookStream(_ jsonString: String) -> OrderBookStream?
    {
        do
        {
            let orderBookStream = try JSONDecoder().decode(OrderBookStream.self, from: jsonString.data(using: .utf8)!)
            return orderBookStream
        }
        catch
        {
            return nil
        }
    }
    
    private func getDigits(by string: String) -> Int
    {
        if string.contains(".")
        {
            return string.split(separator: ".").last!.count
        }
        else
        {
            return 0
        }
    }
}
