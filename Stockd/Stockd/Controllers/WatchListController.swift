//
//  WatchListController.swift
//
//
//  Created by J on 1/5/19.
//

import UIKit

class WatchListController: UIViewController {
  @IBOutlet weak var watchListTable: UITableView!
  private var watchlist = [Stock]() {
    didSet {
      DispatchQueue.main.async {
        self.watchListTable.reloadData()
      }
    }
  }
  private var tickers = [String]() {
    didSet {
      DispatchQueue.main.async {
        self.watchListTable.reloadData()
      }
    }
  }
  public var completionHandler: ((Company) -> Bool)?
  override func viewDidLoad() {
    super.viewDidLoad()
    watchListTable.delegate = self
    watchListTable.dataSource = self
  }
  override func viewWillAppear(_ animated: Bool) {
    getWatchList()
  }
  
  private func getWatchList() {
    guard let token = UserDefaults.standard.object(forKey: Config.userDefaultsTokenKey) as? String,
      let tokenExpiry = UserDefaults.standard.object(forKey: Config.userDefaultsTokenExp) as? String else { return }
    let user = AuthUser(token: token, tokenExpiry: tokenExpiry)
    UserAPIClient.getWatchlist(user: user) { (error, stocks) in
      if let stocks = stocks {
        self.watchlist = stocks
      }
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
extension WatchListController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = watchListTable.dequeueReusableCell(withIdentifier: "watchCell", for: indexPath) as? WatchListCell, watchlist.count > 0 else { return UITableViewCell() }
    let stock = watchlist[indexPath.row]
    cell.tickerNameLabel?.text = stock.ticker
    return cell
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return watchlist.count
  }
}
extension WatchListController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    let stock =
  }
}
