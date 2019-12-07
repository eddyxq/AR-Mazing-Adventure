import Foundation
import SceneKit
import ARKit

class Minion: Enemy
{
    // Player directions
    enum minionDirection: String
    {
        case up
        case down
        case left
        case right
        
        func direction() -> String
        {
            return self.rawValue
        }
    }
    
    //location of the minion on the maze array
    var arrayLocation = (0, 0)
    
    var animations = [String: CAAnimation]()
    let enemyType = Enemy.EnemyTypes.minion.type()

    //constructor for initializing an minion
    init()
    {
        super.init(name: "Zombie", maxHP: 10, health: 10, minAtkVal: 1, maxAtkVal: 1, level: 1, node: SCNNode(), nodeID: "0")
    }
    
    // MARK: Animations & Models
    // creates a player character model with its animations
    func loadMinionAnimations(_ sceneView: ARSCNView, _ position: ViewController.Position)
    {
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/characters/enemy/minion/MinionIdleFixed.dae")!
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes
        {
            enemyNode.addChildNode(child)
        }
        //set enemy location
        enemyNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        //size of the enemy model
        let enemyModelSize = 0.0014
        enemyNode.scale = SCNVector3(enemyModelSize, enemyModelSize, enemyModelSize)
        // Rotating the character by 180 degrees

        enemyNode.rotation = SCNVector4Make(0, 1, 0, .pi)
        enemyNode.castsShadow = true
        enemyNode.name = nodeID
        //TODO: load more animations if available
        loadAnimation(withKey: "impact", sceneName: "art.scnassets/characters/enemy/minion/MinionImpactFixed", animationIdentifier: "MinionImpactFixed-1")
        loadAnimation(withKey: "attack", sceneName: "art.scnassets/characters/enemy/minion/MinionAttackFixed", animationIdentifier: "MinionAttackFixed-1")
        loadAnimation(withKey: "turnRight", sceneName: "art.scnassets/characters/enemy/minion/MinionRightTurnFixed", animationIdentifier: "MinionRightTurnFixed-1")
        loadAnimation(withKey: "turnLeft", sceneName: "art.scnassets/characters/enemy/minion/MinionLeftTurnFixed", animationIdentifier: "MinionLeftTurnFixed-1")
        loadAnimation(withKey: "death", sceneName: "art.scnassets/characters/enemy/minion/MinionDeathFixed", animationIdentifier: "MinionDeathFixed-1")
        loadAnimation(withKey: "walking", sceneName: "art.scnassets/characters/enemy/minion/MinionWalkingFixed", animationIdentifier: "MinionWalkingFixed-1")
        sceneView.scene.rootNode.addChildNode(enemyNode)
    }
    
    //load animations
    func loadAnimation(withKey: String, sceneName: String, animationIdentifier: String)
    {
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self)
        {
            //The animation will only play once
            animationObject.repeatCount = 1
            //To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(0.5)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            //Store the animation for later use
            animations[withKey] = animationObject
        }
    }
    //play animation
    func playAnimation(_ sceneView: ARSCNView, key: String)
    {
        // Add the animation to start playing it right away
        sceneView.scene.rootNode.childNode(withName: nodeID, recursively: true)?.addAnimation(animations[key]!, forKey: key)
    }
    //stop animation
    func stopAnimation(_ sceneView: ARSCNView, key: String)
    {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.childNode(withName: nodeID, recursively: true)?.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    // MARK: Minion Movement Logics
    // The direction minion is current facing.
    // Default: Up
    var currentMinionDirection = minionDirection.up.direction()
    //turns the minion 90 degrees counter clockwise
    func turnLeft(direction: String)
    {
        switch direction
        {
            case "up":
                currentMinionDirection = minionDirection.left.direction()
            case "down":
                currentMinionDirection = minionDirection.right.direction()
            case "left":
                currentMinionDirection = minionDirection.down.direction()
            case "right":
                currentMinionDirection = minionDirection.up.direction()
            default:
                break
        }
        let turnAction = SCNAction.rotateBy(x: 0, y: -(.pi/2), z: 0, duration: 0.5)
        enemyNode.runAction(turnAction)
    }
    //turns the minion 90 degrees clockwise
    func turnRight(direction: String)
    {
        switch direction{
            case "up":
                currentMinionDirection = minionDirection.right.direction()
            case "down":
                currentMinionDirection = minionDirection.left.direction()
            case "left":
                currentMinionDirection = minionDirection.up.direction()
            case "right":
                currentMinionDirection = minionDirection.down.direction()
            default:
                break
        }
        let turnAction = SCNAction.rotateBy(x: 0, y: .pi/2, z: 0, duration: 0.5)
        enemyNode.runAction(turnAction)
    }

    func turn180(direction: String){
        switch direction{
            case "up":
                currentMinionDirection = minionDirection.down.direction()
            case "down":
                currentMinionDirection = minionDirection.up.direction()
            case "left":
                currentMinionDirection = minionDirection.right.direction()
            case "right":
                currentMinionDirection = minionDirection.left.direction()
            default:
                break
        }
        let turnAction = SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 0.5)
        enemyNode.runAction(turnAction)
    }
    
    //translates minion
    func newMove(direction: String) -> SCNAction
    {
        let tileSize = CGFloat(0.04)
        var walkAction = SCNAction()
        switch direction
        {
            case "up":
                walkAction = SCNAction.moveBy(x: 0, y: 0, z: -tileSize, duration: 1.5)
            case "down":
                walkAction = SCNAction.moveBy(x: 0, y: 0, z: tileSize, duration: 1.5)
            case "left":
                walkAction = SCNAction.moveBy(x: -tileSize, y: 0, z: 0, duration: 1.5)
            case "right":
                walkAction = SCNAction.moveBy(x: tileSize, y: 0, z: 0, duration: 1.5)
            default:
                break
        }
        return walkAction
    }
    
    // MARK: Getters & Setters
    func getMinionNode() -> SCNNode
    {
        return enemyNode
    }
    
    func setLocation(location: (row: Int, col: Int))
    {
        arrayLocation = location
    }
    
    //Spawns the minion model at the given sceneview
    func spawnMinion(_ sceneView: ARSCNView, _ position: ViewController.Position, _ minionnum: Int) -> Minion
    {
        nodeID = "\(minionnum)"
        loadMinionAnimations(sceneView, position)
        return self
    }
}
