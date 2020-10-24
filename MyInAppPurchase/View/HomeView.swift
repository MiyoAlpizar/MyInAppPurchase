//
//  HomeView.swift
//  MyInAppPurchase
//
//  Created by Miyo Alpízar on 23/10/20.
//

import UIKit
import StoreKit

class HomeView: UITableViewController {

    enum Product: String, CaseIterable {
        case removeAds = "com.todosVuelan.remove"
        case unlockEverything = "com.todosVuelan.unlock"
        case getGems = "com.todosVuelan.gems"
    }
    
    private var models = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchProducts()
        SKPaymentQueue.default().add(self)
    }
    
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({$0.rawValue})))
        request.delegate = self
        request.start()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return models.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(product.localizedTitle) : \(product.localizedDescription) - \(product.priceLocale.currencySymbol ?? "$") \(product.price)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pay = SKPayment(product: models[indexPath.row])
        SKPaymentQueue.default().add(pay)
    }
}


extension HomeView: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchasing:
                print("prchasing")
            case .purchased:
                print("prchased")
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                print("failed")
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                print("Restored")
            case .deferred:
                print("deferred")
            @unknown default:
                print("default")
            }
        })
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            print("Count: \(response.products)")
            self.models = response.products
            self.tableView.reloadData()
        }
    }
}
