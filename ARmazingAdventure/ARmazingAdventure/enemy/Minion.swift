import Foundation
import SceneKit
import ARKit

class Minion: Enemy
{
    
    let minionNode = SCNNode()
    var animations = [String: CAAnimation]()
    let enemyType = Enemy.EnemyTypes.boss.type()
    
}
