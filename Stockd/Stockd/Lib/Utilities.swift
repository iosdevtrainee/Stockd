//
//  Utilities.swift
//  Stockd
//
//  Created by J on 1/7/19.
//  Copyright © 2019 J. All rights reserved.
//

import UIKit
struct Lib {
  public static func transitionToVC(nextVCType:Navigation, vcData:Any?, target:UIViewController) {
    let storyboard = UIStoryboard(name:Config.storyboardName, bundle:nil)
    var vc = storyboard.instantiateViewController(withIdentifier: nextVCType.rawValue)
    switch nextVCType {
    case .compare:
      vc = vc as! ComparisonViewController
    case .economics:
      vc = vc as! EconomicsViewController
    case .search:
      vc = vc as! SearchViewController
    case .signIn:
      vc = vc as! SignInViewController
    case .stock:
      vc = vc as! StockViewController
    case .watchlist:
      vc = vc as! WatchListController
    }
    target.present(vc, animated: true, completion: nil)
  }
  
  public static func presentErrorController(error:AppError, target:UIViewController){
    DispatchQueue.main.async {
      let alertVC = UIAlertController.errorAlert(error: error)
      target.present(alertVC, animated: true, completion: nil)
      return
    }
  }
  
}
