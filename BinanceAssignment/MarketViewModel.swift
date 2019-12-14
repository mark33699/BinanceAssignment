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
                    self.updataOrderBook(stream)
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
                
//                self.askOrders = Array(allAsks.prefix(maxDisplayOrderCount))
//                self.bidOrders = Array(allBids.prefix(maxDisplayOrderCount))
                
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
    
    func updataOrderBook(_ stream: OrderBookStream)
    {
        let newAsks = self.stringArrayToOrderArray(stream.asks)
        let newBids = self.stringArrayToOrderArray(stream.bids)
        
//        print("stream asks\n\(newAsks)")
        
        for newOrder: Order in newAsks
        {
            if newOrder.priceLevel < askOrders.last!.priceLevel
            {
                var isSamePrice = false
                var newIndex = 0
                
                //replace
                for (offset, originOrder) in askOrders.enumerated()
                {
                    if newOrder.priceLevel == originOrder.priceLevel
                    {
                        if newOrder.quantity == zeroString
                        {
                            askOrders.remove(at: offset)
                        }
                        else
                        {
                            askOrders[offset] = newOrder
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
                    askOrders.insert(newOrder, at: newIndex)
                    askOrders.popLast()
                }
            }
        }

//        print("updated asks\n\(self.askOrders)")
        
        self.completionHandler()
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
