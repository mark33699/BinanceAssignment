//
//  MarketViewModel.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/12.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit

//let zeroString = "0.00000000"
let maxDigits = 8

class MarketOrderViewModel: BABassClass
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
    
    var quantityDigits = maxDigits
    var priceDigits = maxDigits
    var priceDigitsCount: Int
    {
        switch priceDigits
        {
        case 0:
            return 1
        case 1:
            return 2
        case 2:
            return 3
        default:
            return 4
        }
    }
    
    override init()
    {
        super.init()
        
        requestExchangeInfo()
    }
    
    private func socketBinding()
    {
        socketManager.didReceiveMessageHandler =
        {[weak self] message -> () in
            
            if let self = self, let stream = self.jsonStringToOrderBookStream(message)
            {
                //While listening to the stream, each new event's U should be equal to the previous event's u+1.
                if self.streamLastUpdateId == 0 ||
                (stream.firstUpdateID == self.streamLastUpdateId + 1)
                {
                    //Drop any event where u is <= lastUpdateId in the snapshot.
                    if self.snapshotLastUpdateId != 0 &&
                       stream.lastUpdateID >= self.snapshotLastUpdateId + 1
                    {
                        self.updateOrderBook(stream)
                    }
                }
                else
                {
                    //若網路短暫中斷，數據還能夠恢復
                    self.requestOrderBookSnapshot()
                }
                self.streamLastUpdateId = stream.lastUpdateID
            }
        }
    }
    
    //MARK:- api
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
                
                self.requestOrderBookSnapshot()
                self.socketBinding()
                
                DispatchQueue.main.async
                {
                    self.completionHandler()
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
                
                //delete zero data
                self.askOrders = self.stringArrayToOrderArray(snapshot.asks).filter { Double($0.quantity) != 0 }
                self.bidOrders = self.stringArrayToOrderArray(snapshot.bids).filter { Double($0.quantity) != 0 }
                
                //cut zero
                self.askOrders = self.askOrders.map
                {
                    Order(priceLevel: $0.priceLevel.substring(cut: maxDigits - self.priceDigits),
                          quantity: $0.quantity.substring(cut: maxDigits - self.quantityDigits))
                }
                self.bidOrders = self.bidOrders.map
                {
                    Order(priceLevel: $0.priceLevel.substring(cut: maxDigits - self.priceDigits),
                          quantity: $0.quantity.substring(cut: maxDigits - self.quantityDigits))
                }
                
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
    
    //MARK:- value process
    ///updata both array
    private func updateOrderBook(_ stream: OrderBookStream)
    {
        let newAsks = self.stringArrayToOrderArray(stream.asks)
        let newBids = self.stringArrayToOrderArray(stream.bids)
        
        updateOrder(newOrders: newAsks, originOrders: &askOrders, isAsk: true)
        updateOrder(newOrders: newBids, originOrders: &bidOrders, isAsk: false)
        
        sumAllOrderBook()
        
        self.completionHandler()
    }
    
    ///updata one array
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
                        if Double(newOrder.quantity) == 0
                        {
                            //if the quantity is 0, remove the price level.
                            originOrders.remove(at: offset)
                        }
                        else
                        {
                            //The data in each event is the absolute quantity for a price level.
                            originOrders[offset] = newOrder
                        }
                        isSamePrice = true
                        break
                    }
                    
                    //keep for insert
                    if (isAsk && newOrder.priceLevel < originOrder.priceLevel)
                    || (!isAsk && newOrder.priceLevel > originOrder.priceLevel)
                    {
                        newIndex = offset
                        break
                    }
                }
                
                //insert
                if isSamePrice == false && Double(newOrder.quantity) != 0
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
            self.askOrdersLose1 = self.sumOrderBook(self.askOrders, isAsk: true)
            self.bidOrdersLose1 = self.sumOrderBook(self.bidOrders, isAsk: false)
            self.askOrdersLose2 = self.sumOrderBook(self.askOrdersLose1, isAsk: true)
            self.bidOrdersLose2 = self.sumOrderBook(self.bidOrdersLose1, isAsk: false)
            self.askOrdersLose3 = self.sumOrderBook(self.askOrdersLose2, isAsk: true)
            self.bidOrdersLose3 = self.sumOrderBook(self.bidOrdersLose2, isAsk: false)
        }
    }
    
    private func sumOrderBook(_ orders: [Order],
                              isAsk: Bool) -> [Order]
    {
        //Step1. lose digit
        let loseDigitOrderBook = isAsk ?
        orders.map //ask should ceiling
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
        orders.map //bid just cut
        { (order) -> Order in

            return Order(priceLevel: self.getSubStringToSecondLast(order.priceLevel),
                         quantity: order.quantity)
        }
        
        //Step2. sum same price
        var sumOrderBook = [Order]()
        for order: Order in loseDigitOrderBook
        {
            //sum or append
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
    
    //MARK:- instance func
    private func getSubStringToSecondLast(_ str: String) -> String
    {
        let end = str.index(str.endIndex, offsetBy: -1)
        let newString = str[str.startIndex..<end]
        return String(newString)
    }
    
    private func stringArrayToOrderArray(_ array: [[String]]) -> [Order]
    {
        array.map
        {
            Order(priceLevel: $0.first!.substring(cut: maxDigits - priceDigits),
                  quantity: $0.last!.substring(cut: maxDigits - quantityDigits))
        }
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
