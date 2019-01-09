//
//  HomeViewController.swift
//  Stockd
//
//  Created by J on 12/29/18.
//  Copyright © 2018 J. All rights reserved.
//

import UIKit
import Charts
import SafariServices
class StockViewController: UIViewController {
  @IBOutlet weak var navTitleLabel: UINavigationItem!
  @IBOutlet weak var assetNewsTable: UITableView!
  @IBOutlet weak var stockChart: LineChartView!
  public var company: Company?
  private var news = [NewsStory]() {
    didSet {
      DispatchQueue.main.async {
          self.assetNewsTable.reloadData()
      }
    }
  }
  private var assetPrices = [CompanyPrice]() {
    didSet {
      DispatchQueue.main.async {
          self.renderChart(prices: self.assetPrices)
      }
    }
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      assetNewsTable.delegate = self
      assetNewsTable.dataSource = self
      guard let ticker = company?.ticker else { return }
      navigationItem.title = ticker
      getNews(ticker: ticker)
      getPrices(ticker: ticker)
      navTitleLabel.title = ticker
      
        // Do any additional setup after loading the view.
    }
  
  private func getPrices(ticker:String){
    IntrinioAPI.getCompanyPrices(ticker: ticker) { (error, prices) in
      if let error = error {
        let alertVC = UIAlertController.errorAlert(error: error)
        self.present(alertVC, animated: true, completion: nil)
      }
      if let prices = prices {
        self.assetPrices = prices
      }
    }
  }
  
  private func getNews(ticker:String) {
    IntrinioAPI.getCompanyNews(ticker: ticker) { (error, news) in
      if let error = error {
        let alertVC = UIAlertController.errorAlert(error: error)
        self.present(alertVC, animated: true, completion: nil)
      }
      if let news = news {
        self.news = news
      }
    }
  }
  
  private func renderChart(prices:[CompanyPrice]){
    var chartValues = [ChartDataEntry]()
    chartValues = prices.indices.map {(index) in
      ChartDataEntry(x: Double(index), y: prices[index].close)
    }
    let lineSeries = LineChartDataSet(values: chartValues, label: "Stock Prices")
    //    lineSeries.colors = [.black]
    lineSeries.mode = .cubicBezier
    lineSeries.drawCircleHoleEnabled = false
    lineSeries.drawCirclesEnabled = false
    lineSeries.drawFilledEnabled = true
    lineSeries.fillAlpha = 0.2
    lineSeries.fillColor = .blue
    let lineChartData = LineChartData()
    lineChartData.addDataSet(lineSeries)
    stockChart.data = lineChartData
    stockChart.drawGridBackgroundEnabled = false
    stockChart.chartDescription?.text = Config.chartText
    let xAxis = stockChart.xAxis
    xAxis.valueFormatter = DateValueFormatter()
  }
  
  @IBAction func onBackPressed(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func addToWatchlist(_ sender: UIBarButtonItem) {
    guard let token = UserDefaults.standard.object(forKey: Config.userDefaultsTokenKey) as? String,
      let tokenExpiry = UserDefaults.standard.object(forKey: Config.userDefaultsTokenExp) as? String, let ticker = company?.ticker else { return }
    let user = AuthUser(token: token, tokenExpiry: tokenExpiry)
    let stock = Stock(ticker: ticker, id:nil)
    guard let stockData = try? JSONEncoder().encode(stock) else { return }
    UserAPIClient.addStockToWatchList(user: user, stockData: stockData) { (error, stock) in
      if let error = error {
        DispatchQueue.main.async {
          let alertVC = UIAlertController.errorAlert(error: error)
          self.present(alertVC, animated: true, completion: nil)
          return
        }
      }
    }
  }
  
  
}
  


extension StockViewController : UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let story = news[indexPath.row]
    let safariVC = SFSafariViewController(url: story.url)
    present(safariVC, animated: true, completion: nil)
  }
}

extension StockViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return news.count
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard news.count > 0 else { return UITableViewCell() }
    let story = news[indexPath.row]
    let cell = UITableViewCell()
    cell.textLabel?.text = story.title
    cell.detailTextLabel?.text = story.summary
    return cell
  }
  
  
}

