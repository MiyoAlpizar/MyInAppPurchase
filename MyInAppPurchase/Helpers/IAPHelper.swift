//
//  IAPHelper.swift
//  MyInAppPurchase
//
//  Created by Miyo Alpízar on 23/10/20.
//

import UIKit
import StoreKit

struct SubscriptionType {
    let id: String
    let monthDuration: Int
    let title: String
}

class IAPHelper: NSObject{
    
    let sharedSecret = "3446a7e5eae34426bbaaab9f94666276"
    
    static let shared = IAPHelper()
    var onReceiveProductsHandler: ((Result<[SKProduct], IAPHelperError>) -> Void)?
    var onBuyProductHandler: ((Result<SKPaymentTransaction, Error>) -> Void)?
    var onRestoreProductHandler: ((Result<SKPaymentTransaction, Error>) -> Void)?
    var onRefreshSubscriptionStatus: ((Result<Date, Error>) -> Void)?
    
    var suscriptionTypes = [SubscriptionType]()
    
    private override init() {
        super.init()
        suscriptionTypes.append(SubscriptionType(id: "todosVuelan.MyInAppPurchase.Month", monthDuration: 1, title: "1 Month"))
        suscriptionTypes.append(SubscriptionType(id: "todosVuelan.MyInAppPurchase.6Months", monthDuration: 6, title: "6 Month"))
        suscriptionTypes.append(SubscriptionType(id: "todosVuelan.MyInAppPurchase.Annual", monthDuration: 12, title: "1 Year"))
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
        let productsIDs = getProductsID()
        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productsIDs))
        request.delegate = self
        request.start()
    }
    
    func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Result<SKPaymentTransaction, Error>) -> Void)) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else {
            return
        }
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        onBuyProductHandler = handler
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
    
    fileprivate func getProductsID() -> [String] {
        var ids = [String]()
        suscriptionTypes.forEach { (type) in
            ids.append(type.id)
        }
        return ids
    }
    
    func getProductType(withId id: String) -> SubscriptionType? {
        return suscriptionTypes.filter({$0.id == id}).first
    }
    
    func refreshSubscriptionsStatus(handler : @escaping (_ result: Result<Date, Error>) -> Void){
        // save blocks for further use
         onRefreshSubscriptionStatus = handler
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            self.refreshReceipt()
            return
        }
        #if DEBUG
            let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
        #else
            let urlString = "https://buy.itunes.apple.com/verifyReceipt"
        #endif
        let receiptData = try? Data(contentsOf: receiptUrl).base64EncodedString()
        let requestData = ["receipt-data" : receiptData ?? "", "password" : self.sharedSecret, "exclude-old-transactions" : true] as [String : Any]
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            DispatchQueue.main.async {
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                        self.parseReceipt(json as! Dictionary<String, Any>)
                        return
                    }
                } else {
                    print("error validating receipt: \(error?.localizedDescription ?? "")")
                }
                if let error = error {
                    self.onRefreshSubscriptionStatus?(.failure(error))
                }
            }
        }.resume()
    }
    
    private func parseReceipt(_ json : Dictionary<String, Any>) {
         guard let receipts_array = json["latest_receipt_info"] as? [Dictionary<String, Any>] else {
             return
        }
        for receipt in receipts_array {
            let productID = receipt["product_id"] as! String
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            if let date = formatter.date(from: receipt["expires_date"] as! String) {
                onRefreshSubscriptionStatus?(.success(date))
                if date > Date() {
                    print(productID, date)
                    // Subscription does not expires yet
                }
            }
        }
    }
    
    
    private func refreshReceipt(){
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
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
        if request is SKReceiptRefreshRequest {
            //self.refr
        }
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    
    
    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            refreshSubscriptionsStatus(handler: {_ in })
        }
    }
    
    
    
}


extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            switch $0.transactionState {
            case .purchased:
                onBuyProductHandler?(.success($0))
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
