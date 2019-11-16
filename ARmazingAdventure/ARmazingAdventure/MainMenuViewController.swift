import UIKit
import ARKit

class MainMenuViewController: UIViewController
{
    @IBOutlet weak var ARCanvas: ARSCNView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let config = ARWorldTrackingConfiguration()
        ARCanvas.session.run(config)
    }
}
