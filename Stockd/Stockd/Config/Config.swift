//
//  Config.swift
//  Stockd
//
//  Created by J on 1/5/19.
//  Copyright © 2019 J. All rights reserved.
//

import Foundation

struct Config {
  public static let priceAPIUrl = ""
  public static let userAPIUrl = "http://localhost:8080"
  public static let watchCellName = "watchCell"
  public static let newsCellName = "newsCell"
  public static let economicsCellName = "economicsCell"
  public static let chartText = "Stock Prices"
  public static let authorizationHeader = "Authorization"
  public static let contentTypeHeader = "Content-Type"
  public static let jsonContentHeader = "application/json"
  public static let userDefaultLoginKey = "LoggedIn"
  public static let userDefaultsTokenKey = "TokenID"
  public static let userDefaultsTokenExp = "TokenExpiry"
  public static let storyboardName = "Main"
  public static let stockVCName = "StockVC"
  public static let signInVCName = "SignInVC"
  public static let searchVCName = "SearchVC"
  public static let tabBarVCName = "TabBarVC"
  public static let watchListVCName = "WatchListVC"
  public static let economicsVCName = "EconomicsVC"
  public static let compVCName = "CompVC"
}
