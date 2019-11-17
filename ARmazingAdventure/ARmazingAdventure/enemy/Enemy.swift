import Foundation
import SceneKit
import ARKit

class Enemy
{
    //enemy types
    enum EnemyTypes: String {
        case minion
        case boss
        
        func type() -> String
        {
            return self.rawValue
        }
    }

}
