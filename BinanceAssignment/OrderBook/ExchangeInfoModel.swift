//
//  ExchangeInfo.swift
//  BinanceAssignment
//
//  Created by 謝飛飛 on 2019/12/15.
//  Copyright © 2019 MarkFly. All rights reserved.
//

import Foundation

struct ExchangeInfo: Codable
{
    let code: String
    let message: String?
    let messageDetail: String?
    let data: [ExchangeInfoData]
    let success: Bool
}

struct ExchangeInfoData: Codable
{
    let baseAsset: String
    let quoteAsset: String
    let minTradeAmount: String
    let minTickSize: String
    let minOrderValue: String
    let maxMarketOrderQty: String
    let minMarketOrderQty: String?
}
