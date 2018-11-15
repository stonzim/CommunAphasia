//
//  SelectedImageViewCell.swift
//  CommunAphasia
//
//  Created by RedSQ on 26/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit

/// The class for the cell in the `SelectedCollectionView`. It stores the cell
/// properties and deals with assigning and exporting.
class SelectedImageViewCell: UICollectionViewCell {
    //good to manage these variables in the clzass but could be done with an array in the view controller
    var word: String = "car"
    var type: String = "verb" //for the type of word (noun, verb etc)
    
    /// Reference to the image on the UI which are changed to reflect the image.
    @IBOutlet weak var imageView: UIImageView!
    var suggestedWords = [String]()
    var grNum: String = gNum.singlular.rawValue
   
    
    /**
     * Takes in a tuple and assigns it to class properties.
     *
     * - Parameter cell:    a tuple containing the following properties:
     *      - word:         the word for the cell.
     *      - type:         the type of word.
     *      - image:        the image to be displayed in the cell.
     *      - suggestions:  possible suggestions which are related to the word.
     */
    func addData(cell: (word: String, type: String, image: UIImage, suggestions: [String], grNum: String)) {
        self.word = cell.word
        self.type = cell.type
        self.imageView.image = cell.image
        self.suggestedWords = cell.suggestions
        self.grNum = cell.grNum
        
        //---colouring boarders---//
        /*if type == "noun"{
         layer.borderColor = UIColor.red.cgColor
         }else{
         layer.borderColor = UIColor.blue.cgColor
         
         }
         layer.borderWidth = 4 //max dont change*/
    }
    
    
    /**
     * Extracts the cell properties and puts it into a tuple.
     *
     *  - Returns: a tuple containing the cell's properties.
     *      - word:         the word for the cell.
     *      - type:         the type of word.
     *      - image:        the image to be displayed in the cell.
     *      - suggestions:  possible suggestions which are related to the word.
     */
    func extractData()-> (word: String, type: String, image: UIImage, suggestions: [String], grNum: String) {
        let word = self.word
        let type = self.type
        let suggestions = self.suggestedWords
        let image = self.imageView.image!
        let grNum = self.grNum
        return (word, type, image, suggestions, grNum)
    }
    
    func showPlural(){
        let image = UIImage(named: "cow.png")
        let frontImageView = UIImageView(image: image)
        self.contentView.addSubview(imageView)
        frontImageView.frame = imageView.frame
        //frontImageView.frame.offsetBy(dx: 3, dy: 3)
        //imageView.frame = CGRect(x: imageView.frame.x, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
    }
}
