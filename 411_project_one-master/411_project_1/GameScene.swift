//
//  GameScene.swift
//  411Car
//
//  Created by Xianghui Huang on 3/03/19.
//  Copyright © 2019 Xianghui Huang. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var player:AVAudioPlayer = AVAudioPlayer()
    var leftSpaceship = SKSpriteNode()
    var rightSpaceship = SKSpriteNode()
    
    var canMove = false
    var leftToMoveLeft = true
    var rightToMoveRight = true
    
    var leftAtRight = false
    var rightAtLeft = false
    var centerPoint : CGFloat!
    
    
    var score = 0
    
    
    let leftSpaceshipMax :CGFloat = -260
    let leftSpaceshipMin : CGFloat = -50
    
    let rightSpaceshipMax :CGFloat = 50
    let rightSpaceshipMin :CGFloat = 260
    
    
    var count = 1
    var stopEverything = true
    var scoreText = SKLabelNode()
    
    var gameSettings = Settings.sharedInstance
    
    override func didMove(to view: SKView) {
        
        do{
            let audioPath = Bundle.main.path(forResource: "Theme", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!)as URL)
        }
        catch{
            // error
        }
        player.play()
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUp()
        
        physicsWorld.contactDelegate = self
        
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector:#selector(GameScene.createSpaceRoad), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector:#selector(GameScene.startCountDown), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(GameAssist().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.leftTraffic), userInfo:nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(GameAssist().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.rightTraffic), userInfo:nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector:#selector(GameScene.increaseScore), userInfo: nil, repeats: true)
        }
    }
    
    
   
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "leftCar" || contact.bodyA.node?.name == "rightCar"{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        firstBody.node?.removeFromParent()
        afterCollision()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if touchLocation.x > centerPoint{
                if rightAtLeft{
                    rightAtLeft = false
                    rightToMoveRight = true
                }else{
                    rightAtLeft = true
                    rightToMoveRight = false
                }
            }else{
                if leftAtRight{
                    leftAtRight = false
                    leftToMoveLeft = true
                }else{
                    leftAtRight = true
                    leftToMoveLeft = false
                }
                
            }
            canMove = true
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if canMove{
            move(leftSide:leftToMoveLeft)
            moveRightCar(rightSide: rightToMoveRight)
        }
        showRoad()
    }
    func setUp(){
        leftSpaceship = self.childNode(withName: "leftSpaceship") as! SKSpriteNode
        rightSpaceship = self.childNode(withName: "rightSpaceship") as! SKSpriteNode
        centerPoint = self.frame.size.width / self.frame.size.height
        
        leftSpaceship.physicsBody?.categoryBitMask = ColliderType.OBJECT_COLLIDER
        leftSpaceship.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_1
        leftSpaceship.physicsBody?.collisionBitMask = 0
        
        rightSpaceship.physicsBody?.categoryBitMask = ColliderType.OBJECT_COLLIDER
        rightSpaceship.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_2
        rightSpaceship.physicsBody?.collisionBitMask = 0
        
        let scoreBackGround = SKShapeNode(rect:CGRect(x:-self.size.width/2 + 70 ,y:self.size.height/2 - 130 ,width:180,height:80), cornerRadius: 20)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        scoreText.name = "score"
        scoreText.fontName = "AvenirNext-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width/2 + 160, y: self.size.height/2 - 110)
        scoreText.fontSize = 50
        scoreText.zPosition = 4
        addChild(scoreText)
    }
    
   @objc func createSpaceRoad(){
        let leftRoad = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        leftRoad.strokeColor = SKColor.red
        leftRoad.fillColor = SKColor.red
        leftRoad.alpha = 0.5
        leftRoad.name = "leftRoadStrip"
        leftRoad.zPosition = 10
        leftRoad.position.x = -160
        leftRoad.position.y = 700
        addChild(leftRoad)
        
        let rightRoad = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        rightRoad.strokeColor = SKColor.red
        rightRoad.fillColor = SKColor.red
        rightRoad.alpha = 0.5
        rightRoad.name = "rightRoadStrip"
        rightRoad.zPosition = 10
        rightRoad.position.x = 160
        rightRoad.position.y = 700
        addChild(rightRoad)
    }
    
    func showRoad(){
        
        enumerateChildNodes(withName: "leftRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
        
        enumerateChildNodes(withName: "rightRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 30
        })
        
        enumerateChildNodes(withName: "block", using: { (leftblock, stop) in
            let block = leftblock as! SKSpriteNode
            block.position.y -= 15
        })
        
        enumerateChildNodes(withName: "block", using: { (rightblock, stop) in
            let block = rightblock as! SKSpriteNode
            block.position.y -= 15
        })
        
    }
    
  @objc  func removeItems(){
        for child in children{
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
        
    }
    
    
    func move(leftSide:Bool){
        if leftSide{
            leftSpaceship.position.x -= 20
            if leftSpaceship.position.x < leftSpaceshipMin{
                leftSpaceship.position.x = leftSpaceshipMin
            }
        }else{
            leftSpaceship.position.x += 20
            if leftSpaceship.position.x > leftSpaceshipMax{
                leftSpaceship.position.x = leftSpaceshipMax
            }
            
            
        }
    }
    
    func moveRightCar(rightSide:Bool){
        if rightSide{
            rightSpaceship.position.x += 20
            if rightSpaceship.position.x > rightSpaceshipMax{
                rightSpaceship.position.x = rightSpaceshipMax
            }
        }else{
            rightSpaceship.position.x -= 20
            if rightSpaceship.position.x < rightSpaceshipMin{
                rightSpaceship.position.x = rightSpaceshipMin
                
            }
        }
    }
    
    
   @objc func leftTraffic(){
        if !stopEverything{
            let leftTrafficItem : SKSpriteNode!
            let randonNumber = GameAssist().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
            switch Int(randonNumber) {
            case 1...4:
                leftTrafficItem = SKSpriteNode(imageNamed: "block")
                leftTrafficItem.name = "block"
                break
            case 5...8:
                leftTrafficItem = SKSpriteNode(imageNamed: "block")
                leftTrafficItem.name = "block"
                break
            default:
                leftTrafficItem = SKSpriteNode(imageNamed: "block")
                leftTrafficItem.name = "block"
            }
            leftTrafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            leftTrafficItem.zPosition = 10
            let randomNum = GameAssist().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
            switch Int(randomNum) {
            case 1...4:
                leftTrafficItem.position.x = -280
                break
            case 5...10:
                leftTrafficItem.position.x = -100
                break
            default:
                leftTrafficItem.position.x = -280
            }
            leftTrafficItem.position.y = 700
            leftTrafficItem.physicsBody = SKPhysicsBody(circleOfRadius: leftTrafficItem.size.height/2)
            leftTrafficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_1
            leftTrafficItem.physicsBody?.collisionBitMask = 0
            leftTrafficItem.physicsBody?.affectedByGravity = false
            addChild(leftTrafficItem)
        }
    }
    
    
   @objc func rightTraffic(){
        if !stopEverything{
            let rightTrafficItem : SKSpriteNode!
            let randonNumber = GameAssist().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 8)
            switch Int(randonNumber) {
            case 1...4:
                rightTrafficItem = SKSpriteNode(imageNamed: "block")
                rightTrafficItem.name = "block"
                break
            case 5...8:
                rightTrafficItem = SKSpriteNode(imageNamed: "block")
                rightTrafficItem.name = "block"
                break
            default:
                rightTrafficItem = SKSpriteNode(imageNamed: "block")
                rightTrafficItem.name = "block"
            }
            rightTrafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            rightTrafficItem.zPosition = 10
            let randomNum = GameAssist().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
            switch Int(randomNum) {
            case 1...4:
                rightTrafficItem.position.x = 280
                break
            case 5...10:
                rightTrafficItem.position.x = 100
                break
            default:
                rightTrafficItem.position.x = 280
            }
            rightTrafficItem.position.y = 700
            rightTrafficItem.position.y = 700
            rightTrafficItem.physicsBody = SKPhysicsBody(circleOfRadius: rightTrafficItem.size.height/2)
            rightTrafficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_2
            rightTrafficItem.physicsBody?.collisionBitMask = 0
            rightTrafficItem.physicsBody?.affectedByGravity = false
            addChild(rightTrafficItem)
        }
    }
    
    func afterCollision(){
        if gameSettings.highScore < score{
            gameSettings.highScore = score
        }
        let menuScene = SKScene(fileNamed: "GameMenu")!
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(2)))
    }
    
    
   @objc func startCountDown(){
        if count>0{
            if count < 4{
                let countDownLabel = SKLabelNode()
                countDownLabel.fontName = "Bold"
                countDownLabel.fontColor = SKColor.white
                countDownLabel.fontSize = 300
                countDownLabel.text = String(count)
                countDownLabel.position = CGPoint(x: 0, y: 0)
                countDownLabel.zPosition = 300
                countDownLabel.name = "cLabel"
                countDownLabel.horizontalAlignmentMode = .center
                addChild(countDownLabel)
                
                let deadTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: deadTime, execute: {
                    countDownLabel.removeFromParent()
                })
            }
            count += 1
            if count == 4 {
                self.stopEverything = false
            }
        }
    }
    
  @objc  func increaseScore(){
        if !stopEverything{
            score += 1
            scoreText.text = String(score)
        }
    }
    
}
