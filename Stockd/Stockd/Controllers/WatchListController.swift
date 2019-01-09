//
//  WatchListController.swift
//
//
//  Created by J on 1/5/19.
//

import UIKit
import UserNotifications
class WatchListController: UIViewController {
  @IBOutlet weak var watchListTable: UITableView!
  private var watchlist = [Stock]() {
    didSet {
      DispatchQueue.main.async {
        self.watchListTable.reloadData()
      }
    }
  }
  private var tickerToPrices = [String:[CompanyPrice]]() {
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
    UNUserNotificationCenter.current().delegate = self
  }
  override func viewWillAppear(_ animated: Bool) {
    getWatchList()
  }
  
  private func calculateReturn (ticker:String) -> Double {
    
    guard let stockPrices = tickerToPrices[ticker],
      let firstPrice = stockPrices.first,
      let lastPrice = stockPrices.last else { return 0.0 }

    return (lastPrice.close / firstPrice.close) * 100
  }
  
  private func largestReturn() -> String{
    
    return self.tickerToPrices.keys.max { (firstTicker, secondTicker) in
      calculateReturn(ticker: firstTicker) > calculateReturn(ticker: secondTicker)
      } ?? ""
    
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
      self.watchlist.forEach { stock in
        
        IntrinioAPI.getCompanyPrices(ticker: stock.ticker, pageSize: 2) {(error, prices) in
          
          if let error = error {
            DispatchQueue.main.async {
              let alertVC = UIAlertController.errorAlert(error: error)
              self.present(alertVC, animated: true, completion: nil)
              return
            }
          }
          
          if let prices = prices {
            self.tickerToPrices[stock.ticker] = prices
          }
          let largestReturnTicker = self.largestReturn()
          self.scheduleNotifications(ticker: largestReturnTicker)
        }
      }
      
    }
  }
  
  private func deleteStock(user:AuthUser, stock:Stock){
    watchlist = watchlist.filter { $0.ticker != stock.ticker }
    UserAPIClient.deleteStock(user:user, stock: stock) { (error, success) in
      
      if let error = error {
        Lib.presentErrorController(error: error, target: self)
      }
      
    }
  }
  
  func scheduleNotifications(ticker:String) {

    let content = UNMutableNotificationContent()
    let requestIdentifier = Config.notificationID

    content.badge = 1
    guard let stockPrices = tickerToPrices[ticker],
      let firstPrice = stockPrices.first,
      let lastPrice = stockPrices.last else { return }
    
    let stockReturn = ((firstPrice.close / lastPrice.close) - 1) * 100
    let returnString = String(format: "%.1f", stockReturn)
    
    content.title = "\(ticker) increased by \(returnString)%"
    content.subtitle = "Woohoo Shmoney!!!"
    content.categoryIdentifier = "actionCategory"
    content.sound = .default

    // If you want to attach any image to show in local notification
    guard let url = Bundle.main.url(forResource: "icon", withExtension: ".png"),
      let attachment = try? UNNotificationAttachment(identifier: requestIdentifier,
                                                     url: url, options: nil)  else { return }
      content.attachments = [attachment]
    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5.0, repeats: false)

    let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { (error:Error?) in

      if let error = error {
        print(error.localizedDescription)
      }
      print("Notification Register Success")
    }
  }
  
}
extension WatchListController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     guard let cell = watchListTable.dequeueReusableCell(withIdentifier: "watchCell", for: indexPath) as? WatchListCell, watchlist.count > 0,
      tickerToPrices[watchlist[indexPath.row].ticker]?.first != nil else { return UITableViewCell() }
    let stock = watchlist[indexPath.row]
    let prices = tickerToPrices[stock.ticker]
    let stockReturn = calculateReturn(ticker: stock.ticker)
    cell.tickerNameLabel?.text = stock.ticker
    cell.priceLabel.text = String(format: "%.2f" , (prices?.last!.close)!)
    cell.priceLabel.textColor = stockReturn < 1.0 ? .red : .green
    return cell
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return watchlist.count
  }
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return watchlist.count > 0
  }
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard watchlist.count > 0 else { return }
    if editingStyle == .delete {
      //TODO: delete the client watchlist item and server ticker
      let stock = watchlist[indexPath.row]
      // API delete call
      guard let user = Lib.getAuthUser() else { return }
      deleteStock(user:user, stock: stock)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
}
extension WatchListController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}

extension WatchListController: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
    // some other way of handling notification
    // If you don't implement this delegate on the view controller you will not be able to see the notification inside the app for the specified view controller. Both the app delegate and view controller need to have the delegate implemented.
    completionHandler([.alert, .sound, .badge])
  }
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
    switch response.actionIdentifier {
    case Config.notificationID:
      print("some stuff")
      break
    default:
      break
    }
    completionHandler()

  }
}
