//
//  MainMenuViewController.swift
//  ARmazingAdventure
//
//  Created by Shuji Chen on 2019-10-21.
//  Copyright © 2019 Muhammad Saadan. All rights reserved.
//

import UIKit
import ARKit

class MainMenuViewController: UIViewController {

    
    @IBOutlet weak var ARCanvas: ARSCNView!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARWorldTrackingConfiguration()
        ARCanvas.session.run(config)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
