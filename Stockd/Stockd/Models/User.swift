//
//  User.swift
//  Stockd
//
//  Created by J on 1/6/19.
//  Copyright © 2019 J. All rights reserved.
//

import Foundation

struct User: Codable {
  public let email: String
  public let password: String
  public let verifyPassword: String?
  public var token: String?
  public var encodedCredentials: String {
    let credentials = "\(email):\(password)"
    guard let data = credentials.data(using: String.Encoding.utf8) else {
      return ""
    }
    return data.base64EncodedString(options: .init(rawValue: 0))
  }
}

struct AuthUser: Codable {
  public var token: String
  public let tokenExpiry: String
}

struct APIUser: Codable {
  public let email: String
}
