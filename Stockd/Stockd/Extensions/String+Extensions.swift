//
//  String+Extensions.swift
//  Stockd
//
//  Created by J on 1/6/19.
//  Copyright © 2019 J. All rights reserved.
//

import Foundation
extension String {
  func toBase64() -> String {
    guard let data = self.data(using: String.Encoding.utf8) else {
      return ""
    }
    return data.base64EncodedData(options: .init(rawValue: 0)).base64EncodedString()
  }
}
