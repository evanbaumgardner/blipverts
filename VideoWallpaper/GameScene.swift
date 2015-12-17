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
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var fileName: String!
    
    override func didMoveToView(view: SKView) {
        playVideo()
    }
    
    func playVideo() {
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType:"mp4")!
        player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = scene!.view!.frame
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
    
    func playerItemDidReachEnd(notification: NSNotification) {
        print("repeating...")
        
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        player.seekToTime(seekTime)
        player.play()
    }
    
    func returnToMenu() {
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
            let scene = MenuScene(size: self.size)
            scene.scaleMode = self.scaleMode
            self.view?.presentScene(scene)
        }
    }
}
