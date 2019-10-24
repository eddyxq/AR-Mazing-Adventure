import UIKit
import RealityKit
import ARKit
import SceneKit

class ViewController: UIViewController
{
    //size of each box
    struct Size
    {
        var width = 0.0
        var height = 0.0
        var length = 0.0
    }
    
    //position of each box
    struct Position
    {
        var xCoord = 0.0
        var yCoord = 0.0
        var zCoord = 0.0
        var cRad = 0.0
    }
    
    @IBOutlet var arView: ARView!
    @IBOutlet var ARCanvas: ARSCNView!
    
    var animations = [String: CAAnimation]()
    var idle: Bool = true
    let charNode = SCNNode()
    //true when user has placed the maze on surface
    var mazePlaced = false
    
    // Player directions
    enum playerDirection: String{
        case up
        case down
        case left
        case right
        
        func direction() -> String{
            return self.rawValue
        }
    }
    // The direction player is current facing.
    // Default: Up
    var currentPlayerDirection = playerDirection.up.direction()
    
    func turnLeft(direction: String){
        switch direction{
            case "up":
                currentPlayerDirection = playerDirection.left.direction()
            case "down":
                currentPlayerDirection = playerDirection.right.direction()
            case "left":
                currentPlayerDirection = playerDirection.down.direction()
            case "right":
                currentPlayerDirection = playerDirection.up.direction()
        default:
            break
        }
    }
    
    func turnRight(direction: String){
        switch direction{
            case "up":
                currentPlayerDirection = playerDirection.right.direction()
            case "down":
                currentPlayerDirection = playerDirection.left.direction()
            case "left":
                currentPlayerDirection = playerDirection.up.direction()
            case "right":
                currentPlayerDirection = playerDirection.down.direction()
        default:
            break
        }
    }
    
    func moveForward(direction: String) -> SCNAction{
        var walkAction = SCNAction()
        switch direction {
        case "up":
            walkAction = SCNAction.moveBy(x: 0, y: 0, z: -0.02, duration: 1.5)
        case "down":
            walkAction = SCNAction.moveBy(x: 0, y: 0, z: 0.02, duration: 1.5)
        case "left":
            walkAction = SCNAction.moveBy(x: -0.02, y: 0, z: 0, duration: 1.5)
        case "right":
            walkAction = SCNAction.moveBy(x: 0.02, y: 0, z: 0, duration: 1.5)
        default:
            break
        }
        return walkAction
    }
    
