//
//  GameScene.swift
//  CorgiPingPong
//
//  Created by Alyx on 4/20/23.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private let ballCategory: UInt32 = 0x1 << 0
    private var leftPaddle: SKSpriteNode!
    private var rightPaddle: SKSpriteNode!
    private var ball: SKSpriteNode!
    private var leftScoreLabel: SKLabelNode!
    private var rightScoreLabel: SKLabelNode!
    private var leftScore = 0
    private var rightScore = 0

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.black
        setupNodes()
        setupPhysics()
        ball.physicsBody?.applyImpulse(randomInitialVelocity())

    }

    private func setupNodes() {
        leftPaddle = SKSpriteNode(imageNamed: "corgi_head")
        leftPaddle.position = CGPoint(x: frame.minX + leftPaddle.size.width, y: frame.midY)
        leftPaddle.physicsBody = SKPhysicsBody(rectangleOf: leftPaddle.size)
        leftPaddle.physicsBody?.isDynamic = false
        addChild(leftPaddle)

        rightPaddle = SKSpriteNode(imageNamed: "corgi_head")
        rightPaddle.position = CGPoint(x: frame.maxX - rightPaddle.size.width, y: frame.midY)
        rightPaddle.physicsBody = SKPhysicsBody(rectangleOf: rightPaddle.size)
        rightPaddle.physicsBody?.isDynamic = false
        addChild(rightPaddle)

        ball = SKSpriteNode(imageNamed: "fried_chicken_leg")
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.angularDamping = 0.0
        addChild(ball)

        leftScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        leftScoreLabel.fontSize = 36
        leftScoreLabel.fontColor = SKColor.white
        leftScoreLabel.position = CGPoint(x: frame.midX - 50, y: frame.maxY - 120)
        leftScoreLabel.text = "\(leftScore)"
        addChild(leftScoreLabel)

        rightScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        rightScoreLabel.fontSize = 36
        rightScoreLabel.fontColor = SKColor.white
        rightScoreLabel.position = CGPoint(x: frame.midX + 50, y: frame.maxY - 120)
        rightScoreLabel.text = "\(rightScore)"
        addChild(rightScoreLabel)
    }

    private let hitSound = SKAction.playSoundFileNamed("ball_hit.mp3", waitForCompletion: false)

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        let border = SKPhysicsBody(edgeLoopFrom: frame)
        border.friction = 0.0
        physicsBody = border
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches: touches)
    }

    private func handleTouches(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)

        if touchLocation.x <= frame.midX {
            leftPaddle.run(SKAction.moveTo(y: touchLocation.y, duration: 0.1))
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ballCategory || contact.bodyB.categoryBitMask == ballCategory {
            run(hitSound) // Play the hit sound effect
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Ensure minimum horizontal velocity
        if abs(ball.physicsBody!.velocity.dx) < 150 {
            let newDX = ball.physicsBody!.velocity.dx < 0 ? -150 : 150
            ball.physicsBody!.velocity.dx = CGFloat(newDX)
        }
        // AI for right paddle
        rightPaddle.run(SKAction.moveTo(y: ball.position.y, duration: 0.4))

        // Update score and reset ball
        if ball.position.x <= frame.minX + ball.size.width {
            rightScore += 1
            rightScoreLabel.text = "\(rightScore)"
            resetBall()
        } else if ball.position.x >= frame.maxX - ball.size.width {
            leftScore += 1
            leftScoreLabel.text = "\(leftScore)"
            resetBall()
        }
    }


    private func resetBall() {
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.applyImpulse(randomInitialVelocity())
    }

    private func randomInitialVelocity() -> CGVector {
        let dx = CGFloat(arc4random_uniform(2) == 0 ? -120 : 120) // Increase the magnitude from 100 to 120
        let dy = CGFloat(arc4random_uniform(201)) - 100
        return CGVector(dx: dx, dy: dy)
    }

    }
