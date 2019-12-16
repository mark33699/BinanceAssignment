//
//  MarketHistoryModel.swift
//  BinanceAssignment
//
//  Created by iOS_Mark on 2019/12/16.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import Foundation

struct MarketHistory: Codable
{
    let time: Int
    let price: String
    let quantity: String
    let isBuyer: Bool

    enum CodingKeys: String, CodingKey
    {
        case time = "T"
        case price = "p"
        case quantity = "q"
        case isBuyer = "m"
    }
}

//struct MarketHistory: Codable
//{
//    let eventType: String
//    let eventTime: Int
//    let symbol: String
//    let aggregateTradeID: Int
//    let price: String
//    let quantity: String
//    let firstTradeID: Int
//    let lastTradeID: Int
//    let tradeTime: Int
//    let isBuyer: Bool
//
//    enum CodingKeys: String, CodingKey
//    {
//        case eventType = "e"
//        case eventTime = "E"
//        case symbol = "s"
//        case aggregateTradeID = "a"
//        case price = "p"
//        case quantity = "q"
//        case firstTradeID = "f"
//        case lastTradeID = "l"
//        case tradeTime = "T"
//        case isBuyer = "m"
//    }
//}
