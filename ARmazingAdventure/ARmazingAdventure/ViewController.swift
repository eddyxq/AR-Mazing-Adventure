import UIKit
import RealityKit
import ARKit
import SceneKit
import SpriteKit

class ViewController: UIViewController
{
    //set up game states
    enum GameState: String
    {
        case playerTurn
        case enemyTurn
        
        func state() -> String
        {
            return self.rawValue
        }
    }
    
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
    var location = Position(xCoord: 0.0, yCoord: 0.0, zCoord: 0.0, cRad: 0.0)
    
    var currentGameState = GameState.playerTurn.state()
    
    let player = Player(name: "noobMaster69", health: 10, minAtkVal: 1, maxAtkVal: 3, level: 1)
    var minionPool = [Minion]()
    var targetMinion = Minion()
    var bossPool = [Boss]()
    
    var enemyHPBorder = SKSpriteNode()
    var enemyHPBar = SKSpriteNode(color: .red, size: CGSize(width: 200, height: 20))
    
    @IBOutlet weak var APLabel: UILabel!

    @IBOutlet weak var APTitleLabel: UILabel!
    
    @IBOutlet weak var turnIndicator: UILabel!
    
    @IBOutlet weak var enemyHPBarLabel: UILabel!
    
    //count of number of maze stages completed
    var stageLevel = 1
    
    //true when user has placed the maze on surface
    var mazePlaced = false
    var planeFound = false
    
    //tracks the player direction states
    enum playerDirection: String
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
    
    //creates a new random maze stage that is tracked in a 2d array
    var maze = Maze().newStage()
    //the dimensions of the maze
    let NUMROW = Maze().getHeight()
    let NUMCOL = Maze().getWidth()
    
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
        ARCanvas.autoenablesDefaultLighting = false
        //shows the feature points
        ARCanvas.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        ARCanvas.scene.rootNode.castsShadow = true
        
        turnIndicator.isHidden = true
        APTitleLabel.isHidden = true
        
        setupOverlay()
        setupDungeonMusic()
//        setupARLight()
//        setupFog()
        //enables user to tap detected plane for maze placement
        addTapGestureToSceneView()
        //adds arrow pad to screen
        createGamepad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    func setupOverlay()
    {
        let hud = SKScene()
        hud.scaleMode = .resizeFill
        
        enemyHPBorder = SKSpriteNode()
        let hpBorderImage = UIImage(named: "minionHPBorder")
        let hpBorderTexture = SKTexture(image: hpBorderImage!)
        enemyHPBorder = SKSpriteNode(texture: hpBorderTexture)
        enemyHPBorder.position = CGPoint(x: 680, y: 200)
        
        enemyHPBar = SKSpriteNode(color: .red, size: CGSize(width: 200, height: 20))
        enemyHPBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        enemyHPBar.position = CGPoint(x: 580, y: 200)
        
        hud.addChild(enemyHPBar)
        hud.addChild(enemyHPBorder)
        ARCanvas.overlaySKScene = hud
        
        enemyHPBarLabel.isHidden = true
        enemyHPBar.isHidden = true
        enemyHPBorder.isHidden = true
    }
    
    func updateEnemyHPBarLabel()
    {
        enemyHPBarLabel.textColor = UIColor.white
        enemyHPBarLabel.shadowColor = UIColor.black
        enemyHPBarLabel.text = "\(targetMinion.getName()) HP: \(targetMinion.getHP()) \\ \(targetMinion.getMaxHP())"
        enemyHPBarLabel.isHidden = false
    }
    
    
    // MARK: Action Points & Game State Change
    func updateAP()
    {
        APTitleLabel.isHidden = false
        APTitleLabel.textColor = UIColor.white
        APTitleLabel.shadowColor = UIColor.black
        APLabel.text = player.getAPCount()
        
        if player.apCount == 0
        {
            stateChange()
        }
    }
    
