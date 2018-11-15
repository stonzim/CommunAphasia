//
//  Tense_ViewController.swift
//  CommunAphasia
//
//  Created by RedSQ on 8/9/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit

/**
    Protocol which must be implemented.
 */
protocol TenseDelegate: class {
    func selectedTense(cell: ImageCell, tense: String, tenseType: String, indexPath: IndexPath)
}


/**
    Class that controls the pop-up.
 */
class Tense_ViewController: UIViewController {
    
    weak var delegate: TenseDelegate?
    var cell: ImageCell?
    var indexPath: IndexPath?
    var tenses: String?
    var tuteNum:Int?
    
    @IBOutlet weak var PastImageView: UIImageView!
    @IBOutlet weak var PresentImageView: UIImageView!
    @IBOutlet weak var FutureImageView: UIImageView!
    
    @IBOutlet weak var windowInTense: windowInTense!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
        Sets up the pop-up

        - Parameters:
            - delegate:     What delegate to call after the button is pressed.
            - cell:         What cell is being acted on.
            - indexpath:    The index path that specifies the location of the
                            item.
     */
    func setUp(delegate: TenseDelegate, cell: ImageCell, indexPath: IndexPath) {
        self.delegate = delegate
        self.cell = cell
        let image = cell.imageView.image
        PastImageView.image = image
        PresentImageView.image = image
        FutureImageView.image = image
        self.indexPath = indexPath
        self.tenses = cell.tense
        
        
        if tuteNum == 1{
            windowInTense.isHidden = false            
        }else{
            windowInTense.removeFromSuperview()
        }
    }
    
    
    /**
        Past tense selected.
     */
    @IBAction func PastButtonPressed(_ sender: Any) {
        delegate?.selectedTense(cell: cell!, tense: self.tenses!, tenseType: "past", indexPath: indexPath!)
        closePopup(sender)
    }
    
    
    /**
        Present tense selected.
     */
    @IBAction func PresentButtonPressed(_ sender: Any) {
        delegate?.selectedTense(cell: cell!, tense: self.tenses!, tenseType: "present", indexPath: indexPath!)
        closePopup(sender)
    }
    
    
    /**
        Future tense selected.
     */
    @IBAction func FutureButtonPressed(_ sender: Any) {
        delegate?.selectedTense(cell: cell!, tense: self.tenses!, tenseType: "future", indexPath: indexPath!)
        closePopup(sender)
    }
    
    
    /**
        Closes the popup if no option is selected.
     */
    @IBAction func closePopup(_ sender: Any) {
        self.view.removeFromSuperview()
    }
}
class windowInTense: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if CGRect(x: 321+196-5, y: 322+40-5, width: 78+10, height: 111+10).contains(point){
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
        path.addRect(CGRect(x: 321+196-5, y: 322+40-5, width: 78+10, height: 111+10))
        
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
