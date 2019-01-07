//
//  TickerInfo.swift
//  Stockd
//
//  Created by J on 12/29/18.
//  Copyright © 2018 J. All rights reserved.
//

import Foundation
struct Company: Codable {
  public let id: String
  public let ticker: String?
  public let name: String
  struct TickerInfo: Codable {
    public let companies: [Company]
  }
}

struct Stock: Codable {
  public let ticker: String
  public let id:Int?
}
