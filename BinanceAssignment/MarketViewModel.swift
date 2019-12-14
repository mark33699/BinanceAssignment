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

class MarketViewModel: BABassClass
{
    var completionHandler: (() -> Void)! = {}
    
    let socketManager = WebSocketManager.init(with: "wss://stream.binance.com:9443/ws/linkbtc@depth")
    
    var askOrders = [Order]()
    var bidOrders = [Order]()
    var snapshotLastUpdateId = 0
    
    override init()
    {
        super.init()
        
        requestOrderBookSnapshot()
        
        socketManager.didReceiveMessageHandler =
        { message -> () in
            let stream = self.jsonStringToOrderBookStream(message)
            if let stream = stream
            {
                if self.snapshotLastUpdateId != 0 &&
                   stream.lastUpdateID >= self.snapshotLastUpdateId + 1
                {
                    self.updateOrderBook(stream)
                }
            }
        }
    }

    func requestOrderBookSnapshot()
    {
        ApiManager.apiRequest(with: .orederBook, objectType: OrderBookSnapshot.self)
        { (result) in
            
            switch result
            {
            case .success(let snapshot):
                self.snapshotLastUpdateId = snapshot.lastUpdateId
                let allAsks = self.stringArrayToOrderArray(snapshot.asks).filter { $0.quantity != zeroString }
                let allBids = self.stringArrayToOrderArray(snapshot.bids).filter { $0.quantity != zeroString }
                
                self.askOrders = allAsks
                self.bidOrders = allBids
                
//                print("snapshot asks\n\(self.askOrders)")
                
                DispatchQueue.main.async
                {
                    self.completionHandler()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateOrderBook(_ stream: OrderBookStream)
    {
        let newAsks = self.stringArrayToOrderArray(stream.asks)
        let newBids = self.stringArrayToOrderArray(stream.bids)
        
//        print("stream asks\n\(newAsks)")
        
        updateOrder(newOrders: newAsks, originOrders: &askOrders, isAsk: true)
        updateOrder(newOrders: newBids, originOrders: &bidOrders, isAsk: false)
        
//        print("updated asks\n\(self.askOrders)")
        
        self.completionHandler()
    }
    
    func updateOrder(newOrders: [Order],
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
                    
                    if newOrder.priceLevel < originOrder.priceLevel
                    {
                        newIndex = offset
                        break
                    }
                }
                
                //insert
                if isSamePrice == false && newOrder.quantity != zeroString
                {
                    originOrders.insert(newOrder, at: newIndex)
                    originOrders.popLast()
                }
            }
        }
    }
    
    func stringArrayToOrderArray(_ array: [[String]]) -> [Order]
    {
        array.map{ Order(priceLevel: $0.first!, quantity: $0.last!) }
    }
    
    func jsonStringToOrderBookStream(_ jsonString: String) -> OrderBookStream?
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
}
