//
//  ARSCNViewDelegate.swift
//  ARmazingAdventure

import UIKit
import RealityKit
import ARKit
import SceneKit
import Foundation

// MARK: Class Extension
extension ViewController: ARSCNViewDelegate
{
    //Setting anchors
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
        
        
        //ensures the setup maze is not run without an anchor plane
        planeFound = true
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
