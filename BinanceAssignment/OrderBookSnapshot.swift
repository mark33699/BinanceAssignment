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
