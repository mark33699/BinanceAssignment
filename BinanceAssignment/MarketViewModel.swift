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
    var askOrders = [Order]()
    var bidOrders = [Order]()
    var lastUpdateId = 0

    func requestOrderBookSnapshot(completion: @escaping (() -> Void) = {})
    {
        ApiManager.apiRequest(with: .orederBook, objectType: OrderBookSnapshot.self)
        { (result) in
            
            switch result
            {
            case .success(let orderBookSnapshot):
                self.lastUpdateId = orderBookSnapshot.lastUpdateId
                self.askOrders = orderBookSnapshot.asks.map{ Order(priceLevel: $0.first!, quantity: $0.last!) }
                self.bidOrders = orderBookSnapshot.bids.map{ Order(priceLevel: $0.first!, quantity: $0.last!) }
                
                completion()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
