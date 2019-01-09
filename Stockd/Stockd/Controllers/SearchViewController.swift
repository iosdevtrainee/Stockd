//
//  SearchViewController.swift
//  Stockd
//
//  Created by J on 12/29/18.
//  Copyright © 2018 J. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  weak var userAuthDelegate: UserAuthDelegate?
  private var refreshControl: UIRefreshControl!
  private var tickerCircles = [CircleView]()
  private var position: Position = .first
  private var companies = [Company]() {
    didSet {
      DispatchQueue.main.async {
          self.companiesTable.reloadData()
      }
    }
  }
  
  @IBOutlet weak var companiesSearch: UISearchBar!
  @IBOutlet weak var firstCircle: CircleView!
  @IBOutlet weak var secondCircle: CircleView!
  @IBOutlet weak var thirdCircle: CircleView!
  @IBOutlet weak var companiesTable: UITableView!
  @IBOutlet weak var compareButton: UIBarButtonItem!
  
  @IBOutlet weak var tickersContainer: UIStackView!
  
  override func viewDidLoad() {
      super.viewDidLoad()
      setupDelegates()
      compareButton.isEnabled = false
      title = "Search"
      setupRefreshControl()
      allCompanies()
      view.bringSubviewToFront(tickersContainer)
      makeCircles()
      tickerCircles = [firstCircle, secondCircle, thirdCircle]
    }
  
  private func makeCircles() {
    makeCircle(view: firstCircle)
    makeCircle(view: secondCircle)
    makeCircle(view: thirdCircle)
  }
  
  private func setupDelegates() {
    companiesTable.dataSource = self
    companiesSearch.delegate = self
    companiesTable.delegate = self
  }
  
  private func makeCircle(view:UIView) {
        view.layer.cornerRadius = view.frame.size.width/2
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 5.0
  }

  private func setupRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(allCompanies), for: .valueChanged)
    companiesTable.refreshControl = refreshControl
  }
  
  @objc private func allCompanies() {
    refreshControl.endRefreshing()
    
    IntrinioAPI.allCompanies {(error, companies) in
      
      if let error = error {
       Lib.presentErrorController(error: error, target: self)
      }
      
      if let companies = companies {
        self.companies = companies.filter { $0.ticker != nil }
      }
      
    }
  }
  
  @IBAction func onSignOut(_ sender: UIBarButtonItem) {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    guard let signInVC = storyboard.instantiateViewController(withIdentifier: Config.userAuthVC) as? UserAuthController else {
      return 
    }
    
    userAuthDelegate = signInVC
    userAuthDelegate?.signOut { success in
      
      if !success {
        print("Didn't sign out.")
        return
      }
    }
    
    present(signInVC, animated: true, completion: nil)
  }
  
  
  private func searchCompanies(keyword:String) {
    
    IntrinioAPI.searchCompanies(keyword: keyword) { (error, companies) in
      
      if let error = error {
        Lib.presentErrorController(error: error, target: self)
      }
      
      if let companies = companies {
        self.companies = companies.filter { $0.ticker != nil }
      }
    }
    
  }
  
  @objc private func showTicker(sender:UILongPressGestureRecognizer){
    guard let cell = sender.view as? CompanyCell else { return }
    guard let ticker = cell.companyTickerLabel.text else { return }
    let tickerCircle = tickerCircles[position.rawValue]
    let previousCircle = tickerCircles[position.previous().rawValue]
    if (tickerCircles.filter {$0.text == ticker }).count == 0{
      tickerCircle.text = ticker
      tickerCircle.isHidden = false
      position = position.next()
      if (tickerCircles.filter {$0.text != "" }).count > 1 {
        compareButton.isEnabled = true
      }
      return
    }
    switch position {
    case .first:
      if ticker == tickerCircle.text {
        tickerCircle.text = ""
        tickerCircle.isHidden = true
        return
      }
    case .second:
      compareButton.isEnabled = false
      if ticker == tickerCircle.text {
        tickerCircle.text = ""
        tickerCircle.isHidden = true
        return
      }
      if ticker == previousCircle.text {
        previousCircle.text = ""
        position = position.previous()
        previousCircle.isHidden = true
        return
      }
    case .third:
      if ticker == tickerCircle.text {
        tickerCircle.text = ""
        tickerCircle.isHidden = true
        return
      }
      if ticker == previousCircle.text && tickerCircle.text == "" {
        compareButton.isEnabled = false
        previousCircle.text = ""
        previousCircle.isHidden = true
        position = position.previous()
        return
      }
    }
  }

  @IBAction func onCompare(_ sender: UIBarButtonItem) {
    let tickers = tickerCircles.map { $0.text }
    let selectedCompanies = companies.filter { tickers.contains($0.ticker) }
    Lib.transitionToVC(nextVCType: .compare, vcData: selectedCompanies, target: self)
    
  }
  
  
}
extension SearchViewController : UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = companiesTable.dequeueReusableCell(withIdentifier:
      Config.companyCellName) as? CompanyCell else { return UITableViewCell() }
    if companies.count > 0 {
      let company = companies[indexPath.row]
      let longPressGesture = UILongPressGestureRecognizer()
      longPressGesture.addTarget(self, action: #selector(showTicker(sender:)))
      cell.companyNameLabel.text = company.name
      cell.companyTickerLabel.text = company.ticker
      cell.addGestureRecognizer(longPressGesture)
    }
    return cell
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return companies.count
  }
}



extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let company = companies[indexPath.row]
    let storyboard = UIStoryboard(name: Config.storyboardName, bundle: nil)
    guard let homeVC =  storyboard.instantiateViewController(withIdentifier: Config.stockVCName) as? StockViewController else { return }
    homeVC.company = company
    homeVC.modalPresentationStyle = .overCurrentContext
    present(homeVC, animated: true, completion: nil)
  }
  
  
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.6)
      UIView.animate(withDuration: 0.4) {
          cell.transform = CGAffineTransform.identity
      }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
}

extension SearchViewController : UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text else { return }
    searchCompanies(keyword: text)
  }
  
}
