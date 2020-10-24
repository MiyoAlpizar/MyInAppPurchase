//
//  IAPHelper.swift
//  MyInAppPurchase
//
//  Created by Miyo Alpízar on 23/10/20.
//

import UIKit
import StoreKit

class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var productID: NSSet = NSSet(object: "string")
    var productsRequest: SKProductsRequest = SKProductsRequest()
    var products = [String: SKProduct]()
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
}
