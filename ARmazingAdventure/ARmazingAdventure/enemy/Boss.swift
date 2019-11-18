import Foundation
import SceneKit
import ARKit

class Boss: Enemy
{
    let bossNode = SCNNode()
    var animations = [String: CAAnimation]()
    let enemyType = Enemy.EnemyTypes.boss.type()
    
    // MARK: Animations & Models
    // creates a player character model with its animations
    func loadBossAnimations(_ sceneView: ARSCNView, _ position: ViewController.Position)
    {
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/characters/enemy/boss/IdleEnemyFixed.dae")!
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes
        {
            bossNode.addChildNode(child)
        }
        //set enemy location
        bossNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        //size of the enemy model
        let enemyModelSize = 0.00038
        bossNode.scale = SCNVector3(enemyModelSize, enemyModelSize, enemyModelSize)
        // Rotating the character by 180 degrees
        bossNode.rotation = SCNVector4Make(0, 1, 0, 0)
        bossNode.castsShadow = true
        bossNode.name = "enemy"
        //TODO: load more animations if available
        loadAnimation(withKey: "impact", sceneName: "art.scnassets/characters/enemy/boss/ImpactFixed", animationIdentifier: "ImpactFixed-1")
        sceneView.scene.rootNode.addChildNode(bossNode)
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
        sceneView.scene.rootNode.childNode(withName: "enemy", recursively: true)?.addAnimation(animations[key]!, forKey: key)
    }
    //stop animation
    func stopAnimation(_ sceneView: ARSCNView, key: String)
    {
        // Stop the animation with a smooth transition
        sceneView.scene.rootNode.childNode(withName: "enemy", recursively: true)?.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    //Spawns the boss model at the given sceneview
    func spawnBoss(_ sceneView: ARSCNView, _ position: ViewController.Position)
    {
        loadBossAnimations(sceneView, position)
    }
    
    func getBossNode() -> SCNNode
    {
        return bossNode
    }

}
