//
//  ImageInputTutorial.swift
//  CommunAphasia
//
//  Created by RedSQ on 9/18/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit

class ImageInputTutorial: UIViewController {
    var tuteNum:Int = 0
    
    @IBOutlet var tuteOverlay: MakeTransparentHoleOnOverlayView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tuteOverlay.tuteNum = self.tuteNum
        
        tuteOverlay.setUp(num: tuteNum)
        
    }
}

class TutorialStep {
    var window: CGRect
    var message:String
    var messagePos:CGPoint
    var clickRect:CGRect
    var extraWindow:CGRect
    //should really add a 'state' field
    
    init(window: CGRect,message:String,messagePos:CGPoint,clickRect:CGRect,extraWindow: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)) {
        self.window = window
        self.message = message
        self.messagePos = messagePos
        self.clickRect = clickRect
        self.extraWindow = extraWindow
    }

}
class Tutorials {
    
    func genTute(num:Int) -> [TutorialStep] {
        if num == 1 {
            return [
                TutorialStep(window: CGRect(x: 0, y: 0, width: 0, height: 0), message: "Tap screen to begin tutorial", messagePos: CGPoint(x: 216, y: 68),clickRect: CGRect(x: 0, y: 0, width: 2000, height: 2000)),
                TutorialStep(window: CGRect(x: 1015-5, y: 121-5, width: 66+10, height: 532+10), message: "Cycle through categories", messagePos: CGPoint(x: 216, y: 68),clickRect: CGRect(x: 1015+6, y: 121+9, width: 66, height: 532)),
                TutorialStep(window: CGRect(x: 1015-5, y: 121-5, width: 66+10, height: 532+10), message: "Keep it up! Check out another category", messagePos: CGPoint(x: 216, y: 68),clickRect: CGRect(x: 1015+6, y: 121+9, width: 66, height: 532)),
                TutorialStep(window: CGRect(x: 1015-5, y: 121-5, width: 66+10, height: 62+10), message: "Choose the common images category", messagePos: CGPoint(x: 216, y: 68),clickRect: CGRect(x: 1015+6, y: 121+9, width: 55, height: 52)),
                TutorialStep(window: CGRect(x: 30, y: 121, width: 99+10, height: 96+10), message: "Select a pronoun", messagePos: CGPoint(x: 216, y: 68), clickRect:CGRect(x: 30, y: 121, width: 99, height: 96)),
                TutorialStep(window: CGRect(x: 30+(109*2), y: 121, width: 99+10, height: 96+10), message: "Now select a verb", messagePos: CGPoint(x: 216, y: 68), clickRect:CGRect(x: 30+(109*2)+6, y: 121+9, width: 99, height: 96)),
                TutorialStep(window: CGRect(x: 30+(109*3), y: 121, width: 99+10, height: 96+10), message: "Nice! Now select a noun", messagePos: CGPoint(x: 216, y: 68), clickRect:CGRect(x: 30+(109*3)+6, y: 121+9, width: 99, height: 96)),
                TutorialStep(window: CGRect(x: 30+(109*4), y: 121, width: 99+10, height: 96+10), message: "Select another word", messagePos: CGPoint(x: 216, y: 68), clickRect:CGRect(x: 30+(109*4)+6, y: 121+9, width: 99, height: 96)),
                TutorialStep(window: CGRect(x: 923-5, y: 762-5, width: 58+10, height: 32+10), message: "If you don't want a picture anymore, try deleting it", messagePos: CGPoint(x: 216, y: 68), clickRect:CGRect(x: 923, y: 762, width: 58, height: 32)),
                TutorialStep(window: CGRect(x: 1016-5, y: 759-5, width: 85+10, height: 39+10), message: "Great! Hit the 'Done' button to finish your sentence", messagePos: CGPoint(x: 216, y: 68), clickRect:CGRect(x: 1016, y: 759, width: 85, height: 39))
            ]
        }else if num == 2 {
            return [
                TutorialStep(window: CGRect(x: 0, y: 0, width: 0, height: 0), message: "Tap screen to begin tutorial", messagePos: CGPoint(x: 216, y: 220),clickRect: CGRect(x: 0, y: 0, width: 2000, height: 2000)),
                TutorialStep(window: CGRect(x: 166-5, y: 163-10, width: 806+115+10, height: 33+20), message: "Enter the phrase: \"The large tree is green\" and press 'Done'", messagePos: CGPoint(x: 216, y: 220), clickRect: CGRect(x: 988, y: 157, width: 97, height: 45)),
                TutorialStep(window: CGRect(x: 406-5, y: 504-5, width: 300+10, height: 200+10), message: "Use the scroll wheel to change \"large\" to \"big\" and press 'Done'", messagePos: CGPoint(x: 216, y: 220), clickRect: CGRect(x: 988, y: 157, width: 97, height: 45),extraWindow: CGRect(x: 988-5, y: 157-5, width: 97+10, height: 45+10))
            ]
        }else {
        //default tute
            return [TutorialStep(window: CGRect(x: 0, y: 0, width: 0, height: 0), message: "Sorry an error occured, tap screen to exit tutorial", messagePos: CGPoint(x: 216, y: 90),clickRect: CGRect(x: 0, y: 0, width: 2000, height: 2000))]
        }
    }
}

