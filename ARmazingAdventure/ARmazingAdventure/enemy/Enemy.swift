import Foundation
import SceneKit
import ARKit

class Enemy
{
    var name: String
    var maxHP : Int
    var health: Int
    
    var minAtkVal: Int
    var maxAtkVal: Int
    
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

    init(name: String, maxHP: Int, health: Int, minAtkVal: Int, maxAtkVal: Int, level: Int) {
        self.maxHP = maxHP
        self.health = health
        self.minAtkVal = minAtkVal
        self.maxAtkVal = maxAtkVal
        self.level = level
        self.name = name
    }
    
    func getName() -> String{
        return name
    }
    
    func getMaxHP() -> Int{
        return maxHP
    }
    
    func getHP() -> Int{
        return health
    }
    
    func setHP(val: Int){
        health = val
    }
    
    // MARK: Combat Functions
    func attackPlayer(target: Player) -> CGFloat
    {
        let targetCurrentHP = target.getHP()
        let dmg = Int.random(in: minAtkVal ... maxAtkVal)
        let newHP = targetCurrentHP-dmg
        
        if newHP < 0
        {
            target.setHP(val: 0)
        }
        else
        {
            target.setHP(val: newHP)
        }
        
        let convertToHPBar = CGFloat(dmg) * target.convertHPBar()
        return convertToHPBar
    }
    
    func isDead() -> Bool{
        if health <= 0{
            return true
        }
        return false
    }
    
    func convertHPBar() -> CGFloat{
        return CGFloat(200 / maxHP)
    }
}

