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
        
        requestMarketHistory()
        
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

    private func requestMarketHistory()
    {
        ApiManager.apiRequest(with: ApiUrl.history, objectType: [MarketHistory].self)
        { (result) in
            
            switch result
            {
            case .success(let historys):
                
                self.historys.insert(contentsOf: historys.reversed(), at: 0)

                if self.historys.count > maxDisplayHistoryCount
                {
                    self.historys = Array(self.historys[0..<maxDisplayHistoryCount])
                }
                
                DispatchQueue.main.async
                {
                    self.completionHandler()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
