//
//  ImageResultViewCell.swift
//  CommunAphasia
//
//  Created by RedSQ on 26/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit


/**
    The class for the cell in the `ImageResultCollectionView`.
 
    It stores the cell properties and deals with assigning and exporting.
 */
class ImageCell: UICollectionViewCell {
    // Good to manage these variables in the class but could be done with an
    // array in the view controller.
    var word: String = "car"
    var type: String = "verb" // for the type of word (noun, verb etc). Could use enums.
    var suggestedWords = [String]()
    var grNum: String = gNum.singlular.rawValue
    var category: String = "Other"
    var tense: String = "current"
    var freq: Int = 0
    
    var frequency:Int = 0
    var imageInputVC: ImageInput_ViewController?
    
    // Reference to the image on the UI which are changed to reflect the image.
    @IBOutlet weak var imageView: UIImageView!
    let colourDict: [String: CGColor] = ["noun":UIColor.red.cgColor,
                                         "adj":UIColor.green.cgColor,
                                         "verb":UIColor.blue.cgColor,
                                         "pronoun":UIColor.orange.cgColor,
                                         "adverb":UIColor.purple.cgColor,
                                         "modal":UIColor.magenta.cgColor]
    var tenseType: String = "present"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        imageView.addGestureRecognizer(longGesture)
    }
    
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        if sender.state == .ended {
            //Do Whatever You want on End of Gesture
            imageInputVC?.hidePopover()
        }
        else if sender.state == .began {
            //Do Whatever You want on Began of Gesture
            imageInputVC?.showPopover(word: word, position: sender.location(in: imageInputVC?.view))
        }
    }
    
    func addImageInputVC(parent: ImageInput_ViewController){
        imageInputVC = parent
    }
    
    /**
        Takes in a tuple and assigns it to class properties.

        - Parameter cell:   A tuple containing the following properties:
           - word:          The word for the cell.
           - type:          The type of word.
           - image:         The image to be displayed in the cell.
           - suggestions:   Possible suggestions which are related to the word.
     */
    func addData(cell: (word: String, type: String, image: UIImage, suggestions: [String], grNum: String,category: String,tense: String)) {
        self.word = cell.word
        self.type = cell.type
        self.imageView.image = cell.image
        self.suggestedWords = cell.suggestions
        self.grNum = cell.grNum
        self.category = cell.category
        self.tense = cell.tense
        self.getFreq()
    }
    
    
    /**
        Extracts the cell properties and puts it into a tuple.

        - Returns:  A tuple containing the cell's properties.
           - word:         The word for the cell.
           - type:         The type of word.
           - image:        The image to be displayed in the cell.
           - suggestions:  Possible suggestions which are related to the word.
     */
    func extractData()-> (word: String, type: String, image: UIImage, suggestions: [String], grNum: String,category: String,tense: String) {
        return (self.word, self.type, self.imageView.image!, self.suggestedWords, self.grNum, self.category, self.tense)
    }
    
    func setFreq(f:Int) {
        self.freq = f
        //maybe
        Utility.instance.setFreq(word: self.word, freq: f)
    }
    func getFreq() -> Int{
        //maybe
        self.freq = Utility.instance.getFreq(word: self.word)
        
        return self.freq
    }
    
    /**
        Shows a duplicate of the image to show plurality.
     */
    func showPlural() {
        let image = imageView.image
        let size = CGSize(width: imageView.frame.width, height: imageView.frame.height)
        UIGraphicsBeginImageContext(size)
        let space: CGFloat = 15
        let backSize = CGRect(x: 0, y: 0, width: imageView.frame.width-space, height: imageView.frame.height-space)
        let frontSize = CGRect(x: space, y: space, width: imageView.frame.width-space, height: imageView.frame.height-space)
        
        //if i decide to try and aspect fit plural images
        //https://stackoverflow.com/questions/43094186/uiimage-aspect-fill-when-using-drawinrect
        
        image?.draw(in: backSize, blendMode: CGBlendMode.normal, alpha: 0.7)
        image?.draw(in: frontSize)
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        imageView.image = newImage
    }
    
    
    /**
        Shows a clock below the image denoting the tense.
     
        - Parameter tenseType:  either `past`, `present`, or `future`.
     */
    func showTense(tenseType: String) {
        let image = imageView.image
        var tenseImage = UIImage(named: "imagePlaceholder.png")
        if tenseType == "past" {
            tenseImage = UIImage(named: "pastTense.png")!
        } else if tenseType == "present" {
            tenseImage = UIImage(named: "presentTense.png")!
        } else if tenseType == "future" {
            tenseImage = UIImage(named: "futureTense.png")!
        }
        let size = CGSize(width: imageView.frame.width, height: imageView.frame.height)
        UIGraphicsBeginImageContext(size)
        
        // For tense sitting below image
        let finalSize = CGRect(x: (size.width - (size.width*0.6))/2, y: 0, width: size.width*0.6, height: size.height*0.6)
        let tenseSize = CGRect(x: (size.width - (size.width*0.4))/2, y: size.height-(size.height*0.4), width: (size.width*0.4), height: (size.height*0.4))
        
        image!.draw(in: finalSize, blendMode: CGBlendMode.normal, alpha: 1)
        tenseImage?.draw(in: tenseSize, blendMode: CGBlendMode.normal, alpha: 1)
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        imageView.image = newImage
    }
    
    
    /**
        Places a border around the image, depending on its lexical type.
     
        Shrinks image to accommodate for border width.
     */
    func showType(thisType: String? = nil){
        //print(">>",type)
        let borderWidth: CGFloat = 5
        imageView.layer.borderWidth = borderWidth
        if thisType == nil{
            imageView.layer.borderColor = colourDict[type]
        }else{
            imageView.layer.borderColor = colourDict[thisType!]
        }
        let image = imageView.image
        let size = CGSize(width: imageView.frame.width, height: imageView.frame.height)
        UIGraphicsBeginImageContext(size)
        image?.draw(in: CGRect(x: borderWidth, y: borderWidth, width: size.width-(borderWidth*2), height: size.height-(borderWidth*2)))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        imageView.image = newImage
    }
}
