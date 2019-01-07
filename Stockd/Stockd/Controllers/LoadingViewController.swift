//
//  ViewController.swift
//  Stockd
//
//  Created by J on 12/28/18.
//  Copyright © 2018 J. All rights reserved.
//

import UIKit
import Lottie
class ViewController: UIViewController {
  private var nextController: UIViewController?
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let lottieView = LOTAnimationView(filePath: "loading")
    self.view.addSubview(lottieView)
    lottieView.play()
    if let nextVC = nextController {
      transition(timeToTransition: 3, viewController: nextVC)
    }
  }
  private func transition(timeToTransition:Double, viewController:UIViewController){
    Timer.scheduledTimer(timeInterval: timeToTransition, target: self,
                         selector: #selector(transitionToNextVC),
                         userInfo: viewController, repeats: false)
  }
  @objc private func transitionToNextVC(userInfo:Timer){
    guard let viewController = userInfo.userInfo as? UIViewController else { return }
    present(viewController, animated: true, completion: nil)
  }
  

}

