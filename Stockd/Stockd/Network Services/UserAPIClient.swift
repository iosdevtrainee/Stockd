//
//  UserAPIClient.swift
//  Stockd
//
//  Created by J on 1/5/19.
//  Copyright © 2019 J. All rights reserved.
//

import Foundation
final class UserAPIClient {
  public static func authenticateUser(user:User,
                                      completion: @escaping (AppError?, AuthUser?) -> Void){
    let urlString = "\(Config.userAPIUrl)/login"
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Basic \(user.encodedCredentials)", forHTTPHeaderField: Config.authorizationHeader)
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        do {
            let user = try JSONDecoder().decode(AuthUser.self, from: data)
          completion(nil, user)
        } catch {
          if let error = try? JSONDecoder().decode(APIError.self, from: data) {
            completion(AppError.userAPIError(error.reason), nil)
          }
          completion(AppError.decodingError(error), nil)
        }
      }
    }
    task.resume()
  }
  public static func createUser(userData:Data,
                                completion: @escaping (AppError?, APIUser?) -> Void){
    let urlString = "\(Config.userAPIUrl)/users"
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = userData
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        completion(AppError.networkError(error), nil)
      }
      if let data = data {
        do {
          let user = try JSONDecoder().decode(APIUser.self, from: data)
          completion(nil, user)
        } catch {
          if let error = try? JSONDecoder().decode(APIError.self, from: data) {
              completion(AppError.userAPIError(error.reason), nil)
          }
          completion(AppError.decodingError(error), nil)
        }
      }
    }
    task.resume()
  }
  public static func addStockToWatchList(user:AuthUser,
                                         stockData:Data,
                                         completion:@escaping(AppError?,Stock?) -> Void){
    let urlString = "\(Config.userAPIUrl)/addstock"
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let bearerAuthValue = "Bearer \(user.token)"
    request.addValue(bearerAuthValue, forHTTPHeaderField: Config.authorizationHeader)
    request.httpBody = stockData
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        completion(AppError.networkError(error), nil)
      }
      if let data = data {
        do {
          let stock = try JSONDecoder().decode(Stock.self, from: data)
          completion(nil, stock)
        } catch {
          if let error = try? JSONDecoder().decode(APIError.self, from: data) {
            completion(AppError.userAPIError(error.reason), nil)
          }
          completion(AppError.decodingError(error), nil)
        }
      }
    }
    task.resume()
  }
  public static func getWatchlist(user:AuthUser,completion:@escaping(AppError?, [Stock]?) -> Void){
    let urlString = "\(Config.userAPIUrl)/watchlist"
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let bearerAuthValue = "Bearer \(user.token)"
    request.addValue(bearerAuthValue, forHTTPHeaderField: Config.authorizationHeader)
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        completion(AppError.networkError(error), nil)
      }
      if let data = data {
        do {
          let stocks = try JSONDecoder().decode([Stock].self, from: data)
          completion(nil, stocks)
        } catch {
          if let error = try? JSONDecoder().decode(APIError.self, from: data) {
            completion(AppError.userAPIError(error.reason), nil)
          }
          completion(AppError.decodingError(error), nil)
        }
      }
    }
    task.resume()
  }
}
