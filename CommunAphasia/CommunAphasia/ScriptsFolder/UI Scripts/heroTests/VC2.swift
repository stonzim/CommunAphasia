//
//  VC2.swift
//  CommunAphasia
//
//  Created by RedSQ on 28/09/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit
import Hero

class VC2: UIViewController {
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var whiteView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        doTrans()
        // Do any additional setup after loading the view.
    }
    
    func doTrans(){
        self.hero.isEnabled = true
        redView.hero.id = "ironMan"
        blackView.hero.id = "batMan"
        whiteView.hero.modifiers = [.translate(y:100)]
        print("vc 2")
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
