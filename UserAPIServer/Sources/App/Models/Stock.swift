//
//  Stock.swift
//  App
//
//  Created by J on 1/6/19.
//

import FluentSQLite
import Vapor

final class Stock : SQLiteModel {
  // id to be created by the SQLite database
  var id: Int? 
  // stock ticker passed by the user
  var ticker: String
  // user who owns this list
  var userID: User.ID
  
  init(id:Int? = nil, stockTicker: String, userID: User.ID){
    self.id = id
    self.ticker = stockTicker
    self.userID = userID
  }
}

extension Stock: Migration {
  static func prepare(on conn: SQLiteConnection) -> Future<Void> {
    return SQLiteDatabase.create(Stock.self, on: conn) { (builder) in
      builder.field(for: \.id, isIdentifier: true)
      builder.field(for: \.ticker)
      builder.field(for: \.userID)
      builder.reference(from: \.userID, to: \User.id)
    }
  }
}

extension Stock {
  var user: Parent<Stock, User> {
    // The foreign key between both the Stock and User must
    // be used here to refer to the parent
    return parent(\.userID)
  }
}

extension Stock : Content { }

extension Stock : Parameter { }
