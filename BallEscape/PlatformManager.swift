//
//  PlatformManager.swift
//  BallEscape
//
//  Created by Jonathan Mahrt Guyou on 11/14/24.
//
//

import SpriteKit

class PlatformManager {
    weak var scene: SKScene?
    var platforms: [SKNode] = []
    var lastPlatformY: CGFloat = 0
    var platformIndex: Int = 0
    let platformSpacing: CGFloat = 200
    let holeWidth: CGFloat = 50

    init(scene: SKScene) {
        self.scene = scene
    }

    // Add this function to spawn initial platforms
    func spawnInitialPlatforms(startY: CGFloat) {
        lastPlatformY = startY
        while lastPlatformY > -scene!.frame.height {
            spawnPlatform(yPosition: lastPlatformY)
            lastPlatformY -= platformSpacing
        }
    }

    func spawnPlatform(yPosition: CGFloat) {
        guard let scene = scene else { return }

        let platformHeight: CGFloat = 20
        let gapPosition = CGFloat.random(in: holeWidth...(scene.frame.width - holeWidth))

        // Create the left segment of the platform
        let leftSegmentWidth = gapPosition - holeWidth / 2
        let leftSegment = SKSpriteNode(color: .white, size: CGSize(width: leftSegmentWidth, height: platformHeight))
        leftSegment.position = CGPoint(x: leftSegmentWidth / 2, y: yPosition)
        leftSegment.physicsBody = SKPhysicsBody(rectangleOf: leftSegment.size)
        leftSegment.physicsBody?.isDynamic = false
        scene.addChild(leftSegment)
        platforms.append(leftSegment)

        // Create the right segment of the platform
        let rightSegmentWidth = scene.frame.width - gapPosition - holeWidth / 2
        let rightSegment = SKSpriteNode(color: .white, size: CGSize(width: rightSegmentWidth, height: platformHeight))
        rightSegment.position = CGPoint(x: gapPosition + holeWidth / 2 + rightSegmentWidth / 2, y: yPosition)
        rightSegment.physicsBody = SKPhysicsBody(rectangleOf: rightSegment.size)
        rightSegment.physicsBody?.isDynamic = false
        scene.addChild(rightSegment)
        platforms.append(rightSegment)
        
        print("Platform \(platformIndex) spawned at yPosition: \(yPosition)")
        platformIndex += 1

        lastPlatformY = yPosition
        
        // Notify ObstacleManager to spawn an obstacle on this platform
        NotificationCenter.default.post(name: .spawnObstacle, object: nil, userInfo: ["leftSegment": leftSegment, "rightSegment": rightSegment, "platformY": yPosition])
    }

    func cleanupPlatforms(playerY: CGFloat, screenHeight: CGFloat) {
        platforms.removeAll { platform in
            if platform.position.y > playerY + screenHeight {
                platform.removeFromParent()
                return true
            }
            return false
        }
    }
}

// Add this extension to define a custom notification name
extension Notification.Name {
    static let spawnObstacle = Notification.Name("spawnObstacle")
}

// End of file. No additional code.
