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
    var onBuyProductHandler: ((Result<Bool, Error>) -> Void)?
    
    var onRestoreProductHandler: ((Result<SKPaymentTransaction, Error>) -> Void)?
    
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
    
    func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        onBuyProductHandler = handler
        //Bundle.main.appStoreReceiptURL
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func restore(withHandler handler: @escaping(_ result: Result<SKPaymentTransaction, Error>) -> Void) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
        onRestoreProductHandler = handler
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
            case .purchased:
                onBuyProductHandler?(.success(true))
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                onRestoreProductHandler?(.success($0))
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                if let error = $0.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(error))
                    } else {
                        onBuyProductHandler?(.failure(IAPHelperError.paymentWasCancelled))
                    }
                    print("IAP Error:", error.localizedDescription)
                }
                SKPaymentQueue.default().finishTransaction($0)
            case .deferred, .purchasing: break
            @unknown default: break
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
