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
      let compVC = vc as! ComparisonViewController
      if let companies = vcData as? [Company] {
        compVC.companies = companies
        target.present(compVC, animated: true, completion: nil)
        return 
      }
    case .economics:
      let _ = vc as! EconomicsViewController
      
    case .search:
      let _ = vc as! SearchViewController
    case .userAuth:
      let _ = vc as! UserAuthController
    case .stock:
      let _ = vc as! StockViewController
    case .watchlist:
      let _ = vc as! WatchListController
    case .tabBar:
      vc = vc as! UITabBarController
    case .signUp:
      let _ = vc as! SignUpViewController
    case .loading:
      let loading = vc as! LoadingViewController
      if let nextVC = vcData as? UIViewController {
        loading.nextController = nextVC
        target.present(nextVC, animated: true, completion: nil)
        return
      }
      let tabBarVC = storyboard.instantiateViewController(withIdentifier: Config.tabBarVCName)
      loading.nextController = tabBarVC
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
  
  public static func getAuthUser() -> AuthUser? {
    
    let defaults = UserDefaults.standard
    guard let token = defaults.object(forKey: Config.userDefaultsTokenKey) as? String,
      let tokenExpiry = defaults.object(forKey: Config.userDefaultsTokenExp) as? String else {
      return nil
    }
    return AuthUser.init(token:token,tokenExpiry:tokenExpiry)
  }
}
