//
//  MenuScene.swift
//  VideoWallpaper
//
//  Created by Atikur Rahman on 12/01/15.
//  Copyright © 2015 Atikur Rahman. All rights reserved.
//

import AVKit
import SpriteKit

class MenuScene: SKScene, GameViewControllerDelegate {
    
    // MARK: - Enum
    
    enum Button: Int {
        case FIRST_VIDEO, SECOND_VIDEO, THIRD_VIDEO, FOURTH_VIDEO, FIFTH_VIDEO, PURCHASE_ALL, RESTORE
        
        mutating func down() {
            if self.rawValue < 6 {
                self = Button(rawValue: self.rawValue + 1)!
            }
        }
        
        mutating func up() {
            if self.rawValue > 0 {
                self = Button(rawValue: self.rawValue - 1)!
            }
        }
    }
    
    // MARK: - Properties
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let soundHover = SKAction.playSoundFileNamed("hover.wav", waitForCompletion: false)
    
    var allButtons: [LabelContainer]!
    var previewBox: SKSpriteNode!
    var previewLabel: SKLabelNode!
    
    // IAP status
    
    var isUnlockedThirdVideo = false
    var isUnlockedFourthVideo = false
    var isUnlockedFifthVideo = false
    
    // Video player
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    // MARK: - Property Observers
    
    var currentVideoIndex = 1 {
        didSet {
            if currentVideoIndex != oldValue {
                updateVideo()
                updatePreviewLabel()
            }
        }
    }
    
    var focusedButton: Button = .FIRST_VIDEO {
        didSet {
            if focusedButton != oldValue {
                updateFocusedButton()
                runAction(soundHover)
                
                if focusedButton.rawValue <= 4 {
                    currentVideoIndex = focusedButton.rawValue + 1
                }
            }
        }
    }
    
    // MARK: -
    
    override func didMoveToView(view: SKView) {
        addGestureRecognizers(view)
        
        addBackground()
        addLogo()
        addButtons()
        addPreviewBox()
        addPreviewLabel()
        
        updateFocusedButton()
        getIAPStatus()
        updateButtonTitleBasedOnIAPStatus()
        
        playVideo("video\(currentVideoIndex)")
        updatePreviewLabel()
    }
    
    func buttonPressed(sender: UITapGestureRecognizer) {
        let soundButtonClick = SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false)
        
        self.runAction(soundButtonClick)
        
