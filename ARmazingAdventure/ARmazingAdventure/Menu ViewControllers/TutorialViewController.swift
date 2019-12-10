//
//  TutorialViewController.swift
//  ARmazingAdventure
//
//  Created by Shuji Chen on 2019-12-09.
//  Copyright © 2019 ShuJi Chen. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController: UIViewController{
    
    @IBOutlet weak var tutorialImage1: UIImageView!
    
    @IBOutlet weak var tutorialImage2: UIImageView!
    
    @IBOutlet weak var tutorialImage3: UIImageView!
    
    @IBOutlet weak var tutoralTextLabel: UILabel!
    
    @IBOutlet weak var previousButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var steps = 1
    
    
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if steps == 1{
            setTutoral(step: "2")
            steps += 1
            previousButton.isEnabled = true
        }else if steps == 2{
            setTutoral(step: "3")
            steps += 1
            nextButton.isEnabled = false
        }
    }
    
    
    @IBAction func previousButtonPressed(_ sender: Any) {
        if steps == 2{
            setTutoral(step: "1")
            steps -= 1
            previousButton.isEnabled = false
        }else if steps == 3{
            setTutoral(step: "2")
            steps -= 1
            nextButton.isEnabled = true
        }
    }
    
    override func viewDidLoad()
    {
        previousButton.isEnabled = false
        setTutoral(step: "1")
    }
    
    func setTutoral(step: String){
        tutoralTextLabel.textColor = UIColor.black
        if step == "1"{
           tutoralTextLabel.text = "1. Navigate through the maze with your wits."
            tutorialImage1.isHidden = false
            tutorialImage2.isHidden = true
            tutorialImage3.isHidden = true
        }else if step == "2"{
            tutoralTextLabel.text = "2. Slay enemies that stand in your way."
            tutorialImage1.isHidden = true
            tutorialImage2.isHidden = false
            tutorialImage3.isHidden = true
        }else{
            tutoralTextLabel.text = "3. Win!"
            tutorialImage1.isHidden = true
            tutorialImage2.isHidden = true
            tutorialImage3.isHidden = false
        }
        
        
    }
    
}
