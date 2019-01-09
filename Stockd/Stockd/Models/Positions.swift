//
//  Positions.swift
//  Stockd
//
//  Created by J on 1/9/19.
//  Copyright © 2019 J. All rights reserved.
//

import Foundation
enum Position:Int {
  case first = 0
  case second
  case third
  
  public func next() -> Position {
    switch self {
    case .first:
      return .second
    case .second:
      return .third
    case .third:
      return .third
    }
  }
  public func previous() -> Position {
    switch self {
    case .first:
      return .first
    case .second:
      return .first
    case .third:
      return .second
    }
  }
  
}