        if focusedButton == .FIRST_VIDEO || focusedButton == .SECOND_VIDEO {
            navigateToPlaybackScene()
        } else if focusedButton == .THIRD_VIDEO {
            if isUnlockedThirdVideo {
                navigateToPlaybackScene()
            } else {
                tapPurchaseProductButton(idIapUnlockVideo3)
            }
        } else if focusedButton == .FOURTH_VIDEO {
            if isUnlockedFourthVideo {
                navigateToPlaybackScene()
            } else {
                tapPurchaseProductButton(idIapUnlockVideo4)
            }
        } else if focusedButton == .FIFTH_VIDEO {
            if isUnlockedFifthVideo {
                navigateToPlaybackScene()
            } else {
                tapPurchaseProductButton(idIapUnlockVideo5)
            }
        } else if focusedButton == .PURCHASE_ALL {
            if isUnlockedThirdVideo && isUnlockedFourthVideo && isUnlockedFifthVideo {
                if let controller = self.view?.window?.rootViewController as? GameViewController {
                    controller.showAlert(title: "Already Unlocked!", message: "You already unlocked all videos!")
                }
            } else {
                tapPurchaseProductButton(idIapUnlockAll)
            }
        } else if focusedButton == .RESTORE {
            if let controller = self.view?.window?.rootViewController as? GameViewController {
                if isUnlockedThirdVideo && isUnlockedFourthVideo && isUnlockedFifthVideo  {
                    controller.showAlert(title: "Already Restored!", message: "In-App Purchase items are already restored!")
                } else {
                    controller.getProductInfo()
                    if controller.isIAPItemsReady {
                        controller.delegate = self
                        controller.restorePurchases()
                    } else {
                        controller.showAlert(title: "Try Again!", message: "Can't process the request. Try again!")
                    }
                }
            }
        }
    }
    
     // this is where the purchases live, isUnlocked will let me unlock everything
    
    func getIAPStatus() {
                isUnlockedThirdVideo = true
                isUnlockedFourthVideo = true
                isUnlockedFifthVideo = true
//        isUnlockedThirdVideo = userDefaults.boolForKey(keyIsUnlockedVideo3)
//        isUnlockedFourthVideo = userDefaults.boolForKey(keyIsUnlockedVideo4)
//        isUnlockedFifthVideo = userDefaults.boolForKey(keyIsUnlockedVideo5)
    }
    
    func updatePreviewLabel() {
        previewLabel.text = previewTexts[currentVideoIndex-1]
    }
    
    // MARK: - IAP
    
    func tapPurchaseProductButton(identifier: String) {
        if let controller = self.view?.window?.rootViewController as? GameViewController {
            controller.getProductInfo()
            if controller.isIAPItemsReady {
                controller.delegate = self
                for product in controller.products {
                    if product.productIdentifier == identifier {
                        controller.buyIAPItem(product)
                        break
                    }
                }
            } else {
                controller.showAlert(title: "Try Again!", message: "Can't process the request. Try again!")
            }
        }
    }
    
    // MARK: - GameViewControllerDelegate methods
    
    func didMakePaymentSuccessfully(productID: String) {
        getIAPStatus()
        updateButtonTitleBasedOnIAPStatus()
    }
    
    func didRestorePurchasesSuccessfully(productID: String) {
        getIAPStatus()
        updateButtonTitleBasedOnIAPStatus()
    }
    
    // MARK: - Video Playback
    
    func playVideo(filename: String) {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType:"mp4")!
        player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRectMake(880, 270, 960, 540)
        scene!.view!.layer.addSublayer(playerLayer)
        
        player.actionAtItemEnd = .None
        player.play()
        
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "playerItemDidReachEnd:",
                name: AVPlayerItemDidPlayToEndTimeNotification ,
                object: self.player.currentItem)
        }
    }
    
    func updateVideo() {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player.currentItem)
        }
    
        if playerLayer != nil {
            playerLayer.removeFromSuperlayer()
        }
        
        playVideo("video\(currentVideoIndex)")
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        print("repeating...")
        
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        player.seekToTime(seekTime)
        player.play()
    }
    
    func navigateToPlaybackScene() {
        playerLayer.removeFromSuperlayer()
        
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player.currentItem)
        }
        
        let blackRect = SKSpriteNode(color: SKColor.blackColor(), size: self.size)
        blackRect.anchorPoint = CGPointZero
        blackRect.zPosition = 100
        addChild(blackRect)
        
        let transition = SKAction.sequence([
            SKAction.waitForDuration(0.01),
            SKAction.removeFromParent()
        ])
        
        blackRect.runAction(transition) {
            let scene = GameScene(size: self.size)
            scene.fileName = "video\(self.currentVideoIndex)"
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene)
        }
    }
    
    // MARK: - Setup Sprites
    
    func addButtons() {
        allButtons = []
        
        let buttonTitles = [
            titleVideo1,
            titleVideo2,
            titleVideo3Locked,
            titleVideo4Locked,
            titleVideo5Locked,
            "Unlock All - $1.99",
            "Restore Purchases"
        ]
        
        for i in 0..<buttonTitles.count {
            let button = LabelContainer(imageNamed: "normalButtonBox")
            button.position = CGPointMake(410, 960 - CGFloat(i) * 140)
            button.label.position = CGPointZero
            button.label.horizontalAlignmentMode = .Center
            button.label.verticalAlignmentMode = .Center
            button.label.fontName = "HelveticaNeue"
            button.label.fontColor = colorButtonNormal
            button.label.text = buttonTitles[i]
            addChild(button)
            allButtons.append(button)
        }
    }
    
    func updateButtonTitleBasedOnIAPStatus() {
        if isUnlockedThirdVideo {
            allButtons[Button.THIRD_VIDEO.rawValue].label.text = titleVideo3
        }
        
        if isUnlockedFourthVideo {
            allButtons[Button.FOURTH_VIDEO.rawValue].label.text = titleVideo4
        }
        
        if isUnlockedFifthVideo {
            allButtons[Button.FIFTH_VIDEO.rawValue].label.text = titleVideo5
        }
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -10
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        addChild(background)
    }
    
    func addPreviewBox() {
        previewBox = SKSpriteNode(imageNamed: "preview")
        previewBox.zPosition = -1
        previewBox.position = CGPointMake(1360, 540)
        addChild(previewBox)
    }
    
    func addLogo() {
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPointMake(1360, 950)
        addChild(logo)
    }
    
    func addPreviewLabel() {
        previewLabel = SKLabelNode(fontNamed: "HelveticaNeue")
        previewLabel.fontColor = SKColor.whiteColor()
        previewLabel.fontSize = 60
        previewLabel.position = CGPointMake(CGRectGetMinX(previewBox.frame), 145)
        previewLabel.text = previewTexts[0]
        previewLabel.horizontalAlignmentMode = .Left
        addChild(previewLabel)
    }
    
    // MARK: - Gesture Recognizers
    
    func addGestureRecognizers(view: SKView) {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: "swipedDown:")
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "swipedUp:")
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "buttonPressed:")
        tapGesture.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
        view.addGestureRecognizer(tapGesture)
    }
    
    func swipedUp(sender: UISwipeGestureRecognizer) {
        focusedButton.up()
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer) {
        focusedButton.down()
    }
    
    func updateFocusedButton() {
        for i in 0..<allButtons.count {
            if i == focusedButton.rawValue {
                allButtons[i].texture = SKTexture(imageNamed: "focusButtonBox")
                allButtons[i].label.fontColor = SKColor.blackColor()
            } else {
                allButtons[i].texture = SKTexture(imageNamed: "normalButtonBox")
                allButtons[i].label.fontColor = colorButtonNormal
            }
            
            allButtons[i].size = allButtons[i].texture!.size()
        }
    }
}
