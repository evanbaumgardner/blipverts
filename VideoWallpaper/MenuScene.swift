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
    
    var isUnlockedThirdVideo = false
    var isUnlockedFourthVideo = false
    var isUnlockedFifthVideo = false
    
    // players
    var player: AVQueuePlayer!
    var playerLayer: AVPlayerLayer!
    
    var playerItem1: AVPlayerItem!
    var playerItem2: AVPlayerItem!
    
    // MARK: - Property Observers
    
    var videoIndex = 1 {
        didSet {
            if videoIndex != oldValue {
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
                    videoIndex = focusedButton.rawValue + 1
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
    }
    
    func buttonPressed(sender: UITapGestureRecognizer) {
        let soundButtonClick = SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false)
        
        self.runAction(soundButtonClick)
        
        if focusedButton.rawValue < 5 {
            navigateToPlaybackScene()
        }
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
    
    func getIAPStatus() {
        
    }
    
    func updateButtonTitleBasedOnIAPStatus() {
        if isUnlockedThirdVideo {
            allButtons[Button.THIRD_VIDEO.rawValue].label.text = "Third Video"
        }
        
        if isUnlockedFourthVideo {
            allButtons[Button.FOURTH_VIDEO.rawValue].label.text = "Fourth Video"
        }
        
        if isUnlockedFifthVideo {
            allButtons[Button.FIFTH_VIDEO.rawValue].label.text = "Fifth Video"
        }
    }
    
    // MARK: - Video Playback
    
    func playVideo(filename: String) {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType:"mp4")!
        
        playerItem1 = AVPlayerItem(URL: NSURL(fileURLWithPath: path))
        playerItem2 = AVPlayerItem(URL: NSURL(fileURLWithPath: path))
        
        player = AVQueuePlayer(items: [playerItem1, playerItem2])
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRectMake(880, 240, 960, 540)
        print(playerLayer.anchorPoint)
        scene!.view!.layer.addSublayer(playerLayer)
        
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "playerItem1DidReachEnd:",
            name: AVPlayerItemDidPlayToEndTimeNotification ,
            object: playerItem1)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "playerItem2DidReachEnd:",
            name: AVPlayerItemDidPlayToEndTimeNotification ,
            object: playerItem2)
    }
    
    func updateVideo() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem1)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem2)
        
        playerLayer.removeFromSuperlayer()
        
        playVideo("video\(videoIndex)")
        
        player.play()
    }
    
    func playerItem1DidReachEnd(notification: NSNotification) {
        print("item 1 finished")
        
        player.removeItem(playerItem1)
        player.insertItem(playerItem1, afterItem: playerItem2)
        playerItem1.seekToTime(kCMTimeZero)
        
        print(player.items().count)
    }
    
    func playerItem2DidReachEnd(notification: NSNotification) {
        print("item 2 finished")
        
        player.removeItem(playerItem2)
        player.insertItem(playerItem2, afterItem: playerItem1)
        playerItem2.seekToTime(kCMTimeZero)
        
        print(player.items().count)
    }
    
    func navigateToPlaybackScene() {
        playerLayer.removeFromSuperlayer()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem1)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem2)
        
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
            scene.fileName = "video\(self.videoIndex)"
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene)
        }
    }
    
    // MARK: - Setup Sprites
    
    func addButtons() {
        allButtons = []
        
        let buttonTitles = [
            "First Video",
            "Second Video",
            "Third Video - $0.99",
            "Fourth Video - $0.99",
            "Fifth Video - $0.99",
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
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        background.position = CGPointMake(self.size.width/2, self.size.height/2)
        addChild(background)
    }
    
    func addPreviewBox() {
        previewBox = SKSpriteNode(imageNamed: "preview")
        previewBox.position = CGPointMake(1360, 570)
        addChild(previewBox)
    }
    
    func addLogo() {
        let logo = SKSpriteNode(imageNamed: "textBrainGames")
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
}
