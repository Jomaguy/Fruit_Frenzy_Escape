//
//  Player.swift
//  BallEscape
//
//  Created by Jonathan Mahrt Guyou on 11/14/24.
//


// Player.swift

import SpriteKit

class Player {
    var node: SKSpriteNode
    var movementDirection: CGFloat = 0
    let jumpForce: CGFloat = 20
    let moveSpeed: CGFloat = 300

    init(position: CGPoint) {
        
        node = SKSpriteNode(imageNamed: "Tommy2")
        node.size = CGSize(width: 40, height: 40)

        node.position = position
        
        // Create a circular physics body instead of a texture-based one
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = true
        
        // Add these lines to prevent rotation and dampen movement
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.linearDamping = 0.9
        node.physicsBody?.angularDamping = 0.9
        
    }

    func move(in frame: CGRect) {
        if movementDirection != 0 {
            let newXPosition = node.position.x + movementDirection * moveSpeed * CGFloat(1.0 / 60.0)
            // Constrain the player within the screen bounds
            node.position.x = max(node.frame.width / 2, min(newXPosition, frame.width - node.frame.width / 2))
        }
    }

    func jump() {
        let verticalJump = CGVector(dx: 0, dy: jumpForce)
        node.physicsBody?.applyImpulse(verticalJump)
    }

    func stopMoving() {
        movementDirection = 0
        node.physicsBody?.velocity.dx = 0
    }
}

// End of file. No additional code.
