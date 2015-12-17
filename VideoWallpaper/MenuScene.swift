//
//  MenuScene.swift
//  VideoWallpaper
//
//  Created by Atikur Rahman on 12/01/15.
//  Copyright © 2015 Atikur Rahman. All rights reserved.
//

import AVKit
import SpriteKit

class MenuScene: SKScene {
    
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
        
        updateFocusedButton()
        getIAPStatus()
        updateButtonTitleBasedOnIAPStatus()
        
        playVideo("video\(currentVideoIndex)")
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
                print("item locked...")
            }
        } else if focusedButton == .FOURTH_VIDEO {
            if isUnlockedFourthVideo {
                navigateToPlaybackScene()
            } else {
                print("item locked...")
            }
        } else if focusedButton == .FIFTH_VIDEO {
            if isUnlockedFifthVideo {
                navigateToPlaybackScene()
            } else {
                print("item locked...")
            }
        } else if focusedButton == .PURCHASE_ALL {
            if isUnlockedThirdVideo && isUnlockedFourthVideo && isUnlockedFifthVideo {
                print("already unlocked all videos")
            } else {
                print("item locked...")
            }
        } else if focusedButton == .RESTORE {
            if isUnlockedThirdVideo && isUnlockedFourthVideo && isUnlockedFifthVideo {
                print("already restored")
            } else {
                print("processing restore")
            }
        }
    }
    
    func getIAPStatus() {
        
    }
    
    // MARK: - Video Playback
    
    func playVideo(filename: String) {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType:"mp4")!
        player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRectMake(880, 240, 960, 540)
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
        previewBox.position = CGPointMake(1360, 570)
        addChild(previewBox)
    }
    
    func addLogo() {
        let logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPointMake(1360, 980)
        addChild(logo)
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
