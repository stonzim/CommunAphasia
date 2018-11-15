//
//  ImageResult_ViewController.swift
//  CommunAphasia
//
//  Created by RedSQ on 21/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit
import Hero

/**
    Class that controls the Image result screen.
 */
class ImageResult_ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {

    @IBOutlet weak var InputImagesCollectionView: UICollectionView!
    @IBOutlet weak var resultTextLabel: UILabel!
    var selectedCellsResult = [ImageCell]()
    
    
    /**
        Called after the controller's view is loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        InputImagesCollectionView.delegate = self
        InputImagesCollectionView.dataSource = self
       
        let convertedSentance = (ImageToText.instance.createSentence(pics: selectedCellsResult))
        let textToDisplay = (convertedSentance.split(separator: " ")).joined(separator: " ")
        resultTextLabel.text = textToDisplay
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .right
        self.view.addGestureRecognizer(swipeLeft)

        
        Utility.instance.setRecentSentence(sentence: selectedCellsResult)
        // Do any additional setup after loading the view.
    }

    
    /**
        Sent to the view controller when the app receives a memory warning.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            self.backAction(AnyObject.self)
        }
    }

    //----------------------------------------------------------------------------------90
    // Shows input images on screen.
    //----------------------------------------------------------------------------------90
    
    /**
        Asks the `collectionView` object for the number of items in the
        specified section.
     
        - Parameters:
            - collectionView:   The collection view requesting this information.
            - section:          An index number identifying a section in
                                `collectionView`. This index value is 0-based.
     
        - Returns:  The number of rows in `section`.
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedCellsResult.count
    }
   
    
    /**
        Asks `collectionView` object for the cell that corresponds to the
        specified item in the collection view.
        Makes it upto the size of the `collectionView`.
     
        - Parameters:
            - collectionView:   The collection view requesting this information.
            - indexPath:        The index path that specifies the location of
                                the item.
     
        - Returns:  A configured cell object. Must not return nil.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageResultCell", for: indexPath) as! ImageCell
        
        cell.addData(cell: selectedCellsResult[indexPath.item].extractData())
        cell.showType()
        return cell
    }
    /**
     Used by back button to go back to input screen
     
     - Parameter word: Who called the action
     */
    @IBAction func backAction(_ sender: Any) {
        let imageInputVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageInputVC")
        imageInputVC.hero.isEnabled = true
        imageInputVC.hero.modalAnimationType =  .fade

        self.hero.replaceViewController(with: imageInputVC)

    }
}
