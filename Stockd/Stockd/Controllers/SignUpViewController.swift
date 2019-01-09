//
//  SignUpViewController.swift
//  Stockd
//
//  Created by J on 1/9/19.
//  Copyright © 2019 J. All rights reserved.
//

import UIKit
import FacebookLogin
import GoogleSignIn
import FacebookCore

class SignUpViewController: UIViewController {
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var verifyPasswordField: UITextField!
  weak var userAuthDelegate: UserAuthDelegate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    }
  
  @IBAction func onSignUp(_ sender: UIButton) {
    guard let email = usernameField.text,
      let password = passwordField.text,
      let verifyPassword = verifyPasswordField.text else { return }
    let storyboard = UIStoryboard(name: Config.storyboardName, bundle: nil)
    guard let userAuthVC =  storyboard.instantiateViewController(withIdentifier: Config.userAuthVC) as? UserAuthController else { return }
    userAuthDelegate = userAuthVC
    let user = User.init(email: email,
                         password: password,
                         verifyPassword: verifyPassword, token: nil)
    userAuthDelegate.signUp(user: user) { (success) in
      if success {
        Lib.transitionToVC(nextVCType: .tabBar , vcData: nil, target: self)
      }
    }
  }
  
  @IBAction func transitionToSignUpVC(_ sender: UIBarButtonItem) {
    Lib.transitionToVC(nextVCType: .userAuth, vcData: nil, target: self)
  }
}
