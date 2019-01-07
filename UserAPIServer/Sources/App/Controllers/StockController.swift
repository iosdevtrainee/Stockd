//
//  StockController.swift
//  App
//
//  Created by J on 1/6/19.
//

import Vapor
import FluentSQLite

final class StockController {
  // return all the stocks associated with the current user
  
  func allStocks(_ req: Request) throws -> Future<[StockResponse]> {
    let user = try req.requireAuthenticated(User.self)
    
    return try Stock.query(on: req)
    .filter(\.userID == user.requireID()).all()
    .map { stocks in
      return stocks.map { StockResponse(ticker: $0.ticker, id: $0.id!)}
    }
  }
  
  func addStock(_ req: Request) throws -> Future<Stock> {
    let user = try req.requireAuthenticated(User.self)
    
    return try req.http.body.data.flatMap { data -> Future<Stock> in
      guard let stock = try? JSONDecoder().decode(CreateStockRequest.self, from: data) else {
        throw Abort(HTTPResponseStatus.init(statusCode: 499, reasonPhrase: "Bad Data"))
      }
      
      return try Stock(stockTicker: stock.ticker, userID: user.requireID()).save(on: req)
    }!
  }
  
  func removeStock(_ req: Request) throws -> Future<HTTPStatus> {
    let user = try req.requireAuthenticated(User.self)
    
    return try req.parameters.next(Stock.self).flatMap { stock -> Future<Void> in
      guard try user.requireID() == stock.requireID() else {
        throw Abort(.forbidden)
      }
      
      return stock.delete(on: req)
    }.transform(to: HTTPStatus.init(statusCode: 259, reasonPhrase: "Delete Successful"))

  }
}



struct CreateStockRequest: Content {
  public var ticker: String
}

struct StockResponse: Content {
  public var ticker: String
  public var id: User.ID
}
