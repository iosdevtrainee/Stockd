//
//  Error.swift
//  Stockd
//
//  Created by J on 1/6/19.
//  Copyright © 2019 J. All rights reserved.
//

import Foundation
struct APIError: Codable {
  public let error: Bool
  public let reason: String
}
