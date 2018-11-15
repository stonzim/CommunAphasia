//
//  TextResult_ViewController.swift
//  CommunAphasia
//
//  Created by RedSQ on 17/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit
import Hero

/**
    Class that controls the Text result screen.
 */
class TextResult_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    // Reference to the label which will display the result of converting images to text ...?
    @IBOutlet weak var resultLabel: UILabel!
    
    var inputString = String()
    var cellsToBeShown = [(word: String, type: String, image: UIImage, suggestions: [String], grNum: String,category: String,tense: String)]()
    
    /**
        Called after the controller's view is loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultLabel.text = inputString // Shows at bottom what was typed.
        resultCollectionView.dataSource = self
        resultCollectionView.delegate = self
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .right
        self.view.addGestureRecognizer(swipeLeft)
    }
    /** recognises a swipe left and returns to the previous menu if so
     */
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            self.backButtonAction(AnyObject.self)
        }
    }
    
    /**
        Sent to the view controller when the app receives a memory warning.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
        Tells the colelction view how many cells it needs to hold.

        - Parameters:
            - collectionView:   The collection view requesting this information.
            - section:          An index number identifying a section in
                                collectionView. This index value is 0-based.

        - Returns:  The number of rows in section.
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("> w2bs count", wordsToBeShown.count)
        return  cellsToBeShown.count  //number of images going to be shown
    }
    
    
    /**
        Makes the items within the given collection view upto the size of the
        collectionview.

        - Parameters:
            - collectionView:   The collection view requesting this information.
            - indexPath:        The index path that specifies the location of
                                the item.

        - Returns:  a configured cell object. Must not return `nil` from this
                    method.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextResultCell", for: indexPath) as! ImageCell //gives the type of the custom class that was made for the cell-----might need to create a seperate class for text->images
        
        
        cell.addData(cell: cellsToBeShown[indexPath.item])
        cell.showType()
        return cell
    }
    @IBAction func backButtonAction(_ sender: Any) {
        let textToImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextInputVC")
        textToImageVC.hero.isEnabled = true
        textToImageVC.hero.modalAnimationType = .fade
        self.hero.replaceViewController(with: textToImageVC)
    }
    
} // End of TextResult_ViewController class!
