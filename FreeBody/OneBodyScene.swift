//
//  OneBodyScene.swift
//  FreeBody
//
//  Created by Jackson Kearl on 12/30/14.
//  Copyright (c) 2014 Applications of Computer Science Club. All rights reserved.
//

import SpriteKit
import Darwin

class OneBodyScene: SKScene {

    var isOptionVisible = false
    var isRunning = false
    let basePosition: CGPoint?
    var forces: Stack<Force> = Stack<Force>()

    override func didMoveToView(view: SKView) {
        self.backgroundColor = FBColors.BlueDark
    }

    func triangleInRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> SKShapeNode {
        let rect = CGRectMake(x, y, width, height)
        let offsetX: CGFloat = CGRectGetMidX(rect)
        let offsetY: CGFloat = CGRectGetMidY(rect)
        var bezierPath: UIBezierPath = UIBezierPath()

        bezierPath.moveToPoint(CGPointMake(offsetX, 0))
        bezierPath.addLineToPoint(CGPointMake(-offsetX, offsetY))
        bezierPath.addLineToPoint(CGPointMake(-offsetX, -offsetY))
        bezierPath.closePath()

        let shape: SKShapeNode = SKShapeNode()
        shape.path = bezierPath.CGPath

        return shape
    }

    override init(size: CGSize) {
        super.init(size: size)

        basePosition = CGPointMake(self.size.width/2, self.size.height/2)

        let node = SKShapeNode(rectOfSize: CGSizeMake(self.size.width/4, self.size.width/4));
        node.fillColor = FBColors.Yellow
        node.lineWidth = 0
        node.name = "Node"
        node.position = basePosition!
        node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
        node.physicsBody?.dynamic = false
        self.addChild(node)

        let nodeCircle = SKShapeNode(circleOfRadius: 10)
        nodeCircle.fillColor = FBColors.Red
        nodeCircle.lineWidth = 0
        nodeCircle.name = "Node"
        node.addChild(nodeCircle)

        self.forces.push(Force(0,-9.8,identifier: 0x1))
        println("adding gravity to forces")


        let π = M_PI

        let force: SKShapeNode = self.forces.data[0].shapeNode(0, y: 0)
        let rotate = SKAction.rotateToAngle(CGFloat(3*π/2), duration: 0.0)

        force.runAction(rotate)
        force.name = "Force"
        node.addChild(force)
        println(self.forces.data)


        let backButton = FBButtonNode(text: "Main Menu", identifier: "Back", size: 24)
        backButton.name = "MainMenu"
        self.addChild(backButton)
        backButton.position = CGPointMake(backButton.size.width/2+backButton.size.height/2, backButton.size.height)

        let startButton = triangleInRect(0, y: 0, width: 32, height: 32)
        startButton.strokeColor = FBColors.YellowBright
        startButton.fillColor = FBColors.YellowBright
        startButton.name = "Play"
        addChild(startButton)
        startButton.position = CGPointMake(startButton.frame.size.width/2+startButton.frame.size.height/2, self.size.height-startButton.frame.size.height)

        let stopButton = SKShapeNode(rectOfSize: CGSizeMake(32, 32))
        stopButton.strokeColor = FBColors.YellowBright
        stopButton.fillColor = FBColors.YellowBright
        stopButton.name = "Pause"
        addChild(stopButton)
        stopButton.position = CGPointMake(stopButton.frame.size.width/2+stopButton.frame.size.height/2, self.size.height-stopButton.frame.size.height)
        stopButton.hidden = true

        let options = SKShapeNode(rectOfSize: CGSizeMake(self.size.width/3, self.size.height))
        options.fillColor = FBColors.Brown
        options.position = CGPointMake(self.size.width*7/6, self.size.height/2)
        options.name = "Options"
        options.lineWidth = 0
        self.addChild(options)

        let forcesAdd = FBButtonNode(text: "+", identifier: "AddForce", size: 24)
        forcesAdd.name = "ForcesAdd"
        options.addChild(forcesAdd)


        self.name = "Background"

    }

    func showOptionPane() {
        if !isOptionVisible {
            for child in children {
                let name = (child as SKNode).name
                if (name == "Node" || (child as SKNode).parent?.name == "Node") {
                    // move central node and children (force arrows in future maybe) to be in new center
                    (child as SKNode).runAction(SKAction.moveBy(CGVectorMake(-self.frame.width/6, 0), duration: 0.25))
                } else if (name == "MainMenu" ) {
                    //stay in the same place
                }
                else {
                    //move all the way. acts on option pane and children, along with all other nodes
                    (child as SKNode).runAction(SKAction.moveBy(CGVectorMake(-self.frame.width/3, 0), duration: 0.25))

                }
            }
            isOptionVisible = true
        }
    }

