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
    
    // MARK: - Enums
    
    enum SwipeDirection {
        case UP, DOWN
    }
    
    enum VIDEO: Int {
        case VIDEO1, VIDEO2, VIDEO3, VIDEO4, VIDEO5
        
        mutating func next() {
            if self.rawValue < 4 {
                self = VIDEO(rawValue: self.rawValue + 1)!
            }
        }
        
        mutating func prev() {
            if self.rawValue > 0 {
                self = VIDEO(rawValue: self.rawValue - 1)!
            }
        }
    }
    
    var focusedVideo: VIDEO = .VIDEO1 {
        didSet {
            if focusedVideo != oldValue {
                updateConainerPosition()
                updateVideo()
            }
        }
    }
    
    // MARK: -
    
    var player: AVQueuePlayer!
    var playerLayer: AVPlayerLayer!
    
    var playerItem1: AVPlayerItem!
    var playerItem2: AVPlayerItem!
    
    var allButtons = [SKLabelNode]()
    var container: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        allButtons = []
        
        for i in 1...5 {
            allButtons.append(childNodeWithName("video\(i)") as! SKLabelNode)
        }
        
        container = childNodeWithName("container") as! SKSpriteNode
        
        playVideo("video1")
        addGestureRecognizers(view)
    }
    
    func playVideo(filename: String) {
        let path = NSBundle.mainBundle().pathForResource(filename, ofType:"mp4")!
        
        playerItem1 = AVPlayerItem(URL: NSURL(fileURLWithPath: path))
        playerItem2 = AVPlayerItem(URL: NSURL(fileURLWithPath: path))
        
        player = AVQueuePlayer(items: [playerItem1, playerItem2])
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRectMake(850, 250, 960, 540)
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
        
        playVideo("video\(focusedVideo.rawValue + 1)")
        
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
        // remove player layer
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
            scene.fileName = "video\(self.focusedVideo.rawValue + 1)"
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene)
        }
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
        focusedVideo.prev()
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer) {
        focusedVideo.next()
    }
    
    func updateConainerPosition() {
        container.position = CGPointMake(container.position.x, allButtons[focusedVideo.rawValue].position.y)
    }
    
    func buttonPressed(sender: UITapGestureRecognizer) {
        navigateToPlaybackScene()
    }
}
