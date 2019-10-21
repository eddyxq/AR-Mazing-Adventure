//
//  ViewController.swift
//  ARmazingAdventure
//
//  Created by Muhammad Saadan on 2019-10-20.
//  Copyright © 2019 Muhammad Saadan. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    @IBOutlet var ARCanvas: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
        //let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
        //arView.scene.anchors.append(boxAnchor)
        
        setUpMaze()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARWorldTrackingConfiguration()
        ARCanvas.session.run(config)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ARCanvas.session.pause()
    }
    
   
    
    func setUpBox(size: Size, position: Position)
    {
        let box = SCNBox(width: CGFloat(size.width), height: CGFloat(size.height), length: CGFloat(size.length), chamferRadius: 0)
        let colours = [UIColor.black, .black, .black, .black, .gray, .black]
        
        box.materials = colours.map({ (colour) -> SCNMaterial in let material = SCNMaterial()
                    material.diffuse.contents = colour
            return material})
        
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(CGFloat(position.xCoord), CGFloat(position.yCoord), CGFloat(position.zCoord))
        ARCanvas.scene.rootNode.addChildNode(boxNode)
        //-0.1, -0.15, -0.03
    }
    
    func setUpMaze()
    {
        //dimensions of a box
        let WIDTH = 0.01
        let HEIGHT = 0.01
        let LENGTH = 0.01
        //init dimensions
        let dimensions = Size(width: WIDTH, height: HEIGHT, length: LENGTH)
            
        
        //position of first box
        var x = -0.1
        var y = -0.15
        var z = -0.03
        var c = 0.0
        //init position
        var location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
        
        
        let mazeMap = [
                        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1],
                        [1,0,0,0,0,0,1,1,0,0,0,1,0,0,1,3,0,1,0,1],
                        [1,0,1,1,1,0,6,1,0,1,0,0,0,1,1,1,0,1,0,1],
                        [1,0,0,0,1,1,1,1,0,1,1,0,1,1,0,1,0,1,0,1],
                        [1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,1],
                        [1,0,1,1,1,1,0,1,0,1,1,0,1,1,1,1,0,1,0,1],
                        [1,0,0,0,0,1,0,1,0,1,0,0,0,0,0,0,0,1,0,1],
                        [1,0,1,1,0,1,0,1,0,1,1,0,1,1,0,1,1,1,0,1],
                        [1,3,1,0,0,1,0,1,0,0,0,0,0,1,0,0,0,1,0,1],
                        [1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,0,1,0,1],
                        [1,0,1,0,1,0,0,1,0,1,0,0,0,1,0,1,0,1,0,1],
                        [1,0,0,0,0,0,1,1,0,0,0,1,1,1,0,1,0,0,0,1],
                        [1,0,1,1,1,0,1,0,0,1,0,0,0,1,3,1,1,1,0,1],
                        [1,0,0,0,1,1,1,1,0,1,1,1,0,1,1,1,0,0,0,1],
                        [1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,1,0,1,0,1],
                        [1,0,1,1,1,1,0,1,0,1,0,1,1,1,1,1,0,1,1,1],
                        [1,0,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,1,3,1],
                        [1,0,1,1,0,1,0,1,0,0,0,0,0,1,0,1,1,1,0,1],
                        [1,0,1,3,0,1,0,1,0,1,0,1,0,0,0,0,0,0,0,1],
                        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]]
        
        let NUMROW = 20
        let NUMCOL = 20
        
        for i in 0...NUMROW-1
        {
            for j in 0...NUMCOL-1
            {
                let row = mazeMap[i]
                let flag = row[j]
                
                if flag == 1
                {
                    location = Position(xCoord: x, yCoord: y, zCoord: z, cRad: c)
                    setUpBox(size: dimensions, position: location)
                }
                x += 0.01
            }
            x -= 0.2
            z += 0.01
        }
    }
    
    struct Size{
        var width = 0.0
        var height = 0.0
        var length = 0.0
    }
    
    struct Position{
        var xCoord = 0.0
        var yCoord = 0.0
        var zCoord = 0.0
        var cRad = 0.0
    }
}
