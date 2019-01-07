//
//  AssetNews.swift
//  Stockd
//
//  Created by J on 12/30/18.
//  Copyright © 2018 J. All rights reserved.
//

import Foundation

struct NewsStory: Codable {
  public let url: URL
  public let title: String
  public let summary: String
  struct CompanyNews:Codable {
    public let news: [NewsStory]
  }
}