    func hideOptionPane() {
        if isOptionVisible {
            for child in children {
                let name = (child as SKNode).name
                if (name == "Node" || (child as SKNode).parent?.name == "Node") {
                    // move central node and children (force arrows in future maybe) to be in new center
                    (child as SKNode).runAction(SKAction.moveBy(CGVectorMake(+self.frame.width/6, 0), duration: 0.25))
                } else if (name == "MainMenu" ) {
                    //stay in the same place
                }
                else {
                    //move all the way. acts on option pane and children, along with all other nodes
                    (child as SKNode).runAction(SKAction.moveBy(CGVectorMake(+self.frame.width/3, 0), duration: 0.25))

                }
            }
            isOptionVisible = false
        }
    }

    func switchPlayButton() {
        isRunning = !isRunning

        let startButton = self.childNodeWithName("Play")
        let stopButton = self.childNodeWithName("Pause")

        if isRunning {
            // if physics is changed to running, start physics
            for node in self.children {
                (node as SKNode).physicsBody?.dynamic = true
            }
            startButton!.hidden = true
            startButton?.zPosition--
            stopButton!.hidden = false
            stopButton?.zPosition++
        }
        else {
            // Physics is changed to not running, turn it off! Move node to center
            for node in self.children {
                (node as SKNode).physicsBody?.dynamic = isRunning
                if (node as SKNode).name=="Node"{
                    println("moving node back to center")
                    (node as SKNode).position = basePosition!
                }
            }
            stopButton!.hidden = true
            stopButton?.zPosition--
            startButton!.hidden = false
            startButton?.zPosition++

        }
    }

    // add a force to the forces stack
    func addForce(){

        let bitLeft: UInt32 = UInt32(Int(self.forces.data.count) - 1)
        var identif: UInt32 = 0x1 << bitLeft


        let exampleForce: Force = Force(5,0,identifier: identif)

        self.forces.push(exampleForce)
        println("adding force with identifier: \(identif) || \(self.forces.data.count) objects in stack")
        if let object = self.childNodeWithName("Node"){
            let node: SKShapeNode = exampleForce.shapeNode(0, y: 0)
            node.name = "Force"
            object.addChild(node)
            println(self.forces.data)
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let childOfSceneNodeTouched = nodeAtPoint(touch.locationInNode(self))

        if (childOfSceneNodeTouched.parent?.parent is FBButtonNode) {
            (childOfSceneNodeTouched.parent!.parent as FBButtonNode).setTouched(true)
        }

        let mainNode = self.childNodeWithName("Node")
        let childOfMainNodeTouched = mainNode?.nodeAtPoint(touch.locationInNode(mainNode))
        if (childOfMainNodeTouched?.name? == "Force") {
            (childOfMainNodeTouched as SKShapeNode).strokeColor = FBColors.Green
            (childOfMainNodeTouched as SKShapeNode).fillColor = FBColors.Green
        }

    }

    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch

        let childOfMainSceneTouched = nodeAtPoint(touch.previousLocationInNode(self))

        if (childOfMainSceneTouched !== nodeAtPoint(touch.locationInNode(self))) {
            if (childOfMainSceneTouched.parent?.parent is FBButtonNode) {
                (childOfMainSceneTouched.parent!.parent as FBButtonNode).setTouched(false)
            }
        }

        let mainNode = self.childNodeWithName("Node")
        let childOfMainNodeTouched = mainNode?.nodeAtPoint(touch.locationInNode(mainNode))
        if (childOfMainNodeTouched?.name? == "Force") {
            childOfMainNodeTouched as 
        }

    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let childOfSceneNodeTouched = nodeAtPoint(touch.locationInNode(self))

        if (childOfSceneNodeTouched.parent?.parent is FBButtonNode) {
            (childOfSceneNodeTouched.parent!.parent as FBButtonNode).setTouched(false)
        }

        if (childOfSceneNodeTouched.name? != nil) {
            switch childOfSceneNodeTouched.name! {

            case "Node":
                showOptionPane()

            case "Background":
                hideOptionPane()

            case "Play":
                switchPlayButton()

            case "Pause":
                switchPlayButton()

            case "Back":
                self.view!.presentScene(MainMenuScene(size: self.size), transition: .doorsCloseHorizontalWithDuration(0.5))

            case "AddForce":
                addForce()

            default:
                println("Nothing Touched")
            }
        }

        let mainNode = self.childNodeWithName("Node")
        let childOfMainNodeTouched = mainNode?.nodeAtPoint(touch.locationInNode(mainNode))
        if (childOfMainNodeTouched?.name? == "Force") {
            (childOfMainNodeTouched as SKShapeNode).strokeColor = FBColors.Red
            (childOfMainNodeTouched as SKShapeNode).fillColor = FBColors.Red
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
