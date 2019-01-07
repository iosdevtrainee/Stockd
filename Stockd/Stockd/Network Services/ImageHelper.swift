//
//  ImageHelper.swift
//  MeetupEvents
//
//  Created by J on 12/14/18.
//  Copyright © 2018 Alex Paul. All rights reserved.
//

import UIKit
final class ImageHelper {
  static func fetch(urlString:String?, completion:@escaping (Error?, UIImage?) -> Void) {
    guard  let urlString = urlString else {
      completion(Error.self as? Error, nil)
      return
    }
    NetworkHelper.performDataTask(urlString: urlString, httpMethod: "GET") {(error, data, response) in
      if let error = error {
        completion(error, nil)
      }
      if let data = data {
        let image = UIImage(data: data)
        DispatchQueue.main.async {
          completion(nil, image)
        }
      }
    }
  }
  // NSCache - a dictionary that has the ability to chace transient data for
  // performance improvements
  // We'll use a singleton to build a wrapper around NSCache
}


