//
//  Model.swift
//  CashAppStocks
//
//  Created by Ngoc Nguyen on 7/11/23.
//

import Foundation

struct StockResponse: Codable {
    let stocks: [Stock]
}

struct Stock: Codable {
    let ticker: String
    let name: String
    let currency: String
    let currentPriceCents: Int
    let quantity: Int?
    let currentPriceTimestamp: Int
}
