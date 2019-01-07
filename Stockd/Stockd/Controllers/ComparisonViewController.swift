//
//  ComparisonViewController.swift
//  Stockd
//
//  Created by J on 1/6/19.
//  Copyright © 2019 J. All rights reserved.
//

import UIKit
import Charts
class ComparisonViewController: UIViewController {
  private var comparisonPrices = [[CompanyPrice]]()
  private var companies = [Company]()
  @IBOutlet weak var stockCollectionView: UICollectionView!
  @IBOutlet weak var comparisonChart: LineChartView!
  override func viewDidLoad() {
      super.viewDidLoad()
      stockCollectionView.dataSource = self
      stockCollectionView.delegate = self
    }

}

extension ComparisonViewController : UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return companies.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
}

extension ComparisonViewController : UICollectionViewDelegate {
  
}

extension ComparisonViewController: UICollectionViewDelegateFlowLayout{
  
}


