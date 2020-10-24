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
    
    var products = [SKProduct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func suscribe(_ sender: Any) {
        IAPHelper.shared.getProducts { (result) in
            switch result {
            case .success(let products):
                self.products = products
                self.buy()
            case .failure(let error): print(error.localizedDescription)
            }
        }
    }
    
    
    func buy() {
        guard products.count > 0 else {
            return
        }
        IAPHelper.shared.buy(product: products[0])
    }
}
