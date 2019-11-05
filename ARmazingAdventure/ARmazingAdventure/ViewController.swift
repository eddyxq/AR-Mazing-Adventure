import UIKit
import RealityKit
import ARKit
import SceneKit

class ViewController: UIViewController
{
    
    //setting scene to AR
    var config = ARWorldTrackingConfiguration()
    
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
    var mazeWallNode = SCNNode()
    var mazeFloorNode = SCNNode()
    let enemyNode = SCNNode()
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
    // MARK: Player Movement Logics
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
    
    func attackMove(direction: String) -> SCNAction{
        var attackMoveAction = SCNAction()
        switch direction{
        case "up":
            attackMoveAction = SCNAction.move(to: SCNVector3(x: charNode.position.x, y: charNode.position.y, z: charNode.position.z-0.02), duration: 0)
        case "down":
            attackMoveAction = SCNAction.move(to: SCNVector3(x: charNode.position.x, y: charNode.position.y, z: charNode.position.z+0.02), duration: 0)
        case "left":
            attackMoveAction = SCNAction.move(to: SCNVector3(x: charNode.position.x-0.02, y: charNode.position.y, z: charNode.position.z), duration: 0)
        case "right":
            attackMoveAction = SCNAction.move(to: SCNVector3(x: charNode.position.x+0.02, y: charNode.position.y, z: charNode.position.z), duration: 0)
        default:
            break
            }
        return attackMoveAction
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

    // MARK: ViewController Functions
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //setting scene to AR
        config = ARWorldTrackingConfiguration()
        
        //search for horizontal planes
        config.planeDetection = .horizontal

        //apply configurations
        ARCanvas.session.run(config)
        
        //display the detected plane
        ARCanvas.delegate = self
        
        //shows the feature points
        ARCanvas.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        //enables user to tap detected plane for maze placement
        addTapGestureToSceneView()
        
        //adds arrow pad to screen
        createGamepad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    
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
            
            //disable plane detection by resetting configurations
            config.planeDetection = []
            self.ARCanvas.session.run(config)
            
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
        let attackButtonRadius = 75

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
        
        //light attack
        let lightAttackButton = UIButton(type: .system)
        let attack1 = UIImage(named: "attackButton")
        lightAttackButton.setImage(attack1, for: .normal)
        lightAttackButton.addTarget(self, action: #selector(lightAttackButtonClicked), for: .touchUpInside)
        lightAttackButton.frame = CGRect(x: buttonX+100, y: buttonY-12, width: attackButtonRadius, height: attackButtonRadius)
        self.view.addSubview(lightAttackButton)
        
        //heavy attack
        let heavyAttackButton = UIButton(type: .system)
        let attack2 = UIImage(named: "attackButton")
        heavyAttackButton.setImage(attack2, for: .normal)
        heavyAttackButton.addTarget(self, action: #selector(heavyAttackButtonClicked), for: .touchUpInside)
        heavyAttackButton.frame = CGRect(x: buttonX+200, y: buttonY-12, width: attackButtonRadius, height: attackButtonRadius)
        self.view.addSubview(heavyAttackButton)
    }
    // MARK: Arrow Button Logics
    
    //right button logic
    @objc func rightButtonClicked(sender : UIButton)
    {
        if mazePlaced == true
        {
            sender.preventRepeatedPresses()
            turnRight(direction: currentPlayerDirection)
            let turnAction = SCNAction.rotateBy(x: 0, y: .pi/2, z: 0, duration: 0.5)
            playAnimation(key: "turnRight")
            charNode.runAction(turnAction)
            maze = rotateArrayCCW(orig: maze)
        }
    }
    //left button logic
    @objc func leftButtonClicked(sender : UIButton)
    {
        if mazePlaced == true
        {
            sender.preventRepeatedPresses()
            turnLeft(direction: currentPlayerDirection)
            let turnAction = SCNAction.rotateBy(x: 0, y: -(.pi/2), z: 0, duration: 0.5)
            playAnimation(key: "turnLeft")
            charNode.runAction(turnAction)
            maze = rotateArrayCW(orig: maze)
        }
    }
    //up button logic
    @objc func upButtonClicked(sender : UIButton)
    {
        if mazePlaced && move(direction: "forward")
        {
            sender.preventRepeatedPresses()
            playAnimation(key: "walk")
            charNode.runAction(moveForward(direction: currentPlayerDirection))
        }
    }
    //down button logic
    @objc func downButtonClicked(sender : UIButton)
    {
        if mazePlaced && move(direction: "backward")
        {
            sender.preventRepeatedPresses()
            playAnimation(key: "walkBack")
            charNode.runAction(moveBackward(direction: currentPlayerDirection))
        }
    }
    // MARK: Attack Buttons
    //light attack button logic
    @objc func lightAttackButtonClicked(sender : UIButton)
    {
        sender.preventRepeatedPresses()
        //play animation
        playAnimation(key: "lightAttack")
        let audio = SCNAudioSource(named: "art.scnassets/audios/lightAttack.wav")
        let audioAction = SCNAction.playAudio(audio!, waitForCompletion: true)
        charNode.runAction(audioAction)
    }
    //heavy attack button logic
    @objc func heavyAttackButtonClicked(sender : UIButton)
    {
        sender.preventRepeatedPresses()
        //play animation
        playAnimation(key: "heavyAttack")
        let audio = SCNAudioSource(named: "art.scnassets/audios/heavyAttack.wav")
        let audioAction = SCNAction.playAudio(audio!, waitForCompletion: true)
        charNode.runAction(audioAction)
    }
    

    
    // MARK: Player Restriction
    //var currentPlayerLocation
    
    var maze = [
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
    [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,2,0,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]
    
    let NUMROW = 20
    let NUMCOL = 20
    //MARK MOVE
    
	//rotates a array clockwise
    func rotateArrayCW(orig: [[Int]]) -> [[Int]]
    {
        let rows = 20
        let cols = 20
   
        var arr = [[Int]](repeating: [Int](repeating: 0, count: 20), count: 20)
        
        for r in 0...19
        {
            for c in 0...19
            {
                arr[c][rows-1-r] = orig[r][c]
            }
        }
        return arr;
    }
	
	//rotates a array counter clockwise
    func rotateArrayCCW(orig: [[Int]]) -> [[Int]]
    {
        return rotateArrayCW(orig: rotateArrayCW(orig: rotateArrayCW(orig: orig)))
    }
    
    //moves and updates player location
    func move(direction: String) -> Bool
    {
        var canMove = false
        
        var playerRow = getRow();
        var playerCol = getCol();
        // remove player from current position
        maze[playerRow][playerCol] = 0;
        switch (direction)
        {
        case "backward":
            playerRow += 1;
        case "forward":
            playerRow -= 1;
        default:
            print("error")
        }
        
        if maze[playerRow][playerCol] != 1
        {
            maze[playerRow][playerCol] = 2
            canMove = true
        }
            
        else // player does not move, returns to origin
        {
            switch (direction)
            {
            case "backward":
                playerRow -= 1;
            case "forward":
                playerRow += 1;
            default:
                print("error")
            }
            maze[playerRow][playerCol] = 2;
        }
        
        return canMove
    }
    
    //get player row index
    func getRow() -> Int
    {
        var playerRow = 0;
        for row in 0...NUMROW-1
        {
             for col in 0...NUMCOL-1
             {
                 if (maze[row][col] == 2)
                 {
                     playerRow = row;
                 }
             }
        }
        return playerRow;
    }
    
	//get player column index
    func getCol() -> Int
    {
        var playerCol = 0;
        for row in 0...NUMROW-1
        {
             for col in 0...NUMCOL-1
             {
                 if (maze[row][col] == 2)
                 {
                     playerCol = col;
                 }
             }
        }
        return playerCol;
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
        
        let charLight = SCNLight()
        
        charLight.type = .spot
        charLight.spotOuterAngle = CGFloat(10)
        charLight.zNear = CGFloat(0.04)
        charLight.intensity = CGFloat(1000)
        ARCanvas.pointOfView?.light = charLight
        
        charNode.name = "player"
        ARCanvas.scene.rootNode.addChildNode(charNode)
        //TODO: load more animations if available
        loadAnimation(withKey: "walk", sceneName: "art.scnassets/characters/player/WalkFixed", animationIdentifier: "WalkFixed-1")
        loadAnimation(withKey: "walkBack", sceneName: "art.scnassets/characters/player/WalkBackFixed", animationIdentifier: "WalkBackFixed-1")
        loadAnimation(withKey: "turnLeft", sceneName: "art.scnassets/characters/player/TurnLeftFixed", animationIdentifier: "TurnLeftFixed-1")
        loadAnimation(withKey: "turnRight", sceneName: "art.scnassets/characters/player/TurnRightFixed", animationIdentifier: "TurnRightFixed-1")
        loadAnimation(withKey: "lightAttack", sceneName: "art.scnassets/characters/player/LightAttackFixed", animationIdentifier: "LightAttackFixed-1")
        loadAnimation(withKey: "heavyAttack", sceneName: "art.scnassets/characters/player/HeavyAttackFixed", animationIdentifier: "HeavyAttackFixed-1")
    }
    // MARK: Enemy Model
    // creates a player character model with its animations
    func loadEnemyAnimations(position: Position)
    {
        // Load the character in the idle animation
        let idleScene = SCNScene(named: "art.scnassets/characters/enemy/IdleEnemyFixed.dae")!
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes
        {
            enemyNode.addChildNode(child)
        }
        
        
        enemyNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        //size of the player model
        enemyNode.scale = SCNVector3(0.00018, 0.00018, 0.00018)
        // Rotating the character by 180 degrees
        enemyNode.rotation = SCNVector4Make(0, 1, 0, 0)
        enemyNode.name = "enemy"
        //TODO: load more animations if available
        
        ARCanvas.scene.rootNode.addChildNode(enemyNode)
    }
    
    
    func loadAnimation(withKey: String, sceneName: String, animationIdentifier: String){
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self){
            //The animation will only play once
            animationObject.repeatCount = 1
            //To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(0.5)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            //Store the animation for later use
            animations[withKey] = animationObject
        }
    }
    
    func playAnimation(key: String)
    {
        // Add the animation to start playing it right away
        ARCanvas.scene.rootNode.childNode(withName: "player", recursively: true)?.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String)
    {
        // Stop the animation with a smooth transition
        ARCanvas.scene.rootNode.childNode(withName: "player", recursively: true)?.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    //MARK: Maze Map Setup
    //creates a box
    // MARK: Maze Nodes Setup
        //creates a box for maze wall
        func setupWall(size: Size, position: Position)
        {
            let wall = SCNBox(width: CGFloat(size.width), height: CGFloat(size.height), length: CGFloat(size.length), chamferRadius: 0)
            
            //wall textures
            let imageMaterial1 = SCNMaterial()
            let wallImage1 = UIImage(named: "wall")
            imageMaterial1.diffuse.contents = wallImage1
            
    //        let imageMaterial2 = SCNMaterial()
    //        let wallImage2 = UIImage(named: "darkWall")
    //        imageMaterial2.diffuse.contents = wallImage2
            //apply skins
            wall.materials = [imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1]
            //add box to scene
           let wallNode = SCNNode(geometry: wall)
            wallNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
            mazeWallNode.addChildNode(wallNode)
            
            ARCanvas.scene.rootNode.addChildNode(mazeWallNode)
        }
    
    // creates a box for maze floor
    func setupFloor(size: Size, position: Position)
        {
            let floor = SCNBox(width: CGFloat(size.width), height: CGFloat(size.height), length: CGFloat(size.length), chamferRadius: 0)
            
            //wall textures
            let imageMaterial1 = SCNMaterial()
            let imageMaterial2 = SCNMaterial()
            
            let floorImage1 = UIImage(named: "floor")
            let floorSideImage1 = UIImage(named: "wall")
            
            imageMaterial1.diffuse.contents = floorImage1
            imageMaterial2.diffuse.contents = floorSideImage1
            
    //        let imageMaterial2 = SCNMaterial()
    //        let wallImage2 = UIImage(named: "darkWall")
    //        imageMaterial2.diffuse.contents = wallImage2
            //apply skins
            floor.materials = [imageMaterial2, imageMaterial2, imageMaterial2, imageMaterial2, imageMaterial1, imageMaterial2]
            //add box to scene
            let floorNode = SCNNode(geometry: floor)
            floorNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
            mazeFloorNode.addChildNode(floorNode)
            ARCanvas.scene.rootNode.addChildNode(mazeFloorNode)
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
        var enemyLocation = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
        //hard coded maze
        let mazeMap = [
                        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
                        [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,2,0,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
                        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]
        
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
                setupFloor(size: dimensions, position: location)
                y += 0.04
                
                //show wall or player depending on flag value
                if flag == 1
                {
                    location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
                    setupWall(size: dimensions, position: location)
                // player initial position
                }
                else if flag == 2
                {
                    playerLocation = Position(xCoord: x, yCoord: y-0.02, zCoord: z, cRad: c)
                    loadPlayerAnimations(position: playerLocation)
                }
                else if flag == 3
                {
                    enemyLocation = Position(xCoord: x, yCoord: y-0.02, zCoord: z, cRad: c)
                    loadEnemyAnimations(position: enemyLocation)
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
// MARK: Class Extension
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

extension UIButton {
    func preventRepeatedPresses(inNext seconds: Double = 2) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.isUserInteractionEnabled = true
        }
    }
}
