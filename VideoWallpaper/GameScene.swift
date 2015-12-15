//
//  GameScene.swift
//  VideoWallpaper
//
//  Created by Atikur Rahman on 12/01/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import AVKit
import SpriteKit

class GameScene: SKScene {
    
    var player: AVQueuePlayer!
    var playerLayer: AVPlayerLayer!
    
    var playerItem1: AVPlayerItem!
    var playerItem2: AVPlayerItem!
    var fileName: String!
    
    override func didMoveToView(view: SKView) {
        playVideo()
    }
    
    func playVideo() {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType:"mp4")!
        
        playerItem1 = AVPlayerItem(URL: NSURL(fileURLWithPath: path))
        playerItem2 = AVPlayerItem(URL: NSURL(fileURLWithPath: path))
        
        player = AVQueuePlayer(items: [playerItem1, playerItem2])
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = scene!.view!.frame
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
    
    func returnToMenu() {
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
            let scene = MenuScene(fileNamed: "MenuScene")!
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene)
        }
    }
}
