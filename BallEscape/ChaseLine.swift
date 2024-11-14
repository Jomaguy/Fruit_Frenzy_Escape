//
//  ChaseLine.swift
//  BallEscape
//
//  Created by Jonathan Mahrt Guyou on 11/14/24.
//


import SpriteKit

class ChaseLine {
    var node: SKShapeNode
    var speed: CGFloat
    var lastSpeedIncreaseTime: TimeInterval = 0
    let speedIncreaseInterval: TimeInterval = 10

    init(width: CGFloat, startPosition: CGPoint, initialSpeed: CGFloat) {
        node = SKShapeNode(rectOf: CGSize(width: width, height: 5))
        node.position = startPosition
        node.fillColor = .green
        speed = initialSpeed
    }

    func update(currentTime: TimeInterval, playerPosition: CGPoint) {
        // Move the chase line down
        node.position.y -= speed * CGFloat(1.0 / 60.0)

        // Increase speed every 20 seconds
        if currentTime - lastSpeedIncreaseTime >= speedIncreaseInterval {
            speed += 20
            lastSpeedIncreaseTime = currentTime
        }
    }

    func hasCaughtPlayer(playerPosition: CGPoint) -> Bool {
        return node.position.y <= playerPosition.y
    }
}

// End of file. No additional code.
