//
//  GameOverHandler.swift
//  BallEscape
//
//  Created by Jonathan Mahrt Guyou on 11/14/24.
//


import SpriteKit

class GameOverHandler {
    weak var scene: SKScene?
    var score: Int
    
    init(scene: SKScene, score: Int) {
        self.scene = scene
        self.score = score
    }
    
    func handleGameOver() {
        guard let scene = scene else { return }
        
        // Freeze the screen
        scene.isPaused = true
        
        // Create black overlay
        let blackOverlay = SKSpriteNode(color: .black, size: scene.size)
        blackOverlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        blackOverlay.zPosition = 1000
        blackOverlay.alpha = 1.0
        scene.addChild(blackOverlay)
        
        // Create "Game Over" text
        let gameOverLabel = SKLabelNode(fontNamed: "Arial-Bold")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .yellow
        gameOverLabel.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY + 50)
        gameOverLabel.zPosition = 1001
        scene.addChild(gameOverLabel)
        
        // Create score text
        let scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY - 50)
        scoreLabel.zPosition = 1001
        scene.addChild(scoreLabel)
        
        scene.camera?.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
    }
}
