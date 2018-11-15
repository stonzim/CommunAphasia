//
//  TutorialPopup.swift
//  CommunAphasia
//
//  Created by RedSQ on 10/1/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit

class TutorialPopup: UIViewController {
    
    @IBOutlet weak var tutePopupLabel: UILabel!
    /**
     Called after the controller's view is loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    /**
     Sent to the view controller when the app receives a memory warning.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func tute1pressed(_ sender: Any) {
        performSegue(withIdentifier: "1st Tutorial", sender: self)
    }
    @IBAction func tute2pressed(_ sender: Any) {
        performSegue(withIdentifier: "2nd Tutorial", sender: self)
    }
    @IBAction func closePopup(_ sender: Any) {
        self.view.removeFromSuperview()
    }
    func setLabel(text: String){
        tutePopupLabel.text = text
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "1st Tutorial") {
            let destinationVC = segue.destination as! ImageInput_ViewController
            destinationVC.currentTute = 1
        }else if (segue.identifier == "2nd Tutorial"){
            let destinationVC = segue.destination as! TextInput_ViewController
            destinationVC.currentTute = 2
        }
    }
    
}
