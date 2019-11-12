//
//  HelperFunctions.swift
//  ARmazingAdventure

import UIKit
import RealityKit
import ARKit
import SceneKit

//converts worldTransform value to simd_float3 for access to position
public extension float4x4
{
    var translation: simd_float3
    {
        let translation = self.columns.3
        return simd_float3(translation.x, translation.y, translation.z)
    }
}

public extension UIButton
{
    func preventRepeatedPresses(inNext seconds: Double = 1.5)
    {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds)
        {
                self.isUserInteractionEnabled = true
        }
    }
}
