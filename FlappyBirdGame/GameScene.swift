//
//  GameScene.swift
//  FlappyBird
//
//  Created by Nate Murray on 6/2/14.
//  Copyright (c) 2014 Fullstack.io. All rights reserved.
//

import SpriteKit
import WatchKit

class GameScene: SKScene {
    var bird: SKSpriteNode = SKSpriteNode()
    var skyColor: SKColor = SKColor(red: 21.0/255.0, green: 19.0/255.0, blue: 98.0/255.0, alpha: 1.0)
    var pipeTextureUp: SKTexture = SKTexture(image: UIImage(named: "PipeUp", in: Bundle(identifier: "com.mengdongfuture.FlappyBirdGame"), with: nil)!)
    var pipeTextureDown: SKTexture = SKTexture(image: UIImage(named: "PipeDown", in: Bundle(identifier: "com.mengdongfuture.FlappyBirdGame"), with: nil)!)
    var movePipesAndRemove: SKAction = SKAction()
    var moving: SKNode = SKNode()
    var pipes: SKNode = SKNode()
    var canRestart: Bool = true
    var scoreLabelNode: SKLabelNode = SKLabelNode(fontNamed: "Flappy Bird Font Regular")
    var score: Int = 0
    
    let birdCategory: UInt32 = 1 << 0
    let worldCategory: UInt32 = 1 << 1
    let pipeCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    
    override func sceneDidLoad() {
        canRestart = true
        moving.speed = 0
        
        // setup physics
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        self.physicsWorld.contactDelegate = self
        
        // setup background color
        self.backgroundColor = skyColor
        
        self.addChild(moving)
        moving.addChild(pipes)
        
        self.scaleMode = .aspectFill
        
        // ground
        let groundTexture = SKTexture(image: UIImage(named: "land", in: Bundle(identifier: "com.mengdongfuture.FlappyBirdGame"), with: nil)!)
        groundTexture.filteringMode = .nearest // shorter form for SKTextureFilteringMode.Nearest
        
        let groundTextureWidth = WKInterfaceDevice.current().screenBounds.width * 2.0
        let moveGroundSprite = SKAction.moveBy(x: -groundTextureWidth, y: 0, duration: TimeInterval(0.02 * groundTextureWidth))
        let resetGroundSprite = SKAction.moveBy(x: groundTextureWidth, y: 0, duration: 0.0)
        let moveGroundSpritesForever = SKAction.repeatForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / (WKInterfaceDevice.current().screenBounds.width / 4.0) * 2.0 ) {
            let sprite = SKSpriteNode(texture: groundTexture)
//            sprite.setScale(0.5)
            sprite.size = CGSize(
                width: WKInterfaceDevice.current().screenBounds.width,
                height: WKInterfaceDevice.current().screenBounds.width / 366 * 112
            )
            sprite.position = CGPoint(x: CGFloat(i) * sprite.size.width, y: 0)
            sprite.run(moveGroundSpritesForever)
            moving.addChild(sprite)
        }
        
