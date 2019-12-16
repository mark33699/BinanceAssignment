//
//  OrderBookSnapshot.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/12.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import Foundation

struct OrderBookSnapshot: Codable
{
    let lastUpdateId: Int
    let bids: [[String]]
    let asks: [[String]]
}

struct Order: Codable
{
    let priceLevel: String
    let quantity: String
}

struct OrderBookStream: Codable
{
    let eventType: String
    let eventTime: Int
    let symbol: String
    let firstUpdateID: Int
    let lastUpdateID: Int
    let bids: [[String]]
    let asks: [[String]]

    enum CodingKeys: String, CodingKey
    {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case firstUpdateID = "U"
        case lastUpdateID = "u"
        case bids = "b"
        case asks = "a"
    }
}