//Source: https://gist.github.com/aldo-jlaurenstin/2ed6569b1a3746645143
class MakeTransparentHoleOnOverlayView: UIView {
    var tapCount:Int = 0
    var tuteNum: Int = 0
    var tutes:Tutorials = Tutorials()//class to generate tutorials
    var eventQueue:[TutorialStep] = []
    var currentStep:TutorialStep = TutorialStep(window: CGRect(x: 0, y: 0, width: 0, height: 0), message: "This is a placeholdeer", messagePos: CGPoint(x: 216, y: 90),clickRect: CGRect(x: 0, y: 0, width: 0, height: 0))
    var exitStep:TutorialStep = TutorialStep(window: CGRect(x: 0, y: 0, width: 0, height: 0), message: "Tap screen to exit tutorial", messagePos: CGPoint(x: 216, y: 68),clickRect: CGRect(x: 0, y: 0, width: 2000, height: 2000))
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    //allow presses below UIView
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if currentStep.clickRect.contains(point){
            //this means there was a tap inside the highlighted area
            //do the next tute step NOTE: this happens twice (for unknown reasons)
            tapCount += 1
            if tapCount%2 == 0 {
                if !eventQueue.isEmpty{
                    currentStep = eventQueue.removeFirst()
                    drawRect(step: currentStep)
                }else {
                    //exit
                    if currentStep.message == "Tap screen to exit tutorial" {
                        exitButton.sendActions(for: .touchUpInside)
                    }else{
                        currentStep = exitStep
                        drawRect(step: currentStep)
                    }
                }
            }
            if currentStep.message != "Cycle through categories"{
                
                let view = super.hitTest(point, with: event)
                return view == self ? nil : view
            }
        }else if currentStep.window.contains(point){
            //pass on event to parent view controller
            let view = super.hitTest(point, with: event)
            return view == self ? nil : view
        }else if exitButton.frame.contains(point){
            exitButton.sendActions(for: .touchUpInside)
        }
        return self
    }
    
    // Drawing
    
    func drawRect(step:TutorialStep) {
        
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        
        messageLabel.frame = CGRect(origin: step.messagePos, size: messageLabel.frame.size)
        messageLabel.text = step.message
        
        // Make hole in view's overlay
        // NOTE: Here, instead of using the transparentHoleView UIView we could use a specific CFRect location instead...
        path.addRect(step.window)
        
        path.addRect(bounds)
        
        layer.path = path
        layer.fillRule = kCAFillRuleEvenOdd
        self.layer.mask = layer
        //if an extra window is needed idk how even odd rule works so i just added an extra rect.
        if step.extraWindow.width != 0{
            path.addRect(step.extraWindow)
            path.addRect(bounds)
            layer.path = path
            layer.fillRule = kCAFillRuleEvenOdd
            self.layer.mask = layer
            path.addRect(CGRect(x: 0, y: 0, width: 0, height: 0))
            path.addRect(bounds)
            layer.path = path
            layer.fillRule = kCAFillRuleEvenOdd
            self.layer.mask = layer
        }
    }
    //initial draw
    override func draw(_ rect: CGRect) {
        
        drawRect(step: currentStep)
    }
    
    override func layoutSubviews () {
        super.layoutSubviews()
    }
    
    func setUp(num:Int){
        self.eventQueue = self.tutes.genTute(num: num)
        self.currentStep = eventQueue.removeFirst()
    }
    
    
    // Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    
}
