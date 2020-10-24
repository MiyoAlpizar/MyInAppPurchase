//
//  SuscribeViewController.swift
//  MyInAppPurchase
//
//  Created by Miyo Alpízar on 24/10/20.
//

import UIKit
import StoreKit
class SuscribeViewController: UIViewController {
    
    @IBOutlet weak var suscribeBtn: UIButton!
    @IBOutlet weak var suscribe6Months: UIButton!
    @IBOutlet weak var sucribeMonth: UIButton!
    @IBOutlet weak var restoreBtn: UIButton!
    
    
    
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getProducts()
    }
    
    func getProducts() {
        IAPHelper.shared.getProducts { (result) in
            switch result {
            case .success(let products):
                self.products = products
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
    
    
    @IBAction func suscribeYear(_ sender: Any) {
        buy()
    }
    
    @IBAction func restore(_ sender: Any) {
        IAPHelper.shared.restore { (result) in
            switch result {
            case .success(let transaction):
                print(transaction.transactionState)
                print(transaction.transactionIdentifier ?? "No id")
                print(transaction.payment.applicationUsername ?? "No user name")
                print(transaction.payment.productIdentifier)
                print(transaction.payment.requestData ?? "No data")
                print(transaction.original?.transactionDate ?? "No date")
                
                let alert = UIAlertController(title: "Restore Purchase Successful", message: "Your subscription was successful restored", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Great", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
    func buy() {
        guard products.count > 0, IAPHelper.shared.canMakePayments() else {
            return
        }
        IAPHelper.shared.buy(product: products[0]) { (result) in
            switch result {
            case .success(let ok):
                print(ok)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
