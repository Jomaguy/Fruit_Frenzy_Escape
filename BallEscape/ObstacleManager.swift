//
//  ObstacleManager.swift
//  BallEscape
//
//  Created by Jonathan Mahrt Guyou on 11/14/24.
//


import SpriteKit

class ObstacleManager {
    weak var scene: SKScene?
    let staticObstacleImages = ["StaticApple", "StaticBrocoli"]
    
    init(scene: SKScene) {
        self.scene = scene
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleSpawnObstacle(_:)), name: .spawnObstacle, object: nil)
    }
    
    @objc private func handleSpawnObstacle(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let leftSegment = userInfo["leftSegment"] as? SKSpriteNode,
              let rightSegment = userInfo["rightSegment"] as? SKSpriteNode,
              let platformY = userInfo["platformY"] as? CGFloat else {
            return
        }
        
        spawnStaticObject(onPlatform: leftSegment, rightSegment: rightSegment, platformY: platformY)
    }

    func spawnStaticObject(onPlatform leftSegment: SKSpriteNode, rightSegment: SKSpriteNode, platformY: CGFloat) {
        guard let scene = scene else { return }

        let randomImageName = staticObstacleImages.randomElement() ?? "static1"
        let object = SKSpriteNode(imageNamed: randomImageName)
        
        object.size = CGSize(width: 50, height: 50)
        
        object.physicsBody = SKPhysicsBody(texture: object.texture!, size: object.size)
        object.physicsBody?.isDynamic = false

        // Determine which segment to place the object on
        let segment = Bool.random() ? leftSegment : rightSegment

        // Calculate the valid range for placing the object
        let minX = segment.frame.minX + object.size.width / 2
        let maxX = segment.frame.maxX - object.size.width / 2

        // Check if the range is valid
        if minX < maxX {
            // Use random position within the valid range
            object.position = CGPoint(
                x: CGFloat.random(in: minX...maxX),
                y: platformY + object.size.height / 2 + 10
            )
        } else {
            // Fallback to center of the segment if range is invalid
            object.position = CGPoint(
                x: segment.frame.midX,
                y: platformY + object.size.height / 2 + 10
            )
        }

        scene.addChild(object)
    }
}

// End of file. No additional code.