    // updates the turn indicator
    func updateIndicator()
    {
        if currentGameState == "playerTurn"
        {
            turnIndicator.text = "Your Turn"
            turnIndicator.textColor = UIColor.green
        }
        else if currentGameState == "enemyTurn"
        {
            turnIndicator.text = "Enemy Turn"
            turnIndicator.textColor = UIColor.red
        }
        turnIndicator.isHidden = false
        turnIndicator.shadowColor = UIColor.black
    }
    
    // changes the game state
    func stateChange()
    {
        
        if currentGameState == "playerTurn"
        {
            currentGameState = GameState.enemyTurn.state()
            APTitleLabel.isHidden = true
            APLabel.isHidden = true
            updateIndicator()
        }
        else if currentGameState == "enemyTurn"
        {
            currentGameState = GameState.playerTurn.state()
            player.apCount = 3
            APTitleLabel.isHidden = false
            APLabel.isHidden = false
            updateIndicator()
            updateAP()
        }
    }
    // MARK: Add maze on tap
    @objc func addMazeToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer)
    {
        //adds maze only if it has not been placed and a plane is found
        if mazePlaced == false && planeFound == true
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
            location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: 0.0)
            setUpMaze(position: location)
            
            //flip flag to true so you cannot spawn multiple mazes
            mazePlaced = true
            updateIndicator()
            updateAP()
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
        
        //end turn
        let endTurnButton = UIButton(type: .system)
        let endButton = UIImage(named: "attackButton")
        endTurnButton.setImage(endButton, for: .normal)
        endTurnButton.addTarget(self, action: #selector(endTurnButtonClicked), for: .touchUpInside)
        endTurnButton.frame = CGRect(x: 50, y: 50, width: attackButtonRadius, height: attackButtonRadius)
        self.view.addSubview(endTurnButton)
        
        //constraints
               
        for button in [rightButton, upButton, downButton, leftButton, rightButton, heavyAttackButton, lightAttackButton]
        {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1).isActive = true
        }

        rightButton.bottomAnchor.constraint(equalTo: downButton.topAnchor).isActive = true
        rightButton.leftAnchor.constraint(equalTo: downButton.rightAnchor).isActive = true
        
        leftButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 24).isActive = true
        leftButton.bottomAnchor.constraint(equalTo: downButton.topAnchor).isActive = true

        upButton.bottomAnchor.constraint(equalTo: leftButton.topAnchor).isActive = true
        upButton.leftAnchor.constraint(equalTo: leftButton.rightAnchor).isActive = true

        downButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24).isActive = true
        downButton.leftAnchor.constraint(equalTo: leftButton.rightAnchor).isActive = true

        lightAttackButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        lightAttackButton.rightAnchor.constraint(equalTo: heavyAttackButton.leftAnchor, constant: -24).isActive = true
        lightAttackButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64).isActive = true

        heavyAttackButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        heavyAttackButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -24).isActive = true
        heavyAttackButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64).isActive = true

        endTurnButton.widthAnchor.constraint(equalToConstant: 75).isActive = true
        endTurnButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: -24).isActive = true
        endTurnButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -64).isActive = true

        
    }
    // MARK: Arrow Button Logics
    func canMove(direction: String) -> Bool
    {
        return
            //ensures game is setup in AR
            (mazePlaced
            //allows movement only when player has available action points
            && player.apCount > 0
            //ensures movement only happens during player phase
            && currentGameState == "playerTurn"
            //checks for obstacles and collisions
            && move(direction: direction) ? true : false)
            
    }
    
    //right button logic
    @objc func rightButtonClicked(sender : UIButton)
    {
        if mazePlaced == true && currentGameState != "enemyTurn"
        {
            sender.preventRepeatedPresses()
            player.turnRight(direction: player.currentPlayerDirection)
            let turnAction = SCNAction.rotateBy(x: 0, y: .pi/2, z: 0, duration: 0.5)
            player.playAnimation(ARCanvas, key: "turnRight")
            player.getPlayerNode().runAction(turnAction)
            maze = Maze().rotateArrayCCW(orig: maze)
        }
    }
    //left button logic
    @objc func leftButtonClicked(sender : UIButton)
    {
        if mazePlaced == true && currentGameState != "enemyTurn"
        {
            sender.preventRepeatedPresses()
            player.turnLeft(direction: player.currentPlayerDirection)
            let turnAction = SCNAction.rotateBy(x: 0, y: -(.pi/2), z: 0, duration: 0.5)
            player.playAnimation(ARCanvas, key: "turnLeft")
            player.getPlayerNode().runAction(turnAction)
            maze = Maze().rotateArrayCW(orig: maze)
        }
    }
    //up button logic
    @objc func upButtonClicked(sender : UIButton)
    {
        if canMove(direction: "forward")
        {
            sender.preventRepeatedPresses()
            player.playAnimation(ARCanvas, key: "walk")
            player.getPlayerNode().runAction(player.moveForward(direction: player.currentPlayerDirection))
            player.apCount -= 1
            updateAP()
        }
    }
    //down button logic
    @objc func downButtonClicked(sender : UIButton)
    {
        if canMove(direction: "backward")
        {
            sender.preventRepeatedPresses()
            player.playAnimation(ARCanvas, key: "walkBack")
            player.getPlayerNode().runAction(player.moveBackward(direction: player.currentPlayerDirection))
            player.apCount -= 1
            updateAP()
        }
    }
    // MARK: Attack Buttons
    //light attack button logic
    @objc func lightAttackButtonClicked(sender : UIButton)
    {
        if mazePlaced == true && currentGameState == "playerTurn"
        {
            sender.preventRepeatedPresses()
            //play animation
            player.playAnimation(ARCanvas, key: "lightAttack")
            let audio = SCNAudioSource(named: "art.scnassets/audios/lightAttack.wav")
            let audioAction = SCNAction.playAudio(audio!, waitForCompletion: true)
            player.getPlayerNode().runAction(audioAction)
            //logic for when player swings at a enemy
            if  player.apCount > 0
            {
                targetMinion.playAnimation(ARCanvas, key: "impact")
                //consumes ap per attack
                player.apCount -= 1
                updateAP()
                var action = SKAction()
                let newBarWidth = enemyHPBar.size.width - player.attackEnemy(target: targetMinion)
                //if enemy is dead
                if newBarWidth <= 0.0
                {
                    action = SKAction.resize(toWidth: 0.0, duration: 0.25)
                    //remove enemy model from scene
                    targetMinion.getMinionNode().removeFromParentNode()
                    //remove enemy data from maze
                    maze[adjacentEnemyLocation.0][adjacentEnemyLocation.1] = 0
                }
                else
                {
                    action = SKAction.resize(toWidth: CGFloat(newBarWidth), duration: 0.25)
                }
                updateEnemyHPBarLabel()
                enemyHPBar.run(action)
                    
                }
            }
    }
    
    //heavy attack button logic
    @objc func heavyAttackButtonClicked(sender : UIButton)
    {
        if mazePlaced == true && currentGameState == "playerTurn"
        {
            sender.preventRepeatedPresses()
            //play animation
            player.playAnimation(ARCanvas, key: "heavyAttack")
            let audio = SCNAudioSource(named: "art.scnassets/audios/heavyAttack.wav")
            let audioAction = SCNAction.playAudio(audio!, waitForCompletion: true)
            player.getPlayerNode().runAction(audioAction)
        }
    }
    //end turn button logic
    @objc func endTurnButtonClicked(sender : UIButton)
    {
        if (mazePlaced)
        {
           stateChange()
        }
    }
    // MARK: Player Movement
        
    //moves and updates player location
    func move(direction: String) -> Bool
    {
        var canMove = false
        var playerRow = Maze().getRow(maze: maze)
        let playerCol = Maze().getCol(maze: maze)
        currentPlayerLocation = (playerRow, playerCol)
        // remove player from current position
        maze[playerRow][playerCol] = 0
        switch (direction)
        {
            case "backward":
                playerRow += 1
            case "forward":
                playerRow -= 1
            default:
                break
        }
        if maze[playerRow][playerCol] == 9
        {
            ARCanvas.scene.rootNode.enumerateChildNodes
            { (node, stop) in
                node.removeFromParentNode()
            }
            
            if stageLevel % 2 != 0
            {
                //load a new stage and rotate maze 180 degrees so player
                //starts new stage where he finished previous stage
                maze = Maze().rotateArrayCW(orig: Maze().rotateArrayCW(orig: Maze().newStage()))
                setUpMaze(position: location)
                //rotate player 180 degress
                player.turnRight(direction: player.currentPlayerDirection)
                player.turnRight(direction: player.currentPlayerDirection)
            }
            else
            {
                maze = Maze().newStage()
                setUpMaze(position: location)
            }
            //count number of stages cleared
            stageLevel += 1
            //reload music and settings
            setupDungeonMusic()
            //setupARLight()
            //setupFog()
        }
        else if maze[playerRow][playerCol] != 1 && maze[playerRow][playerCol] != 4
        {
            maze[playerRow][playerCol] = 2
            canMove = true
        }
        else // player does not move, returns to origin
        {
            switch (direction)
            {
                case "backward":
                    playerRow -= 1
                case "forward":
                    playerRow += 1
                default:
                    break
            }
            maze[playerRow][playerCol] = 2;
        }
        
        //check if minion is nearby
        if enemyInRange(row: playerRow, col: playerCol) == true
        {
            //get the instance of the minion that is near the player
            targetMinion = findMinionByLocation(location: (row: playerRow, col: playerCol))
            //display hit points bar
            enemyHPBorder.isHidden = false
            enemyHPBar.isHidden = false
            updateEnemyHPBarLabel()
        }
        return canMove
    }
    
    var adjacentEnemyLocation = (0,0)
    var currentPlayerLocation = (1,2)
    
    func enemyInRange(row: Int, col: Int) -> Bool
    {
        var minionInRange = false
        //check south of player
        if (row < NUMROW-1)
        {
            if maze[row+1][col] == 4
            {
                adjacentEnemyLocation = (row+1, col)
                minionInRange = true
            }
        }
        //check east of player
        if (col < NUMCOL-1)
        {
            if maze[row][col+1] == 4
            {
                adjacentEnemyLocation = (row, col+1)
                minionInRange = true
            }
        }
        //check west of player
        if (row > 0)
        {
            if maze[row-1][col] == 4
            {
                adjacentEnemyLocation = (row-1, col)
                minionInRange = true
            }
        }
        //check north of player
        if (col > 0)
        {
            if maze[row][col-1] == 4
            {
                adjacentEnemyLocation = (row, col-1)
                minionInRange = true
            }
        }
        return minionInRange
    }
    
    
    // MARK: Combat
    func findMinionByLocation(location: (row: Int, col: Int)) -> Minion
    {
        for minion in minionPool
        {
            if minion.arrayLocation == location
            {
                return minion
            }
        }
        //code shouldn't reach here, all minions should be in list
        return minionPool[0]
    }
    // MARK: Music
    //plays background music
    func setupDungeonMusic()
    {
        let audio = SCNAudioSource(named: "art.scnassets/audios/dungeonMusic.wav")
        audio?.volume = 0.65
        audio?.loops = true
        let audioAction = SCNAction.playAudio(audio!, waitForCompletion: true)
        player.getPlayerNode().runAction(audioAction)
    }
    //MARK: Lighting & Fog
    //creates tunnel vision
    func setupARLight()
    {
        let charLight = SCNLight()
        charLight.type = .spot
        charLight.spotOuterAngle = CGFloat(15)
        charLight.zFar = CGFloat(100)
        charLight.zNear = CGFloat(0.01)
        charLight.castsShadow = true
        charLight.intensity = CGFloat(2000)
        ARCanvas.pointOfView?.light = charLight
    }
    //adds fog to the scene
    func setupFog()
    {
        ARCanvas.scene.fogColor = UIColor.darkGray
        ARCanvas.scene.fogStartDistance = CGFloat(0.0)
        ARCanvas.scene.fogEndDistance = CGFloat(3.0)
    }
    //MARK: Maze Map Setup
    //creates the maze wall
    func setupWall(size: Size, position: Position)
    {
        let wall = SCNBox(width: CGFloat(size.width), height: CGFloat(size.height), length: CGFloat(size.length), chamferRadius: 0)
        
        //wall textures
        let imageMaterial1 = SCNMaterial()
        let wallImage1 = UIImage(named: "wall")
        imageMaterial1.diffuse.contents = wallImage1
        
        //apply skins
        wall.materials = [imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1, imageMaterial1]
        //add box to scene
        let wallNode = SCNNode(geometry: wall)
        wallNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        mazeWallNode.addChildNode(wallNode)
        mazeWallNode.castsShadow = true
        ARCanvas.scene.rootNode.addChildNode(mazeWallNode)
    }
    
    // creates the maze floor
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
        
        //apply skins
        floor.materials = [imageMaterial2, imageMaterial2, imageMaterial2, imageMaterial2, imageMaterial1, imageMaterial2]
        //add box to scene
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        mazeFloorNode.addChildNode(floorNode)
        mazeWallNode.castsShadow = true
        ARCanvas.scene.rootNode.addChildNode(mazeFloorNode)
    }
    
    //create a maze
    func setUpMaze(position: Position)
    {
        //dimensions of a box
        let WIDTH = 0.04
        let HEIGHT = 0.08
        let LENGTH = 0.04
        //init dimensions
        let dimensions = Size(width: WIDTH, height: HEIGHT, length: LENGTH)
        
        let FLOORHEIGHT = 0.01
        let floorDimensions = Size(width: WIDTH, height: FLOORHEIGHT, length: LENGTH)
        //position of first box
        var x = position.xCoord - WIDTH * Double(NUMCOL) / 2.0
        var y = position.yCoord + 0.06
        var z = position.zCoord - LENGTH * Double(NUMROW) / 2.0
        let c = 0.0
        //init position
        var location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
        var playerLocation = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
        var bossLocation = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
        var minionLocation = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
        let NUMROW = Maze().getHeight()
        let NUMCOL = Maze().getWidth()
        
        for i in 0 ..< NUMROW
        {
            for j in 0 ..< NUMCOL
            {
                let row = maze[i]
                let flag = row[j]
                
                //creates maze floor
                //y offset to place floor block flush under the wall
                y -= (HEIGHT + FLOORHEIGHT) / 2
                location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
                setupFloor(size: floorDimensions, position: location)
                y += (HEIGHT + FLOORHEIGHT) / 2
                
                //show wall or player depending on flag value
                if flag == 1
                {
                    location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
                    setupWall(size: dimensions, position: location)
                }
                else if flag == 2
                {
                    //initial player position
                    playerLocation = Position(xCoord: x, yCoord: y-WIDTH, zCoord: z, cRad: c)
                    player.spawnPlayer(ARCanvas, playerLocation)
                }
                else if flag == 3
                {
                    bossLocation = Position(xCoord: x, yCoord: y-WIDTH, zCoord: z, cRad: c)
                    let boss = Boss(position: bossLocation)
                    bossPool.append(boss.spawnBoss(ARCanvas, bossLocation))
                }
				else if flag == 4
                {
                    minionLocation = Position(xCoord: x, yCoord: y-WIDTH, zCoord: z, cRad: c)
                    let minion = Minion()
                    minion.setLocation(location: (row: i, col: j))
                    minionPool.append(minion.spawnMinion(ARCanvas, minionLocation))
                }
                //increment each block so it lines up horizontally
                x += WIDTH
            }
            //line up blocks on a new row
            x -= WIDTH * Double(NUMCOL)
            z += LENGTH
        }
    }
}
