//
//  Purchase.swift
//  seelog
//
//  Created by Matus Tomlein on 07/12/2018.
//  Copyright © 2018 Matus Tomlein. All rights reserved.
//

import Foundation
import StoreKit

class CompleteHistoryPurchase {
    public static let CompleteHistory = "app.seelog.completehistory"
    private static let productIdentifiers: Set<ProductIdentifier> = [CompleteHistoryPurchase.CompleteHistory]
    public static let store = IAPHelper(productIds: CompleteHistoryPurchase.productIdentifiers)

    public var product: SKProduct

    public static var isPurchased: Bool {
        get {
            return UserDefaults.standard.bool(forKey: CompleteHistory)
        }
    }

    public static func fetch(callback: @escaping (CompleteHistoryPurchase) -> ()) {
        store.requestProducts { success, products in
            if success {
                if let product = products?.first {
                    callback(CompleteHistoryPurchase(product))
                } else {
                    print("No products found")
                }
            } else {
                print("Unknown error")
            }
        }
    }

    init(_ product: SKProduct) {
        self.product = product
    }

    func buy() {
        CompleteHistoryPurchase.store.buyProduct(product)
    }

    func restore() {
        CompleteHistoryPurchase.store.restorePurchases()
    }
}
