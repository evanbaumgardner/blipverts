//
//  GameViewController.swift
//  VideoWallpaper
//
//  Created by Atikur Rahman on 12/01/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsDrawCount = false
        
        skView.ignoresSiblingOrder = true
        
        let scene = MenuScene(fileNamed: "MenuScene")!
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
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
}
