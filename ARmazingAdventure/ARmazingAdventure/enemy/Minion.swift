//
//  Minions.swift
//  ARmazingAdventure
//
//  Created by Shuji Chen on 2019-11-12.
//  Copyright © 2019 ShuJi Chen. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Minion: Enemy{
    
    let minionNode = SCNNode()
    var animations = [String: CAAnimation]()
    let enemyType = Enemy.EnemyTypes.boss.type()
    
}
