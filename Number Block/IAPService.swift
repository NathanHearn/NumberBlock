//
//  IAPService.swift
//  Number Block
//
//  Created by Nathan on 20/05/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import Foundation
import StoreKit

enum IAPProduct: String {
    case adsRemove = "com.BullhogInteractive.Number.Block.adsremove"
    case gems200 = "com.BullhogInteractive.Number.Block.gems200"
    case gems600 = "com.BullhogInteractive.Number.Block.gems600"
    case gems1500 = "com.BullhogInteractive.Number.Block.gems1500"
    case gems3000 = "com.BullhogInteractive.Number.Block.gems3000"
    case gems10000 = "com.BullhogInteractive.Number.Block.gems10000.corrected"
}

class IAPService: NSObject {
    
    //Creates Singlton
    class var sharedInstance: IAPService {
        struct Singleton {
            static let instance = IAPService()
        }
        return Singleton.instance
    }
    
    //refrance that allows the singleton to interactive with the viewcontroler, is asigned just before getProducts is called in the GVC
    var GVC: GameViewController?
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    var productPrices: Dictionary<String, String> = ["adsRemove":"0", "gems200":"0", "gems600":"0", "gems1500":"0", "gems3000":"0", "gems10000":"0"]
    
    func getProducts() {
        let products: Set =  [IAPProduct.adsRemove.rawValue,
                              IAPProduct.gems200.rawValue,
                              IAPProduct.gems600.rawValue,
                              IAPProduct.gems1500.rawValue,
                              IAPProduct.gems3000.rawValue,
                              IAPProduct.gems10000.rawValue]
        
        let request = SKProductsRequest(productIdentifiers: products)
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: IAPProduct) {
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else {return}
        
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
        
    }
    
    func restorePurchases() {
        paymentQueue.restoreCompletedTransactions()
    }
    
    func purchaseSuccessful(productID: String) {
        if let controler = GVC {
            switch productID {
            case IAPProduct.adsRemove.rawValue:
                controler.buy(get: .adsremove)
            case IAPProduct.gems200.rawValue:
                controler.buy(get: .gems200)
            case IAPProduct.gems600.rawValue:
                controler.buy(get: .gems600)
            case IAPProduct.gems1500.rawValue:
                controler.buy(get: .gems1500)
            case IAPProduct.gems3000.rawValue:
                controler.buy(get: .gems3000)
            case IAPProduct.gems10000.rawValue:
                controler.buy(get: .gems10000)
            default:
                print("Not a valid product")
            }
        } else {
            return
        }
    }
    
}

extension IAPService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        for product in products {
            switch product.productIdentifier {
            case IAPProduct.adsRemove.rawValue:
                productPrices["adsRemove"] = product.localizedPrice()
            case IAPProduct.gems200.rawValue:
                productPrices["gems200"] = product.localizedPrice()
            case IAPProduct.gems600.rawValue:
                productPrices["gems600"] = product.localizedPrice()
            case IAPProduct.gems1500.rawValue:
                productPrices["gems1500"] = product.localizedPrice()
            case IAPProduct.gems3000.rawValue:
                productPrices["gems3000"] = product.localizedPrice()
            case IAPProduct.gems10000.rawValue:
                productPrices["gems10000"] = product.localizedPrice()
            default:
                print("Unknown product ID")
            }
        }
    }
    
}

extension IAPService: SKPaymentTransactionObserver {
    //called anytime somthing is added to the transaction queue
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                //This also works for restoring as there is only one non-consumable
                purchaseSuccessful(productID: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            case .restored:
                purchaseSuccessful(productID: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        
        switch self {
        case .deferred:
            return "deferred"
        case .purchasing:
            return "purchasing"
        case .purchased:
            return "purchased"
        case .failed:
            return "failed"
        case .restored:
            return "restored"
        }
    }
}

extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
    
}
