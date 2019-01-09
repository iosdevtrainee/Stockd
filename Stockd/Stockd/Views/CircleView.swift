//
//  CircleView.swift
//  Stockd
//
//  Created by J on 1/7/19.
//  Copyright © 2019 J. All rights reserved.
//

import UIKit

class CircleView: UILabel {
  private let size: CGFloat = 100
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setUpView()
  }
  
  override func awakeFromNib() {
    setUpView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUpView()
   // fatalError("init(coder:) has not been implemented")
  }
  
  private func setUpView() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .black
    text = ""
    textAlignment = .center
    isHidden = true
    textColor = .white
    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: size),
      heightAnchor.constraint(equalToConstant: size)
      ])
    
    layer.cornerRadius = size / 2
  }
  
}