        // skyline
        let skyTexture = SKTexture(image: UIImage(named: "sky", in: Bundle(identifier: "com.mengdongfuture.FlappyBirdGame"), with: nil)!)
        skyTexture.filteringMode = .nearest
        
//        let skyTextureWidth = WKInterfaceDevice.current().screenBounds.width * 2
        let skyTextureWidth = WKInterfaceDevice.current().screenBounds.width
        let moveSkySprite = SKAction.moveBy(x: -skyTextureWidth, y: 0, duration: TimeInterval(0.1 * skyTextureWidth))
        let resetSkySprite = SKAction.moveBy(x: skyTextureWidth, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        
        for i in 0 ..< 2 + Int(self.frame.size.width / (skyTextureWidth / 2.0) * 2.0) {
            let sprite = SKSpriteNode(texture: skyTexture)
//            sprite.setScale(0.5)
            sprite.size = CGSize(
                width: WKInterfaceDevice.current().screenBounds.width,
                height: WKInterfaceDevice.current().screenBounds.width / 1668 * 1180
            )
            sprite.zPosition = -20
            sprite.position = CGPoint(
                x: CGFloat(i) * sprite.size.width,
                y: WKInterfaceDevice.current().screenBounds.width / 1668 * 1180 / 2 + WKInterfaceDevice.current().screenBounds.width / 366 * 112 / 2 / 1.2
            )
            sprite.run(moveSkySpritesForever)
            moving.addChild(sprite)
        }
        
        // create the pipes textures
        pipeTextureUp.filteringMode = .nearest
        pipeTextureDown.filteringMode = .nearest
        
        // create the pipes movement actions
        let distanceToMove = CGFloat(self.frame.size.width + 2.0 * 30)
        let movePipes = SKAction.moveBy(x: -distanceToMove, y: 0.0, duration: TimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        // spawn the pipes
        let spawn = SKAction.run(spawnPipes)
        let delay = SKAction.wait(forDuration: TimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        // setup our bird
        let birdTexture1 = SKTexture(image: UIImage(named: "cloud-01", in: Bundle(identifier: "com.mengdongfuture.FlappyBirdGame"), with: nil)!)
        birdTexture1.filteringMode = .nearest
        let birdTexture2 = SKTexture(image: UIImage(named: "cloud-02", in: Bundle(identifier: "com.mengdongfuture.FlappyBirdGame"), with: nil)!)
        birdTexture2.filteringMode = .nearest
        
        let anim = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.size = CGSize(width: 176 * 0.14, height: 176 * 0.14)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height / 2.0)
        bird.run(flap, withKey: "flap")
        
        self.addChild(bird)
        
        // create the ground
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: 20)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 13))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = worldCategory
        self.addChild(ground)
        
        // Initialize label and create a label which holds the score
        scoreLabelNode.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = String(score)
        scoreLabelNode.fontSize = 20
        scoreLabelNode.fontColor = .white
        self.addChild(scoreLabelNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if let physicsBody = bird.physicsBody {
            let value = physicsBody.velocity.dy * (physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) * 4
//            bird.zRotation = min(max(-1, value), 0.5)
        }
    }
    
    private func addBirdPhysicsBody() {
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody?.contactTestBitMask = worldCategory | pipeCategory
    }
    
    private func spawnPipes() {
        let verticalPipeGap = 70.0
        
        let pipePair = SKNode()
        pipePair.position = CGPoint(
            x: self.frame.size.width + 30 * 2,
            y: -(self.frame.midY/2) - 20
        )
        pipePair.zPosition = -10
        
        let height: UInt32 = UInt32(self.frame.size.height / 4 - 10)
        let y = Double(arc4random_uniform(height*2) + height)
        
        func pipeSpriteNode(texture: SKTexture) -> SKSpriteNode {
            let node = SKSpriteNode(texture: texture)
            
            node.size  = CGSize(width: 30, height: 160)
            
//            node.setScale(1)
            
            node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
            node.physicsBody?.isDynamic = false
            node.physicsBody?.categoryBitMask = pipeCategory
            node.physicsBody?.contactTestBitMask = birdCategory
            return node
        }
        
        let pipeDown = pipeSpriteNode(texture: pipeTextureDown)
        pipeDown.position = CGPoint(x: 0.0, y: y + Double(pipeDown.size.height) + verticalPipeGap)
        pipePair.addChild(pipeDown)

        let pipeUp = pipeSpriteNode(texture: pipeTextureUp)
        pipeUp.position = CGPoint(x: 0.0, y: y)
        pipePair.addChild(pipeUp)
        
        let contactNode = SKNode()
        contactNode.position = CGPoint(x: pipeDown.size.width - bird.size.width / 2, y: self.frame.size.height)
        contactNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeUp.size.width, height: self.frame.size.height))
        contactNode.physicsBody?.isDynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = birdCategory
        pipePair.addChild(contactNode)
        
        pipePair.run(movePipesAndRemove)
        pipes.addChild(pipePair)
    }
    
    private func resetScene() {
        
        let birdTexture1 = SKTexture(image: UIImage(named: "cloud-01", in: Bundle(identifier: "com.mengdongfuture.FlappyBirdGame"), with: nil)!)
        birdTexture1.filteringMode = .nearest
        let birdTexture2 = SKTexture(image: UIImage(named: "cloud-02", in: Bundle(identifier: "com.mengdongfuture.FlappyBirdGame"), with: nil)!)
        birdTexture2.filteringMode = .nearest
        let anim = SKAction.animate(with: [birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(anim)
        bird.run(flap, withKey: "flap")
        
        // Move bird to original position and reset velocity
        addBirdPhysicsBody()
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.midY)
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.collisionBitMask = worldCategory | pipeCategory
        bird.speed = 1.0
        bird.zRotation = 0.0
        
        // Remove all existing pipes
        pipes.removeAllChildren()
        
        // Reset _canRestart
        canRestart = false
        
        // Reset score
        score = 0
        scoreLabelNode.text = String(score)
        
        // Restart animation
        moving.speed = 0.7
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2))
    }
    
    public func tapGesture() {
        if moving.speed > 0  {
            WKInterfaceDevice.current().play(.start)
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 2))
        } else if canRestart {
            self.resetScene()
        }
    }
}
