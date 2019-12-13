import Foundation
import UIKit
import ARKit

class SettingMenuViewController: UIViewController
{
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var ARCanvas: ARSCNView!
    @IBAction func backTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
