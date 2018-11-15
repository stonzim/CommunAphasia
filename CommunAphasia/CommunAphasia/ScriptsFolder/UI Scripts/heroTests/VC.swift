//
//  VC.swift
//  CommunAphasia
//
//  Created by RedSQ on 28/09/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit

class VC: UIViewController {
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var whiteView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        redView.hero.id = "ironMan"
        
        print("vc")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func buttonPressed(_ sender: Any) {
        self.hero.isEnabled = true
        whiteView.hero.id = "ironMan"
        whiteView.hero.modifiers = [.translate(y:100)]
    }
}
