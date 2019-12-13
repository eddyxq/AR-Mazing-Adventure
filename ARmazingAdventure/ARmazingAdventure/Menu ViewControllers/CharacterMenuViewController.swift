import Foundation
import UIKit
import ARKit

class CharacterMenuViewController: UIViewController
{
    @IBOutlet weak var ARCanvas: ARSCNView!
    @IBAction func backTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
