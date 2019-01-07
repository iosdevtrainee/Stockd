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
  
  private var companies = [Company]() {
    didSet {
      DispatchQueue.main.async {
          self.companiesTable.reloadData()
      }
    }
  }
  
  @IBOutlet weak var companiesSearch: UISearchBar!
  @IBOutlet weak var firstCircle: UIView!
  @IBOutlet weak var secondCircle: UIView!
  @IBOutlet weak var thirdCircle: UIView!
  @IBOutlet weak var companiesTable: UITableView!
  
  @IBOutlet weak var tickersContainer: UIStackView!
  
  private func makeCircles() {
    makeCircle(view: firstCircle)
    makeCircle(view: secondCircle)
    makeCircle(view: thirdCircle)
  }
  
  override func viewDidLoad() {
      super.viewDidLoad()
      companiesTable.dataSource = self
      companiesSearch.delegate = self
      companiesTable.delegate = self
      title = "Search"
      setupRefreshControl()
      allCompanies()
      tickersContainer.frame = CGRect(x: 0, y: 551.5, width: 375, height: 125)
      view.bringSubviewToFront(tickersContainer)
      makeCircles()
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
    IntrinioAPI.allCompanies{ (error, companies) in
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
    guard let signInVC = storyboard.instantiateViewController(withIdentifier: Config.signInVCName) as? SignInViewController else {
      return 
    }
    userAuthDelegate = signInVC
    userAuthDelegate?.signOut { success in
      if !success {
        print("Didn't sign out.")
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

}
extension SearchViewController : UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    if companies.count > 0 {
      let company = companies[indexPath.row]
      cell.textLabel?.text = company.ticker
      cell.detailTextLabel?.text = company.name
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
    present(homeVC, animated: true, completion: nil)
  }
}

extension SearchViewController : UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let text = searchBar.text else { return }
    searchCompanies(keyword: text)
  }
}
