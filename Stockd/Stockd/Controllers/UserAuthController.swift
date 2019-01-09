//
//  UserAuthController.swift
//  Stockd
//
//  Created by J on 12/29/18.
//  Copyright © 2018 J. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
class UserAuthController: UIViewController {
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var googleButton: GIDSignInButton!
//  @IBOutlet weak var disconnectButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let loginButton = LoginButton(readPermissions: [.publicProfile, .adsRead,
                                                    .email, .pagesManageCta,
                                                    .readAudienceNetworkInsights])
    setupViewableButtons(loginButton)
    view.addSubview(loginButton)
    loginButton.delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self
    
//    NotificationCenter.default.addObserver(self,
//                                           selector: #selector(receiveToggleAuthUINotification(_:)),
//                                           name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
//                                           object: nil)
//    toggleAuthUI()
  }
  
  @discardableResult
  private func userSignUp(user:User) -> Bool{
    do {
      let data = try JSONEncoder().encode(user)
      UserAPIClient.createUser(userData:data) { (error, authUser) in
        if let error = error {
          Lib.presentErrorController(error:error, target: self)
        }
        self.signIn(user: user)
      }
    } catch {
      Lib.presentErrorController(error:AppError.encodingError(error), target: self)
      return false
    }
    return true
  }
  
  private func setupViewableButtons(_ loginButton: LoginButton) {
    loginButton.center = view.center
    googleButton.frame = loginButton.frame
    loginButton.center.x = view.frame.minX + (view.frame.maxX / 2) * 0.5
    loginButton.center.y = view.frame.maxY / 2
    googleButton.center.x = view.frame.maxX * 0.8
    googleButton.center.y = view.frame.maxY / 2
    loginButton.frame = CGRect(x: loginButton.frame.minX,
                               y: googleButton.frame.minY,
                               width: loginButton.frame.width,
                               height: loginButton.frame.height * 1.35)
    loginButton.center.y = googleButton.center.y
  }
  
  private func signIn(user:User){
    UserAPIClient.authenticateUser(user: user) { (error, authUser) in
      if let user = authUser {
        UserDefaults.standard.set(user.token,
                                  forKey:Config.userDefaultsTokenKey)
        UserDefaults.standard.set(user.tokenExpiry,
                                  forKey:Config.userDefaultsTokenExp)
        DispatchQueue.main.async {
          let storyboard = UIStoryboard(name: Config.storyboardName, bundle: nil)
          let tabBarVC = storyboard.instantiateViewController(withIdentifier: Config.tabBarVCName)
          self.present(tabBarVC,animated: true) { userLoggedIn = true }
          return
        }
      }
      if let error = error {
        Lib.presentErrorController(error:AppError.encodingError(error), target: self)
      }
    }
  }
  
  
  @IBAction func transitionToSignUpVC(_ sender: UIBarButtonItem) {
    Lib.transitionToVC(nextVCType: .signUp, vcData: nil, target: self)
  }
  
  
  @IBAction func onSignIn(_ sender: UIButton) {
    guard let email = usernameField.text,
      let password = passwordField.text else { return }
    
    let user = User.init(email: email,
                         password: password,
                         verifyPassword: nil, token: nil)
    signIn(user: user)
  }
  
//  @IBAction func didTapDisconnect(_ sender: AnyObject) {
//    GIDSignIn.sharedInstance().disconnect()
//  }

//  func toggleAuthUI() {
//    if GIDSignIn.sharedInstance().hasAuthInKeychain() {
//      signInButton.isHidden = true
//      signOutButton.isHidden = false
//      disconnectButton.isHidden = false
//    } else {
//      signInButton.isHidden = false
//      signOutButton.isHidden = true
//      disconnectButton.isHidden = true
//    }
//  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self,
                                              name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                              object: nil)
  }
  
//  @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
//    if notification.name.rawValue == "ToggleAuthUINotification" {
//      self.toggleAuthUI()
//    }
//  }
  
}
//TODO: Make a Local Account for Facebook users
extension UserAuthController: LoginButtonDelegate {
  func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
    switch result {
    case .failed(let error):
      print(error)
    case .cancelled:
      print("User cancelled login.")
    case .success(let grantedPermissions, let declinedPermissions, let accessToken):
      break
    }
  }
  
  func loginButtonDidLogOut(_ loginButton: LoginButton) {
    userLoggedIn = false
  }
}

extension UserAuthController: GIDSignInUIDelegate {
  
}

extension UserAuthController: UserAuthDelegate {
  func signOut(completion: (Bool) -> Void) {
    UserDefaults.standard.removeObject(forKey: Config.userDefaultsTokenExp)
    UserDefaults.standard.removeObject(forKey: Config.userDefaultsTokenKey)
    userLoggedIn = false
    Lib.transitionToVC(nextVCType: .userAuth, vcData: nil, target: self)
  }
  func signIn(user: User, completion: (Bool) -> Void) {
    signIn(user: user)
    completion(true)
  }
  func signUp(user: User, completion:(Bool) -> Void){
    let success = userSignUp(user: user)
    completion(success)
  }
}
