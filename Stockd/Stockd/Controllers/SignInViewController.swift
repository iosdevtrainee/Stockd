//
//  SignInViewController.swift
//  Stockd
//
//  Created by J on 12/29/18.
//  Copyright © 2018 J. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
class SignInViewController: UIViewController {
  @IBOutlet weak var confirmationView: UIStackView!
  @IBOutlet weak var verifyPasswordField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var registrationButton: UIButton!
  @IBOutlet weak var signInButton: UIButton!
  
  @IBOutlet weak var googleButton: GIDSignInButton!
  @IBOutlet weak var signOutButton: UIButton!
  @IBOutlet weak var disconnectButton: UIButton!
  override func viewDidLoad() {
    title = "test"
    super.viewDidLoad()
    let loginButton = LoginButton(readPermissions: [.publicProfile, .adsRead,
                                                    .email, .pagesManageCta,
                                                    .readAudienceNetworkInsights])
    loginButton.frame = signInButton.frame
//    loginButton.center = view.center
    loginButton.center.x = view.frame.minX + (view.frame.maxX / 2) * 0.5
    loginButton.center.y = view.frame.maxY / 2
//    signInButton.transform.scaledBy(x: 1.1, y: 1.1)
    signInButton.center.x = view.frame.maxX * 0.8
    signInButton.center.y = view.frame.maxY / 2

    
    
    view.addSubview(loginButton)
    loginButton.delegate = self
    GIDSignIn.sharedInstance().uiDelegate = self
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(receiveToggleAuthUINotification(_:)),
                                           name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                           object: nil)
//    toggleAuthUI()
  }
  
  private func userSignUp(user:User) {
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
    }
  }
  
  private func updateViews(message:String){
    title = message
  }
  
  @IBAction func showSignIn(_ sender: UIBarButtonItem) {
    if !confirmationView.isHidden {
      confirmationView.isHidden = true
    }
    registrationButton.isHidden = true
    signInButton.isHidden = false
    updateViews(message: "Sign In")
  }
  
  @IBAction func showSignUp(_ sender: Any) {
    if confirmationView.isHidden {
      confirmationView.isHidden = false
    }
    updateViews(message: "Sign Up")
    signInButton.isHidden = true
    registrationButton.isHidden = false
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
  
  
  @IBAction func onSignIn(_ sender: UIButton) {
    guard let email = usernameField.text,
      let password = passwordField.text else { return }
    
    let user = User.init(email: email,
                         password: password,
                         verifyPassword: nil, token: nil)
    signIn(user: user)
  }
  
  @IBAction func didTapDisconnect(_ sender: AnyObject) {
    GIDSignIn.sharedInstance().disconnect()
  }

  func toggleAuthUI() {
    if GIDSignIn.sharedInstance().hasAuthInKeychain() {
      signInButton.isHidden = true
      signOutButton.isHidden = false
      disconnectButton.isHidden = false
    } else {
      signInButton.isHidden = false
      signOutButton.isHidden = true
      disconnectButton.isHidden = true
    }
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self,
                                              name: NSNotification.Name(rawValue: "ToggleAuthUINotification"),
                                              object: nil)
  }
  
  @objc func receiveToggleAuthUINotification(_ notification: NSNotification) {
    if notification.name.rawValue == "ToggleAuthUINotification" {
      self.toggleAuthUI()
    }
  }
  
  
  
}
extension SignInViewController: LoginButtonDelegate {
  func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
    switch result {
    case .failed(let error):
      print(error)
    case .cancelled:
      print("User cancelled login.")
    case .success/*(let grantedPermissions, let declinedPermissions, let accessToken)*/:
      let storyboard = UIStoryboard(name: Config.storyboardName, bundle: nil)
      let searchVC = storyboard
        .instantiateViewController(withIdentifier: Config.tabBarVCName)
      self.present(searchVC, animated: true) { userLoggedIn = true}
    }
  }
  
  func loginButtonDidLogOut(_ loginButton: LoginButton) {
    userLoggedIn = false
  }
}

extension SignInViewController: GIDSignInUIDelegate {
  
}

extension SignInViewController: UserAuthDelegate {
  func signOut(completion: (Bool) -> Void) {
    UserDefaults.standard.removeObject(forKey: Config.userDefaultsTokenExp)
    UserDefaults.standard.removeObject(forKey: Config.userDefaultsTokenKey)
    userLoggedIn = false
    Lib.transitionToVC(nextVCType: .signIn, vcData: nil, target: self)
  }
  func signIn(user: User, completion: (Bool) -> Void) {
    signIn(user: user)
    completion(true)
  }
}
