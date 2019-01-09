//
//  UserAuthDelegate.swift
//  
//
//  Created by J on 1/7/19.
//

import Foundation
protocol UserAuthDelegate: class {
  func signOut(completion:(Bool) -> Void)
  func signIn(user:User, completion:(Bool) -> Void)
  func signUp(user:User, completion:(Bool) -> Void)
}
