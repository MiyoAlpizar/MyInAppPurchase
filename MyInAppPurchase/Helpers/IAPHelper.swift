//
//  IAPHelper.swift
//  MyInAppPurchase
//
//  Created by Miyo Alpízar on 23/10/20.
//

import UIKit
import StoreKit

class IAPHelper: NSObject{
    
    static let shared = IAPHelper()
    
    var onReceiveProductsHandler: ((Result<[SKProduct], IAPHelperError>) -> Void)?
    
    private override init() {
        super.init()
    }
    
    enum IAPHelperError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }
    
    
    
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPHelperError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler
        
        // Get the product identifiers.
        guard let productsIDs = getProductIDs() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productsIDs))
        request.delegate = self
        request.start()
    }
    
    func buy(product: SKProduct, withUsername username: String="") {
        let payment = SKMutablePayment(product: product)
        payment.applicationUsername = username
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        //Bundle.main.appStoreReceiptURL
    }
    
    func restore(withUsername username: String? = nil) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions(withApplicationUsername: username)
    }
    
    fileprivate func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: "IAP_ProductIDs", withExtension: "plist") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let products = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String]
            return products
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}

extension IAPHelper: SKProductsRequestDelegate  {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products = response.products
        
        // Check if there are any products available.
        if products.count > 0 {
            // Call the following handler passing the received products.
            onReceiveProductsHandler?(.success(products))
        } else {
            // No products were found.
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    
    func requestDidFinish(_ request: SKRequest) {
        //Finish
    }
    
}


extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            switch $0.transactionState {
            case .purchasing: ()
            case .deferred: ()
            case .failed, .purchased, .restored: SKPaymentQueue.default().finishTransaction($0)
            @unknown default:
                break
            }
        }
    }
}


extension IAPHelper.IAPHelperError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .noProductsFound: return "No In-App Purchases were found."
        case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
        case .paymentWasCancelled: return "In-App Purchase process was cancelled."
        }
    }
    
}
