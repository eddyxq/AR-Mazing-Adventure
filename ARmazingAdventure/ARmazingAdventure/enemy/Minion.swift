import Foundation
import SceneKit
import ARKit

class Minion: Enemy
{
    //location of the minion on the maze array
    var arrayLocation = (0, 0)
    
    let minionNode = SCNNode()
    var animations = [String: CAAnimation]()
    let enemyType = Enemy.EnemyTypes.minion.type()
    
    init() {
        super.init(name: "Zombie", maxHP: 5, health: 5, minAtkVal: 1, maxAtkVal: 1, level: 1)
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
            minionNode.addChildNode(child)
        }
        //set enemy location
        minionNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        //size of the enemy model
        let enemyModelSize = 0.0014
        minionNode.scale = SCNVector3(enemyModelSize, enemyModelSize, enemyModelSize)
        // Rotating the character by 180 degrees
        minionNode.rotation = SCNVector4Make(0, 1, 0, 0)
        minionNode.castsShadow = true
        minionNode.name = "minion"
        //TODO: load more animations if available
        loadAnimation(withKey: "impact", sceneName: "art.scnassets/characters/enemy/minion/MinionImpactFixed", animationIdentifier: "MinionImpactFixed-1")
        sceneView.scene.rootNode.addChildNode(minionNode)
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
        sceneView.scene.rootNode.childNode(withName: "minion", recursively: true)?.addAnimation(animations[key]!, forKey: key)
    }
    //stop animation
    func stopAnimation(_ sceneView: ARSCNView, key: String)
    {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.childNode(withName: "minion", recursively: true)?.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    // MARK: Getters & Setters
    //Spawns the minion model at the given sceneview
    func spawnMinion(_ sceneView: ARSCNView, _ position: ViewController.Position) -> Minion
    {
        loadMinionAnimations(sceneView, position)
        return self
        
    }
    
    func getMinionNode() -> SCNNode
    {
        return minionNode
    }
    
    func setLocation(location: (row: Int, col: Int))
    {
        arrayLocation = location
    }
    
}
