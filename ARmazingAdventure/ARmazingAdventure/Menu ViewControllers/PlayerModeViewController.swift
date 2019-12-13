import Foundation
import UIKit
import ARKit

class PlayerModeViewController: UIViewController
{
    @IBOutlet weak var arSCNView: ARSCNView!
    @IBOutlet weak var singlePlayerButton: UIButton!
    @IBAction func backTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
