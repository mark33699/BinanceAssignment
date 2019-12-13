//
//  MarketViewModel.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/12.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit

class MarketViewModel: BABassClass
{
    var completionHandler: (() -> Void)?
    
    let socketManager = WebSocketManager.init(with: "wss://stream.binance.com:9443/ws/bnbbtc@depth")
    
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
                    self.askOrders = self.stringArrayToOrderArray(stream.asks)
                    self.bidOrders = self.stringArrayToOrderArray(stream.bids)

                    if let completion = self.completionHandler
                    {
                        completion()
                    }
                }
            }
        }
    }

    //snapshot just for lastUpdateId ?
    func requestOrderBookSnapshot()
    {
        ApiManager.apiRequest(with: .orederBook, objectType: OrderBookSnapshot.self)
        { (result) in
            
            switch result
            {
            case .success(let orderBookSnapshot):
                self.snapshotLastUpdateId = orderBookSnapshot.lastUpdateId
            case .failure(let error):
                print(error.localizedDescription)
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
