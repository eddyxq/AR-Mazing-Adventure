import Foundation
import SceneKit
import ARKit

class Minion: Enemy
{
    let enemyType = Enemy.EnemyTypes.minion.type()
    
    init() {
        super.init(name: "Zombie", maxHP: 10, health: 10, minAtkVal: 1, maxAtkVal: 1, level: 1)
    }

    // MARK: Getters & Setters
}
