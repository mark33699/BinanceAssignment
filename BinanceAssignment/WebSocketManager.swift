//
//  WebSocketManager.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/11.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import UIKit
import Starscream

class WebSocketManager: BABassClass, WebSocketDelegate
{
    var socket: WebSocket!
    
    override init()
    {
        super.init()
        
        var request = URLRequest(url: URL(string: "wss://stream.binance.com:9443/ws/bnbbtc@depth")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func websocketDidConnect(socket: WebSocketClient)
    {
        print("🎉websocket is connected🎉")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?)
    {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
             print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String)
    {
//        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data)
    {
//        print("Received data: \(data.count)")
    }
}
