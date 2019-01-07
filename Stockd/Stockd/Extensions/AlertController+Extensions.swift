//
//  AlertController+Extensions.swift
//  Stockd
//
//  Created by J on 1/6/19.
//  Copyright © 2019 J. All rights reserved.
//

import UIKit

extension UIAlertController {
  static func errorAlert(error:ErrorProtocol) -> UIAlertController {
    let alert = UIAlertController(title: "Error", message: error.errorMessage, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    return alert
  }
}
