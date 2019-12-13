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
    var lastUpdateId = 0
    
    override init()
    {
        super.init()
        
        socketManager.didReceiveMessageHandler =
        { message -> () in
            let obs = self.jsonStringToOrderBookStream(message)
            if let obs = obs
            {
                self.askOrders = self.stringArrayToOrderArray(obs.asks)
                self.bidOrders = self.stringArrayToOrderArray(obs.bids)
                if let completion = self.completionHandler
                {
                    completion()
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
            case .success(let orderBookSnapshot):
                self.lastUpdateId = orderBookSnapshot.lastUpdateId
                self.askOrders = orderBookSnapshot.asks.map{ Order(priceLevel: $0.first!, quantity: $0.last!) }
                self.bidOrders = orderBookSnapshot.bids.map{ Order(priceLevel: $0.first!, quantity: $0.last!) }
                
                if let completion = self.completionHandler
                {
                    completion()
                }
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
