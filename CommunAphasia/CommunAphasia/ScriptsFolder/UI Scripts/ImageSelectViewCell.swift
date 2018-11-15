//
//  ImageSelectViewCell.swift
//  CommunAphasia
//
//  Created by RedSQ on 21/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit

class ImageSelectViewCell: UICollectionViewCell {
    //good to manage these variables in the clzass but could be done with an array in the view controller
    var word: String = "car"
    var type: String = "verb" //for the type of word (noun, verb etc)
    var num: String = "singular"
    
    @IBOutlet weak var imageView: UIImageView!
    var suggestedWords = [String]()
    //
    
    func addData(cell: (word: String, type: String, num: String, image: UIImage , suggestions: [String])){
        self.word = cell.word
        self.type = cell.type
        self.num = cell.num
        self.imageView.image = cell.image
        self.suggestedWords = cell.suggestions
        
        //---colouring boarders---//
        /*if type == "noun"{
            layer.borderColor = UIColor.red.cgColor
        }else{
            layer.borderColor = UIColor.blue.cgColor
            
        }
        layer.borderWidth = 4 //max dont change*/
    }
    
    func extractData()-> (word: String, type: String, num: String, image: UIImage, suggestions: [String]){
        let word = self.word
        let type = self.type
        let num = self.num
        let suggestions = self.suggestedWords
        let image = self.imageView.image!
        return (word, type, num, image, suggestions)
    }
    
    
  
    
   
}
