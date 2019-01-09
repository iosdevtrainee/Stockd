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
  public var companies = [Company]()
  @IBOutlet weak var stockCollectionView: UICollectionView!
  @IBOutlet weak var comparisonChart: LineChartView!
  override func viewDidLoad() {
    super.viewDidLoad()
//    stockCollectionView.dataSource = self
//    stockCollectionView.delegate = self
    companies.forEach { company in
      IntrinioAPI.getCompanyPrices(ticker:company.ticker!) { (error, prices) in
        if let error = error {
          Lib.presentErrorController(error:error, target:self)
        }
        if let prices = prices {
          self.comparisonPrices.append(prices)
        }
        DispatchQueue.main.async {
          self.renderChart(companiesPrices: self.comparisonPrices)
        }
      }
    }
    
  }
    
  private func renderChart(companiesPrices:[[CompanyPrice]], prices:Bool = true){
    var dataset:[LineChartDataSet]
    if prices {
       dataset = companiesPrices.map { (prices) -> LineChartDataSet in
          let values = prices.indices.map { (index) in
            ChartDataEntry(x: Double(index), y: prices[index].close)
        }
          let set = LineChartDataSet(values: values, label: nil)
          set.mode = .cubicBezier
          set.drawCircleHoleEnabled = false
          set.drawCirclesEnabled = false
          set.drawFilledEnabled = true
          set.fillAlpha = 0.2
          set.fillColor = .blue
          return set
      }
    } else {
      let stockReturns = companiesPrices.map { (companyPrices:[CompanyPrice]) -> [Double] in
        let closingPrices = companyPrices.map { $0.close }
        return CompanyPrice.computeReturns(prices: closingPrices)
      }
       dataset = stockReturns.map { (returns) -> LineChartDataSet in
        let values = returns.indices.map { (index) in
          ChartDataEntry(x: Double(index), y: returns[index])
        }
        let set = LineChartDataSet(values: values, label: nil)
        set.mode = .cubicBezier
        set.drawCircleHoleEnabled = false
        set.drawCirclesEnabled = false
        set.drawFilledEnabled = true
        set.fillAlpha = 0.2
        set.fillColor = .blue
        return set
      }
    }
      let lineChartData = LineChartData(dataSets: dataset)
      let xAxis = comparisonChart.xAxis
      xAxis.valueFormatter = DateValueFormatter()
      xAxis.labelPosition = .bottom
      comparisonChart.data = lineChartData
      comparisonChart.drawGridBackgroundEnabled = false
      comparisonChart.chartDescription?.text = Config.chartText
    }
  @IBAction func backButton(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  @IBAction func showReturns(_ sender: UIButton) {
    renderChart(companiesPrices: comparisonPrices, prices: false)
  }
  
  @IBAction func showPrices(_ sender: UIButton) {
    renderChart(companiesPrices: comparisonPrices, prices: true)
  }
  
}




//extension ComparisonViewController : UICollectionViewDataSource {
//  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//    return companies.count
//  }
//  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    return UICollectionViewCell()
//  }
//}
//
//extension ComparisonViewController : UICollectionViewDelegate {
//
//}



