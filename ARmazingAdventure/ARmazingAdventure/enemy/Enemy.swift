import Foundation
import SceneKit
import ARKit

class Enemy
{
    var name: String
    var health: Int
    var attackValue: Int
    var level: Int
    
    //enemy types
    enum EnemyTypes: String {
        case minion
        case boss
        
        func type() -> String
        {
            return self.rawValue
        }
    }

    init(name: String, health: Int, attackValue: Int, level: Int) {
        self.health = health
        self.attackValue = attackValue
        self.level = level
        self.name = name
    }
    
}
