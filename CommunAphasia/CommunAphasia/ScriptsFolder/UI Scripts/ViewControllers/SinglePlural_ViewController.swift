//
//  SinglePlural_ViewController.swift
//  CommunAphasia
//
//  Created by RedSQ on 27/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit

/**
    Makes a protocol so that the `imageInput_VC` has to implement the delegate.
 */
protocol SinglePluralDelegate: class {
    func selectedGNum(cell: ImageCell, grNum: String, indexPath: IndexPath)
}


/**
    Class that controls the `singlePlural` pop-up.
 */
class SinglePlural_ViewController: UIViewController {
    
    weak var delegate: SinglePluralDelegate?
    var cell: ImageCell?
    var indexPath: IndexPath?
    var tuteNum:Int?
    
    @IBOutlet weak var singleImageView: UIImageView!
    @IBOutlet weak var pluralImageView: UIImageView!
    @IBOutlet weak var backPluralImageView: UIImageView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var windowInPlural: windowInPlural!
    
    /**
        Called after the controller's view is loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    
    /**
        Sent to the view controller when the app receives a memory warning.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
        Sets up the pop-up.
     
        - Parameters:
            - delegate:     What delegate to call after the button is pressed.
            - cell:         What cell is being acted on.
            - indexpath:    The index path that specifies the location of the
                            item.
     */
    func setUp(delegate: SinglePluralDelegate, cell: ImageCell, indexPath: IndexPath) {
        self.delegate = delegate
        self.cell = cell
        let image = cell.imageView.image
        singleImageView.image = image
        pluralImageView.image = image
        backPluralImageView.image = image
        self.indexPath = indexPath
        
        if tuteNum == 1{
            windowInPlural.isHidden = false
        }else{
            windowInPlural.removeFromSuperview()
        }
        
        self.hero.isEnabled = true
    }
    
    
    /**
        The `single` button has been pressed (user has chosen `single` for
        that noun).
     
        - Parameter sender: The object which called this function.
     */
    @IBAction func selectSingle(_ sender: Any) {
        delegate?.selectedGNum(cell: cell!, grNum: "singular", indexPath: indexPath!)
        closePopup()
    }
    
    
    /**
        The `plural` button has been pressed (user has chosen `plural` for
        that noun).
     
        - Parameter sender: The object which called this function.
     */
    @IBAction func selectPlural(_ sender: Any) {
        delegate?.selectedGNum(cell: cell!, grNum: "plural", indexPath: indexPath!)
        closePopup()
    }
    
    
    /**
        Can tap anywhere else to not choose `single` or `plural`.
     */
    @IBAction func closePopup(){
        self.view.removeFromSuperview()
        
    }
}

class windowInPlural: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if CGRect(x: 394+39-5, y: 333+45-5, width: 78+10, height: 79+10).contains(point){
            let view = super.hitTest(point, with: event)
            return view == self ? nil : view
        }
        return self
    }
    
    func drawRect() {
        
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        
        
        // Make hole in view's overlay
        // NOTE: Here, instead of using the transparentHoleView UIView we could use a specific CFRect location instead...
        path.addRect(CGRect(x: 394+39-5, y: 333+45-5, width: 78+10, height: 79+10))
        
        path.addRect(bounds)
        
        layer.path = path
        layer.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = layer
    }
    //initial draw
    override func draw(_ rect: CGRect) {
        drawRect()
    }
}
