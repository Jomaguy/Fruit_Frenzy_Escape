//
//  GameScene.swift
//  BallEscape
//
//  Created by Jonathan Mahrt Guyou on 11/12/24.
//
//
import SpriteKit
class GameScene: SKScene, SKPhysicsContactDelegate {
    // Your existing properties remain
    var player: SKSpriteNode!
    var platforms: [SKSpriteNode] = [] // Change to an array of platforms
    var holes: [SKShapeNode] = [] // Change to an array of holes
    
    // Add player movement properties
    var playerSpeed: CGFloat = 5.0
    var playerMovementDirection: CGFloat = 0.0
    
    // Define collision categories
    let playerCategory: UInt32 = 0x1 << 0
    let platformCategory: UInt32 = 0x1 << 1
    let holeCategory: UInt32 = 0x1 << 2
    
    // Add properties for platform generation
    let platformHeight: CGFloat = 20
    let platformGap: CGFloat = 200
    
    // Add this property to track the camera
    var gameCamera: SKCameraNode!
    
    // Add this property to track if the player is falling through a hole
    var isFallingThroughHole = false

    override func didMove(to view: SKView) {
        // Set up physics world
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // Set up initial platforms
        setupInitialPlatforms()
        
        // Set up the player
        setupPlayer()
        
        // Add this line to set up the camera
        setupCamera()
    }
    
    // Add this function to set up the camera
    func setupCamera() {
        gameCamera = SKCameraNode()
        gameCamera.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameCamera)
        camera = gameCamera
    }
    
    // Modify this function to set up initial platforms lower on the screen
    func setupInitialPlatforms() {
        let numberOfPlatforms = Int(frame.height / platformGap) + 1
        
        for i in 0..<numberOfPlatforms {
            // Change 0.3 to 0.2 to start platforms even lower
            let platformY = frame.height * 0.2 - CGFloat(i) * platformGap
            createPlatform(at: CGPoint(x: frame.midX, y: platformY))
        }
    }
    
    // Modify this function to create a platform with a hole
    func createPlatform(at position: CGPoint) {
        let platform = SKSpriteNode(color: .gray, size: CGSize(width: frame.width, height: platformHeight))
        platform.position = position
        
        // Add physics body to the platform
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.categoryBitMask = platformCategory
        
        addChild(platform)
        platforms.append(platform)
        
        // Create a hole in the platform
        createHole(in: platform)
    }
    
    // Modify this function to create a hole in the given platform
    func createHole(in platform: SKSpriteNode) {
        let holeWidth: CGFloat = 60
        let holePosition = CGPoint(x: CGFloat.random(in: holeWidth/2...frame.width - holeWidth/2), y: platform.position.y)
        
        let hole = SKShapeNode(rectOf: CGSize(width: holeWidth, height: platformHeight))
        hole.fillColor = .black
        hole.strokeColor = .clear
        hole.position = holePosition
        
        // Add physics body to the hole
        hole.physicsBody = SKPhysicsBody(rectangleOf: hole.frame.size)
        hole.physicsBody?.isDynamic = false
        hole.physicsBody?.categoryBitMask = holeCategory
        
        addChild(hole)
        holes.append(hole)
    }
    
    func setupPlayer() {
        player = SKSpriteNode(color: .red, size: CGSize(width: 15, height: 15))
        // Change 0.3 to 0.2 to start the player lower
        player.position = CGPoint(x: frame.midX, y: frame.height * 0.2 + platformHeight / 2 + player.size.height / 2)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = platformCategory
        player.physicsBody?.contactTestBitMask = holeCategory
        
        addChild(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerMovementDirection = 0.0
    }
    
    func handleTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        if touchLocation.x < frame.midX {
            playerMovementDirection = -1.0 // Move left
        } else {
            playerMovementDirection = 1.0 // Move right
        }
    }
    
    // Modify the update function to adjust the camera position
    override func update(_ currentTime: TimeInterval) {
        movePlayer()
        checkAndGenerateNewPlatforms()
        
        // Update camera position to follow the player
        // Change frame.height / 4 to frame.height / 5 to keep more of the lower part of the screen visible
        let targetY = player.position.y - frame.height / 5
        let cameraY = gameCamera.position.y
        let newY = cameraY + (targetY - cameraY) * 0.1 // Smooth camera movement
        gameCamera.position = CGPoint(x: frame.midX, y: newY)
    }
    
    func movePlayer() {
        let newX = player.position.x + (playerSpeed * playerMovementDirection)
        player.position.x = max(player.size.width / 2, min(newX, frame.width - player.size.width / 2))
    }
    
    func checkAndGenerateNewPlatforms() {
        guard let lowestPlatform = platforms.min(by: { $0.position.y < $1.position.y }) else { return }
        
        if player.position.y < lowestPlatform.position.y + frame.height / 2 {
            createPlatform(at: CGPoint(x: frame.midX, y: lowestPlatform.position.y - platformGap))
        }
        
        // Remove platforms that are above the screen
        platforms = platforms.filter { $0.position.y < frame.height + platformHeight }
        holes = holes.filter { $0.position.y < frame.height + platformHeight }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == playerCategory | holeCategory {
            // Player has entered a hole
            if !isFallingThroughHole {
                isFallingThroughHole = true
                player.physicsBody?.collisionBitMask &= ~platformCategory
                
                // Reset falling state and collision after a longer delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.isFallingThroughHole = false
                    self?.player.physicsBody?.collisionBitMask |= self?.platformCategory ?? 0
                }
            }
        } else if collision == playerCategory | platformCategory && !isFallingThroughHole {
            // Player has landed on a platform
            player.physicsBody?.collisionBitMask |= platformCategory
        }
    }
}
