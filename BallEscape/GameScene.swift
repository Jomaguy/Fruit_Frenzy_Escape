//
//  GameScene.swift
//  BallEscape
//
//  Created by Jonathan Mahrt Guyou on 11/12/24.
//
//
import SpriteKit

class GameScene: SKScene {

    // Add this line
    var player: Player!
    var chaseLine: ChaseLine!
    var platformManager: PlatformManager! // Add this line
    var obstacleManager: ObstacleManager!
    
  
    // Other properties remain the same
    var timeElapsed: TimeInterval = 0
    var lastTapTime: TimeInterval = 0
    let doubleTapInterval: TimeInterval = 0.3
    var gameCamera: SKCameraNode!

    // Add this property
    var background: SKSpriteNode!

    // Add this property
    var speedLabel: SKLabelNode!

    // Add these properties
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    var lastPlatformY: CGFloat = 0

    // Remove this property as we won't need it
    // var isOnPlatform: Bool = false

    // Add this property to keep track of the highest platform reached
    var highestPlatformReached: Int = 0

    // Add this property
    var gameOverHandler: GameOverHandler?

    override func didMove(to view: SKView) {
        // Add this line to create the background
        createBackground()

        // Initialize the camera
        gameCamera = SKCameraNode()
        camera = gameCamera
        addChild(gameCamera)
        
        // Initialize PlatformManager
        platformManager = PlatformManager(scene: self)
        obstacleManager = ObstacleManager(scene: self)
        
        // Initial platform setup with consistent spacing
        platformManager.spawnInitialPlatforms(startY: frame.height * 0.3)
        
        createPlayer()
        createScreenBoundaries()
        createChaseLine()
        
        // Add this line to create the speed label
        createSpeedLabel()
        
        // Add this line to create the score label
        createScoreLabel()

        // Set the initial lastPlatformY
        lastPlatformY = frame.height * 0.4 + 10 + 10 // Same as initial player position
        
        // Initialize the GameOverHandler
        gameOverHandler = GameOverHandler(scene: self, score: 0)
    }

    func createPlayer() {
        let playerPosition = CGPoint(x: frame.midX, y: frame.height * 0.4 + 10 + 10)
        player = Player(position: playerPosition)
        addChild(player.node)
    }

    func createScreenBoundaries() {
        let leftBoundary = SKNode()
        leftBoundary.position = CGPoint(x: 0, y: frame.midY)
        leftBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: frame.height))
        leftBoundary.physicsBody?.isDynamic = false
        addChild(leftBoundary)
        
        let rightBoundary = SKNode()
        rightBoundary.position = CGPoint(x: frame.width, y: frame.midY)
        rightBoundary.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1, height: frame.height))
        rightBoundary.physicsBody?.isDynamic = false
        addChild(rightBoundary)
    }

    func createChaseLine() {
        // Replace the content of this function with:
        let startPosition = CGPoint(x: frame.midX, y: frame.height * 0.6)
        chaseLine = ChaseLine(width: frame.width, startPosition: startPosition, initialSpeed: 100)
        addChild(chaseLine.node)
    }

    // Add this function to create the background
    func createBackground() {
        background = SKSpriteNode(imageNamed: "fridgeBackground")
        background.size = self.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1 // Ensure the background is behind other nodes
        addChild(background)
    }

    // Add this function to create the speed label
    func createSpeedLabel() {
        speedLabel = SKLabelNode(fontNamed: "Arial")
        speedLabel.fontSize = 16
        speedLabel.fontColor = .white
        speedLabel.position = CGPoint(x: 20, y: frame.height - 60) // Adjusted y-position
        speedLabel.horizontalAlignmentMode = .left
        speedLabel.zPosition = 100 // Ensure it's above other elements
        addChild(speedLabel)
    }

    // Add this function to create the score label
    func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Arial")
        scoreLabel.fontSize = 16
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.width - 20, y: frame.height - 60)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.zPosition = 100 // Ensure it's above other elements
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentTime = touch.timestamp
        let touchLocation = touch.location(in: self)

        if currentTime - lastTapTime < doubleTapInterval {
            player.jump()
        } else {
            player.movementDirection = touchLocation.x < frame.midX ? -1 : 1
        }

        lastTapTime = currentTime
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.stopMoving()
    }

    override func update(_ currentTime: TimeInterval) {
        // Move the camera to follow the player's vertical position
        gameCamera.position = CGPoint(x: frame.midX, y: player.node.position.y)

        // Update the chase line
        chaseLine.update(currentTime: currentTime, playerPosition: player.node.position)


        // Check if the chase line has reached the player
        if chaseLine.hasCaughtPlayer(playerPosition: player.node.position) {
            gameOver()
        }

        // Move the player horizontally based on the movement direction
        player.move(in: frame)

        // Spawn new platforms based on the camera's position to prevent gaps
        if platformManager.lastPlatformY > gameCamera.position.y - frame.height {
            platformManager.lastPlatformY -= platformManager.platformSpacing
            platformManager.spawnPlatform(yPosition: platformManager.lastPlatformY)
        }

        // Remove platforms that are off the top of the screen
        platformManager.cleanupPlatforms(playerY: player.node.position.y, screenHeight: frame.height)

        // Add this line to update the background position
        background.position = CGPoint(x: frame.midX, y: gameCamera.position.y)

        // Update the speed label
        updateSpeedLabel()

        // Update the score label
        updateScoreLabel()

        // Add this line to check for new platform
        checkNewPlatform()

        // Check if player has reached a new platform
        
    }

    // Add this function to update the speed label
    func updateSpeedLabel() {
        let speed = Int(chaseLine.speed)
        speedLabel.text = "Speed: \(speed)"
        
        // Update the label's position relative to the camera
        speedLabel.position = CGPoint(x: gameCamera.position.x - frame.width / 2 + 20,
                                      y: gameCamera.position.y + frame.height / 2 - 60) // Adjusted y-position
    }

    // Add this function to update the score label
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
        
        // Update the label's position relative to the camera
        scoreLabel.position = CGPoint(x: gameCamera.position.x + frame.width / 2 - 20,
                                      y: gameCamera.position.y + frame.height / 2 - 60)
    }

    // Modify the checkNewPlatform function
    func checkNewPlatform() {
        let playerY = player.node.position.y
        let currentPlatformIndex = Int((playerY - frame.height * 0.3) / platformManager.platformSpacing)
        
        if currentPlatformIndex > highestPlatformReached {
            highestPlatformReached = currentPlatformIndex
            score = highestPlatformReached
            // Add this line to update the score label immediately
            updateScoreLabel()
        }
    }

    func gameOver() {
        // Remove this line
        // self.isPaused = true // Pauses the game scene

        // Update the score in the GameOverHandler
        gameOverHandler?.score = score

        // Call the handleGameOver method
        gameOverHandler?.handleGameOver()
    }
}
