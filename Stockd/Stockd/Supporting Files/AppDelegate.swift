//
//  AppDelegate.swift
//  Stockd
//
//  Created by J on 12/28/18.
//  Copyright © 2018 J. All rights reserved.
//

import UIKit
import FacebookCore
import GoogleSignIn
import UserNotifications
var userLoggedIn = false {
  didSet {
    UserDefaults.standard.set(userLoggedIn, forKey:Config.userDefaultLoginKey)
  }
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  weak var googleUserDelegate: UserAuthDelegate?
  
  @discardableResult
  private func setupFBSignAPI(_ application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
    return SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func transitionToVC(viewController:UIViewController) {
    self.window?.rootViewController = viewController
    self.window?.makeKeyAndVisible()
  }
  
  private func setupGoogleSignAPI() {
    GIDSignIn.sharedInstance().clientID = "661598427566-04kh7bf54p68b74l9ak2f01amnak6uvg.apps.googleusercontent.com"
    GIDSignIn.sharedInstance().delegate = self
  }
  
  private func googleOpenURLAccess(_ url:URL,options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url,
                                             sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                             annotation: options[UIApplication.OpenURLOptionsKey.annotation])
  }
  
  func registerForRichNotifications() {
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted, error) in
      if let error = error {
        print(error.localizedDescription)
      }
      UserDefaults.standard.set(granted,forKey: Config.userDefaultsNotificationsKey)
    }
    
    let action1 = UNNotificationAction(identifier: "stockAction", title: "Stock Action", options: [.foreground])
    
    let category = UNNotificationCategory(identifier: "actionCategory", actions: [action1], intentIdentifiers: [], options: [])
    
    UNUserNotificationCenter.current().setNotificationCategories([category])
    
  }
  
  private func fBOpenURLAcess(_ url:URL,options: [UIApplication.OpenURLOptionsKey : Any],app: UIApplication) -> Bool {
    return SDKApplicationDelegate.shared.application(app, open: url, options: options)
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    registerForRichNotifications()
    let storyboard = UIStoryboard(name: Config.storyboardName, bundle: nil)
    userLoggedIn = UserDefaults.standard.bool(forKey: Config.userDefaultLoginKey)
    if userLoggedIn {
      let tabBarVC = storyboard.instantiateViewController(withIdentifier: Config.tabBarVCName)
      transitionToVC(viewController: tabBarVC)
      return true
    }
    guard let signInVC = storyboard.instantiateViewController(withIdentifier: Config.userAuthVC) as?
      UserAuthController else { return true }
    googleUserDelegate = signInVC
    setupGoogleSignAPI()
    setupFBSignAPI(application, launchOptions)
    transitionToVC(viewController: signInVC)
    return true
  }
  
  
  
  private func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return fBOpenURLAcess(url, options: options, app: app) && googleOpenURLAccess(url, options: options)
    
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}
extension AppDelegate : GIDSignInDelegate {
  
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    
  }
  
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
            withError error: Error!) {
    if let error = error {
      let alert = UIAlertController.errorAlert(error: AppError.invalidLogin(error.localizedDescription))
      transitionToVC(viewController: alert)
    } else {
      guard let clientID = user.userID,                  // For client-side use only!
        let idToken = user.authentication.idToken, // Safe to send to the server
        let _ = user.profile.name,
        let _ = user.profile.givenName,
        let _ = user.profile.familyName,
        let email = user.profile.email  else { return }
      // TODO: Create
      let password = idToken + clientID
      let newUser = User.init(email: email, password: password, verifyPassword: password, token: nil)
      googleUserDelegate?.signUp(user: newUser, completion: { (success) in
        if success {
          googleUserDelegate?.signIn(user: newUser) { success in
            if success {
              let storyboard = UIStoryboard(name: Config.storyboardName, bundle: nil)
              let tabBarVC = storyboard.instantiateViewController(withIdentifier: Config.tabBarVCName)
              transitionToVC(viewController: tabBarVC)
            }
          }
        }
      })
    }
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    print(response.notification.request.content.userInfo)
    switch response.actionIdentifier {
    case Config.notificationID:
      let storyboard = UIStoryboard(name: Config.storyboardName, bundle: nil)
      let tabBarVC = storyboard.instantiateViewController(withIdentifier: Config.tabBarVCName)
      transitionToVC(viewController: tabBarVC)
    case "stockAction":
      let storyboard = UIStoryboard(name: Config.storyboardName, bundle: nil)
      let tabBarVC = storyboard.instantiateViewController(withIdentifier: Config.tabBarVCName)
      transitionToVC(viewController: tabBarVC)
    default:
      break
    }
    completionHandler()
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .badge, .sound])
  }
}
