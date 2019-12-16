//
//  MarketHistroyViewModel.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/16.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit

class MarketHistroyViewModel: BABassClass
{
    let socketManager = WebSocketManager.init(with: SocketUrl.history)
    var historys = [MarketHistory]()
    var completionHandler: (() -> Void)! = {}
    
    override init()
    {
        super.init()
        
        socketManager.didReceiveMessageHandler =
        {[weak self] jsonString -> () in
            
            if let self = self
            {
                do
                {
                    let history = try JSONDecoder().decode(MarketHistory.self, from: jsonString.data(using: .utf8)!)
                    self.historys.insert(history, at: 0)
                    
                    if self.historys.count > maxDisplayHistoryCount
                    {
                        self.historys.popLast()
                    }
                    self.completionHandler()
                }
                catch
                {
                    print("MarketHistoryDecoder Error")
                }
            }
        }
    }
}
