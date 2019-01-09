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
  public var timeSince1970:TimeInterval {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let date = formatter.date(from: self.date)!
    return date.timeIntervalSince1970
  }
  public static func computeReturns(prices:[Double]) -> [Double]{
    var returns = [Double]()
    for index in prices.indices {
      if index == 0 {
        continue
      }
      let previousPrice = prices[index - 1]
      let price = prices[index]
      returns.append(log(previousPrice) - log(price))
    }
    return returns
  }
}
