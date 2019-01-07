//
//  IntrinioAPIClient.swift
//  Stockd
//
//  Created by J on 12/29/18.
//  Copyright © 2018 J. All rights reserved.
//

import Foundation
final class IntrinioAPI {
  
  public static func searchCompanies(keyword: String, completion:@escaping (AppError?, [Company]?) -> Void){
    guard let keyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      return
    }
    let url = "https://api-v2.intrinio.com/companies/search?query=\(keyword)&api_key=\(SecretKeys.intrinioKey)"
    NetworkHelper.performDataTask(urlString: url, httpMethod: "GET") { (error, data, response) in
      if let error = error {
        completion(AppError.networkError(error), nil)
      }
      if let data = data {
        do {
          let apiData = try JSONDecoder().decode(Company.TickerInfo.self, from: data)
          completion(nil, apiData.companies)
        } catch {
          completion(AppError.decodingError(error), nil)
        }
      }
    }
  }
  
  public static func allCompanies(completion:@escaping (AppError?, [Company]?) -> Void) {
    
    let url = "https://api-v2.intrinio.com/companies?api_key=\(SecretKeys.intrinioKey)"
    NetworkHelper.performDataTask(urlString: url, httpMethod: "GET") { (error, data, response) in
      if let error = error {
        completion(AppError.networkError(error), nil)
      }
      if let data = data {
        do {
          let apiData = try JSONDecoder().decode(Company.TickerInfo.self, from: data)
          completion(nil, apiData.companies)
        } catch {
          completion(AppError.decodingError(error), nil)
        }
      }
    }
  }
  public static func getCompanyPrices(ticker:String,
                                      start:String? = nil,
                                      end:String? = nil,
                                      pageSize:Int = 50,
                                      completion: @escaping (AppError?, [CompanyPrice]?) -> Void){
    var url = "https://api-v2.intrinio.com/securities/\(ticker)/prices?api_key=\(SecretKeys.intrinioKey)&page_size=\(pageSize)"
    if let startDate = start, let endDate = end  {
      url += "&start_date=\(startDate)&end_date=\(endDate)"
    }
    NetworkHelper.performDataTask(urlString: url, httpMethod: "GET") { (error, data, response) in
      if let error = error {
        completion(AppError.networkError(error), nil)
      }
      if let data = data {
        do {
          let apiData = try JSONDecoder().decode(CompanyPrice.PriceAPI.self, from: data)
          completion(nil, apiData.stock_prices)
        } catch {
          completion(AppError.decodingError(error), nil)
        }
      }
    }
  }
  public static func getCompanyNews(ticker:String,
                                    completion:@escaping(AppError?, [NewsStory]?) -> Void){
    let url = "https://api-v2.intrinio.com/companies/\(ticker)/news?api_key=\(SecretKeys.intrinioKey)"
    NetworkHelper.performDataTask(urlString: url, httpMethod: "GET") { (error, data, response) in
      if let error = error {
        completion(AppError.networkError(error), nil)
      }
      if let data = data {
        do {
          let apiData = try JSONDecoder().decode(NewsStory.CompanyNews.self, from: data)
          completion(nil, apiData.news)
        } catch {
          completion(AppError.decodingError(error), nil)
        }
      }
    }
  }
}

