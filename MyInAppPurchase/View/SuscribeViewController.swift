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
        getSubscriptionValues()
        
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
    
    @IBAction func suscribeMonth(_ sender: Any) {
        //buy(2)
        IAPHelper.shared.refreshSubscriptionsStatus { (result) in
            switch result {
            case .success(let date):
                print(date)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    @IBAction func suscribe6Months(_ sender: Any) {
        buy(1)
    }
    
    @IBAction func suscribeYear(_ sender: Any) {
        buy(0)
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
                
                self.setExpirationDate(transaction: transaction)
                
                let alert = UIAlertController(title: "Restore Purchase Successful", message: "Your subscription was successful restored", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Great", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func buy(_ index: Int) {
        guard products.count > 0, IAPHelper.shared.canMakePayments() else {
            return
        }
        IAPHelper.shared.buy(product: products[index]) { (result) in
            switch result {
            case .success(let transaction):
                print(transaction)
                self.setExpirationDate(transaction: transaction)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setExpirationDate(transaction: SKPaymentTransaction) {
        
        let suscriptionType = IAPHelper.shared.getProductType(withId: transaction.payment.productIdentifier)
        
        if let date = transaction.transactionDate, let type = suscriptionType {
            if let expirationDate = Calendar.current.date(byAdding: Calendar.Component.month, value: type.monthDuration, to: date)
            {
                print(expirationDate)
                AppHelper.shared.setString(type: UserStrings.subscriptionID, value: type.id)
                AppHelper.shared.setDate(type: UserStrings.subscriptionEndDate, value: expirationDate)
                AppHelper.shared.setString(type: UserStrings.trasnsactionID, value: transaction.transactionIdentifier ?? "")
                AppHelper.shared.setDate(type: .subscriptionStartDate, value: date)
                self.getSubscriptionValues()
            }
        }
    }
    
    func getSubscriptionValues() {
        let expirationDate = AppHelper.shared.getDate(type: UserStrings.subscriptionEndDate)
        let startsDate = AppHelper.shared.getDate(type: UserStrings.subscriptionStartDate)
        let transaction = AppHelper.shared.getString(type: UserStrings.trasnsactionID)
        let productID = AppHelper.shared.getString(type: UserStrings.subscriptionID)
        
        print("Starts Date: \(String(describing: startsDate))")
        print("Expiration Date: \(String(describing: expirationDate))")
        print("Transaction ID: \(transaction)")
        print("Product ID: \(productID)")
       
        
        
    }
}
