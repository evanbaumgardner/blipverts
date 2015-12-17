//
//  GameViewController.swift
//  VideoWallpaper
//
//  Created by Atikur Rahman on 12/01/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit
import StoreKit

protocol GameViewControllerDelegate: class {
    func didMakePaymentSuccessfully(productID: String)
    func didRestorePurchasesSuccessfully(productID: String)
}

class GameViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    weak var delegate: GameViewControllerDelegate?
    
    // IAP
    var products: [SKProduct]!
    var isIAPItemsReady = false
    var productsRequest: SKProductsRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsDrawCount = false
        
        skView.ignoresSiblingOrder = true
        
        let scene = MenuScene(size: CGSizeMake(1920, 1080))
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        // fetch product
        getProductInfo()
    }
    
    // MARK: -
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        if presses.first?.type == UIPressType.Menu {
            if let _ = (self.view as? SKView)?.scene as? MenuScene {
                // default behaviour [exit to apple tv home]
                super.pressesEnded(presses, withEvent: event)
            }
        } else {
            // default behaviour [exit to apple tv home]
            super.pressesEnded(presses, withEvent: event)
        }
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        if presses.first?.type == UIPressType.Menu {
            if let _ = (self.view as? SKView)?.scene as? MenuScene {
                // default behaviour [exit to apple tv home]
                super.pressesBegan(presses, withEvent: event)
            } else if let scene = (self.view as? SKView)?.scene as? GameScene {
                scene.returnToMenu()
            }
        } else {
            // default behaviour [exit to apple tv home]
            super.pressesBegan(presses, withEvent: event)
        }
    }
    
    // MARK: - IAP
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let prodID = transaction.payment.productIdentifier as String
            switch transaction.transactionState {
            case .Purchased:
                productPurchased(prodID)
                showAlert(title: "Success", message: "Video unlocked! Enjoy...")
                delegate?.didMakePaymentSuccessfully(prodID)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            case .Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        var isPurchaseRestored = false
        
        for transaction in queue.transactions {
            let prodID = transaction.payment.productIdentifier as String
            
            switch prodID {
            case idIapUnlockAll, idIapUnlockVideo3, idIapUnlockVideo4, idIapUnlockVideo5:
                isPurchaseRestored = true
                productPurchased(prodID)
                delegate?.didRestorePurchasesSuccessfully(prodID)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
            default:
                break
            }
        }
        
        if !isPurchaseRestored {
            showAlert(title: "Nothing to restore!", message: "You haven't bought any item yet!")
        } else {
            showAlert(title: "Success", message: "In-App Purchase items restored!")
        }
    }
    
    // IAP successfull - do necessary actions
    func productPurchased(productID: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        switch productID {
        case idIapUnlockVideo3:
            userDefaults.setBool(true, forKey: keyIsUnlockedVideo3)
        case idIapUnlockVideo4:
            userDefaults.setBool(true, forKey: keyIsUnlockedVideo4)
        case idIapUnlockVideo5:
            userDefaults.setBool(true, forKey: keyIsUnlockedVideo5)
        case idIapUnlockAll:
            userDefaults.setBool(true, forKey: keyIsUnlockedVideo3)
            userDefaults.setBool(true, forKey: keyIsUnlockedVideo4)
            userDefaults.setBool(true, forKey: keyIsUnlockedVideo5)
        default:
            break
        }
        
        userDefaults.synchronize()
    }
    
    // buy item button tap
    func buyIAPItem(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    // restore purchases button tap
    func restorePurchases() {
        if isIAPItemsReady {
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        }
    }
    
    // get product info from itunes connect
    func getProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIDs = NSSet(array: [idIapUnlockAll, idIapUnlockVideo3, idIapUnlockVideo4, idIapUnlockVideo5])
            productsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        isIAPItemsReady = false
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        products = response.products
        if products.count == 4 {
            isIAPItemsReady = true
        } else {
            isIAPItemsReady = false
        }
    }
    
    // MARK: -
    
    func showAlert(title title: String, message: String) {
        let alert =  UIAlertController( title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction( title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
