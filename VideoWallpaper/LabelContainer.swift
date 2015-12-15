//
//  LabelContainer.swift
//  VideoWallpaper
//
//  Created by Atikur Rahman on 12/15/15.
//  Copyright © 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class LabelContainer: SKSpriteNode {
    
    var label: SKLabelNode!
    
    func setupLabel() {
        label = SKLabelNode(fontNamed: "DINAlternate-Bold")
        label.zPosition = 10
        label.fontColor = SKColor.whiteColor()
        label.fontSize = 55
        label.position = CGPointMake(115, -21)
        label.text = "label"
        label.horizontalAlignmentMode = .Right
    }
    
    init(imageNamed: String) {
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: SKColor.whiteColor(), size: texture.size())
        
        self.setupLabel()
        self.addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