    func moveBackward(direction: String) -> SCNAction{
        var walkAction = SCNAction()
        switch direction {
        case "up":
            walkAction = SCNAction.moveBy(x: 0, y: 0, z: 0.02, duration: 1.5)
        case "down":
            walkAction = SCNAction.moveBy(x: 0, y: 0, z: -0.02, duration: 1.5)
        case "left":
            walkAction = SCNAction.moveBy(x: 0.02, y: 0, z: 0, duration: 1.5)
        case "right":
            walkAction = SCNAction.moveBy(x: -0.02, y: 0, z: 0, duration: 1.5)
        default:
            break
        }
        return walkAction
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //enables user to tap detected plane for maze placement
        addTapGestureToSceneView()
        
        //adds arrow pad to screen
        createGamepad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //setting scene to AR
        let config = ARWorldTrackingConfiguration()
        
        //search for horizontal planes
        config.planeDetection = .horizontal

        //apply configurations
        ARCanvas.session.run(config)
        
        //display the detected plane
        ARCanvas.delegate = self
        
        //shows the feature points
        ARCanvas.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    @objc func addMazeToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer)
    {
        //adds maze only if it has not been placed
        if mazePlaced == false
        {
            //disable plane detection by resetting configurations
            let configuration = ARWorldTrackingConfiguration()
            ARCanvas.session.run(configuration)
            
            //get coordinates of where user tapped
            let tapLocation = recognizer.location(in: ARCanvas)
            let hitTestResults = ARCanvas.hitTest(tapLocation, types: .existingPlaneUsingExtent)

            //if tapped on plane, translate tapped location to plane coordinates
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let x = Double(translation.x)
            let y = Double(translation.y)
            let z = Double(translation.z)
            
            //spawn maze on location
            let location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: 0.0)
            setUpMaze(position: location)
            
            //flip flag to true so you cannot spawn multiple mazes
            mazePlaced = true
            
            //hide plane and feature points
            self.ARCanvas.debugOptions = []
        }
    }
    
    //accepts tap input for placing maze
    func addTapGestureToSceneView()
    {
         let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addMazeToSceneView(withGestureRecognizer:)))
            ARCanvas.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        ARCanvas.session.pause()
    }
    // MARK: Buttons & Controlls
    //creates 4 buttons
    func createGamepad()
    {
      let buttonX = 150
      let buttonY = 250
      let buttonWidth = 100
      let buttonHeight = 50

      //right arrow
      let rightButton = UIButton(type: .system)
      let rightArrow = UIImage(named: "rightArrow")
      rightButton.setImage(rightArrow, for: .normal)
      rightButton.addTarget(self, action: #selector(rightButtonClicked), for: .touchUpInside)

      rightButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)

      self.view.addSubview(rightButton)

      //left arrow
      let leftButton = UIButton(type: .system)
      let leftArrow = UIImage(named: "leftArrow")
      leftButton.setImage(leftArrow, for: .normal)
      leftButton.addTarget(self, action: #selector(leftButtonClicked), for: .touchUpInside)

      leftButton.frame = CGRect(x: buttonX-100, y: buttonY, width: buttonWidth, height: buttonHeight)

      self.view.addSubview(leftButton)

      //up arrow
      let upButton = UIButton(type: .system)
      let upArrow = UIImage(named: "upArrow")
      upButton.setImage(upArrow, for: .normal)
      upButton.addTarget(self, action: #selector(upButtonClicked), for: .touchUpInside)

      upButton.frame = CGRect(x: buttonX-50, y: buttonY-50, width: buttonWidth, height: buttonHeight)

      self.view.addSubview(upButton)

      //down arrow
      let downButton = UIButton(type: .system)
      let downArrow = UIImage(named: "downArrow")
      downButton.setImage(downArrow, for: .normal)
      downButton.addTarget(self, action: #selector(downButtonClicked), for: .touchUpInside)

      downButton.frame = CGRect(x: buttonX-50, y: buttonY+50, width: buttonWidth, height: buttonHeight)

      self.view.addSubview(downButton)
    }
    // MARK: Arrow Button Logics
    
    //right button logic
    @objc func rightButtonClicked(sender : UIButton)
    {
          turnRight(direction: currentPlayerDirection)
          let turnAction = SCNAction.rotateBy(x: 0, y: .pi/2, z: 0, duration: 0.5)
          charNode.runAction(turnAction)
    }
      //left button logic
      @objc func leftButtonClicked(sender : UIButton){
          turnLeft(direction: currentPlayerDirection)
          let turnAction = SCNAction.rotateBy(x: 0, y: -(.pi/2), z: 0, duration: 0.5)
          charNode.runAction(turnAction)
      }
      //up button logic
      @objc func upButtonClicked(sender : UIButton){
          playAnimation(key: "walking")
          charNode.runAction(moveForward(direction: currentPlayerDirection))
      }
      //down button logic
      @objc func downButtonClicked(sender : UIButton){
          playAnimation(key: "walkBack")
          charNode.runAction(moveBackward(direction: currentPlayerDirection))
      }
    
    // MARK: Animations & Models
    // creates a player character model with its animations
    func loadPlayerAnimations(position: Position)
    {
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/characters/player/IdleFixed.dae")!
        
        // Set up parent node of all animation models
        //let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes
        {
            charNode.addChildNode(child)
        }
        charNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        //size of the player model
        charNode.scale = SCNVector3(0.00018, 0.00018, 0.00018)
        // Rotating the character by 180 degrees
        charNode.rotation = SCNVector4Make(0, 1, 0, .pi)
        ARCanvas.scene.rootNode.addChildNode(charNode)
        //TODO: load more animations if available
        loadAnimation(withKey: "walking", sceneName: "art.scnassets/characters/player/WalkFixed", animationIdentifier: "WalkFixed-1")
        loadAnimation(withKey: "walkBack", sceneName: "art.scnassets/characters/player/WalkBackFixed", animationIdentifier: "WalkBackFixed-1")
    }
    
    func loadAnimation(withKey: String, sceneName: String, animationIdentifier: String){
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self){
            //The animation will only play once
            animationObject.repeatCount = 1
            //To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            //Store the animation for later use
            animations[withKey] = animationObject
        }
    }
    
    func playAnimation(key: String)
    {
        // Add the animation to start playing it right away
        ARCanvas.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String)
    {
        // Stop the animation with a smooth transition
        ARCanvas.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    //MARK: Maze Map Setup
    //creates a box
    func setUpBox(size: Size, position: Position)
    {
        let box = SCNBox(width: CGFloat(size.width), height: CGFloat(size.height), length: CGFloat(size.length), chamferRadius: 0)
        
        //wall textures
        let imageMaterial1 = SCNMaterial()
        let wallImage1 = UIImage(named: "wall")
        imageMaterial1.diffuse.contents = wallImage1
        
//        let imageMaterial2 = SCNMaterial()
//        let wallImage2 = UIImage(named: "darkWall")
//        imageMaterial2.diffuse.contents = wallImage2
        //apply skins
        box.materials = [imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1]
        //add box to scene
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        ARCanvas.scene.rootNode.addChildNode(boxNode)
    }
    
    //create a maze
    func setUpMaze(position: Position)
    {
        //dimensions of a box
        let WIDTH = 0.02
        let HEIGHT = 0.04
        let LENGTH = 0.02
        //init dimensions
        let dimensions = Size(width: WIDTH, height: HEIGHT, length: LENGTH)
            
        //position of first box
        var x = position.xCoord - 0.14
        var y = position.yCoord + 0.06
        var z = position.zCoord - 0.14
        let c = 0.0
        //init position
        var location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
        var playerLocation = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
        //hard coded maze
        let mazeMap = [
                        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]
        
        //maze size 20x20
        let NUMROW = 20
        let NUMCOL = 20
        
        for i in 0...NUMROW-1
        {
            for j in 0...NUMCOL-1
            {
                let row = mazeMap[i]
                let flag = row[j]
                
                //creates maze floor
                y -= 0.04
                location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
                setUpBox(size: dimensions, position: location)
                y += 0.04
                
                //show wall or player depending on flag value
                if flag == 1
                {
                    location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
                    setUpBox(size: dimensions, position: location)
                // player initial position
                }
                else if flag == 2
                {
                    playerLocation = Position(xCoord: x, yCoord: y-0.02, zCoord: z, cRad: c)
                    loadPlayerAnimations(position: playerLocation)
                }
                //increment each block so it lines up horizontally
                x += 0.02
            }
            //line up blocks on a new row
            x -= 0.4
            z += 0.02
        }
    }
}

extension ViewController: ARSCNViewDelegate
{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        //unwrap anchor as ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        //extract surface of SCNPlane
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        //set plane color
        plane.materials.first?.diffuse.contents = UIColor(red: 0/255, green: 204/255, blue: 14/255, alpha: 0.0)
        let planeNode = SCNNode(geometry: plane)
        
        //get anchor coordinates for the plane node position
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
    {
        //render plane
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
        let planeNode = node.childNodes.first,
        let plane = planeNode.geometry as? SCNPlane
        else { return }
        
        //update plane dimensions
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        //update position of plane
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}

//converts worldTransform value to simd_float3 for access to position
extension float4x4
{
    var translation: simd_float3
    {
        let translation = self.columns.3
        return simd_float3(translation.x, translation.y, translation.z)
    }
}
