//
//  CompanyPrices.swift
//  Stockd
//
//  Created by J on 12/29/18.
//  Copyright © 2018 J. All rights reserved.
//

import Foundation

struct CompanyPrice: Codable {
  struct PriceAPI:Codable {
    public let stock_prices: [CompanyPrice]
  }
  public let date: String
  public let open: Double
  public let high: Double
  public let close: Double
  public let volume: Int
  public let adj_open: Double
  public let adj_high: Double
  public let adj_close: Double
  public let adj_volume: Int
}
