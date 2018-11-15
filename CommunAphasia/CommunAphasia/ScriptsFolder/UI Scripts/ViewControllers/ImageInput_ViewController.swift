//
//  ImageInput_ViewController.swift
//  CommunAphasia
//
//  Created by RedSQ on 21/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit
import Hero

/**
    Controls everything on the image input screen.
 */
class ImageInput_ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var selectedCollectionView: UICollectionView!
    @IBOutlet weak var InputCollectionView: UICollectionView!
    
    @IBOutlet var inputCollectionViews: [UICollectionView]!
    
    @IBOutlet weak var popupView: UIView!
    
    var commonWords = ["man","woman","breakfast","bathroom",
                        "lunch","dinner","eating","sleeping",
                        "calling","big","small","I","fast","quickly","waiting",
                        "want","need","may","can","should","he","she","it","they","we","you","talk",
                        "how are you?","good morning","good night","hello","pleased to meet you","my name is",
                        "what is your name?","on top","in","next to","in front","behind","between","around",
                        "through","above","below","over","underneath","one","two","three","car","phone",
                        "eat","cook","buy","walk","go","use","talk","like","take","don't"]
    var selectedWords = [String]()
    var selectedCells = [ImageCell]()
    
    @IBOutlet var popover: UIView!
    @IBOutlet weak var popoverWord: UILabel!
    
    // Category UI things.
    @IBOutlet var tabButtons: [UIButton]! // array of tab buttons
    let tabColour: [String] = ["e0f0ea", "def2f1", "d9eceb", "cfe3e2", "bed3d2", "aec8c7", "9ab8b6", "8facab", "99afae"]
    var currentCategoyIndex = 0
    private var cellsInCategory: [[(String, String, UIImage, [String], String, String, String)]]! //temp storage to be used by collection view cells
    let categories = ["common","emotions","animals","food","activity","travel","object","number", "other"]
    
    var currentTute:Int = 0
    private var selectedCell: ImageCell? //for tense controllers
    private var selectedIndexPath: IndexPath? //for tense controllers
    /**
        Called after the controller's view is loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        for collection in inputCollectionViews{
            collection.dataSource = self
            collection.delegate = self
            
        }
        selectedCollectionView.dataSource = self
        selectedCollectionView.delegate = self
        
        // Colourises the tabs
        for button in tabButtons{
            button.setImage(UIImage(named: "Current tab")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.imageView?.tintColor = UIColor(hex: tabColour[button.tag])
        }
        ChangeCategory(tabButtons[0])
        
        
        if currentTute != 0 {
            showTute(num: currentTute)
        }
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .right
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right && currentTute == 0{
            self.backButtonAction(AnyObject.self)
        }
    }
    /**
        calls the tutorial view controler to allow the user to learn
        how to use the app.
     
     - parameter num: which tutoral the user is undergoing
     */
    func showTute(num: Int) {
        let tuteVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tuteVC") as! ImageInputTutorial
        
        tuteVC.tuteNum = num
        self.addChildViewController(tuteVC)
        tuteVC.view.frame = self.view.frame
        self.view.addSubview(tuteVC.view)
        tuteVC.didMove(toParentViewController: self)
    }
    
    /**
        Sent to the view controller when the app receives a memory warning.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
        Reference to the UI `done` button.

        - Parameter sender: The object which called this function.
     */
    @IBAction func DoneButton(_ sender: Any) {
        if selectedWords.count > 0 {
            for cell in selectedCells {
                cell.setFreq(f: cell.freq + 1)
            }
            // At least one image is selected
            ImageToText.instance.reset()
            let imageResultsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageResultVC") as! ImageResult_ViewController
            imageResultsVC.selectedCellsResult = selectedCells
            self.hero.isEnabled = true
            imageResultsVC.hero.isEnabled = true
            imageResultsVC.hero.modalAnimationType =  .fade
            self.hero.replaceViewController(with: imageResultsVC)
            
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC")
        mainVC.hero.isEnabled = true
        mainVC.hero.modalAnimationType = .pageOut(direction: HeroDefaultAnimationType.Direction.right)
        self.hero.replaceViewController(with: mainVC)
        
    }
    
    
    /**
        Called when a tab is pressed and uses the tab tag to determine what
        category to use.
     
        - Parameter sender: Tab button pressed
     */
    @IBAction func ChangeCategory(_ sender: UIButton) {
        for button in tabButtons {
            if button.tag == currentCategoyIndex {
                button.imageView?.tintColor = UIColor(hex: tabColour[button.tag])
            }
            if button.tag == sender.tag {
                // New tab to be selected
                 button.imageView?.tintColor = UIColor(hex: "ffffff")
            }
        }
        if sender.tag == 0 {
            cellsInCategory = Utility.instance.getWordsInDatabase(words: commonWords)
        } else {
            cellsInCategory = Utility.instance.getCellsByCategory(category: categories[sender.tag])
        }
        for collection in inputCollectionViews{
            collection.reloadData()
        }
        sortCellsByfreq()
        fillSpaceWithCollectionViews()
        currentCategoyIndex = sender.tag
    }
    
    /**
     Sorts the 2d array that consists of arrays of cells (cellsInCategory). the cells are sorted
     in their array by the frequency of their word.
     
     */
    func sortCellsByfreq(){
        //this has to make a small call to the database for every image but was easier than changing every tuple to type ImageCell
        var tempCells: [[(String, String, UIImage, [String], String, String, String)]] = [[]]
        for cellArray in cellsInCategory {
            //images of a specific type
            var wordfreqs:[String:Int] = [:]
            for cell in cellArray {
                wordfreqs[cell.0] = Utility.instance.getFreq(word: cell.0)
            }
            let sortedWords:[String] = Array(wordfreqs.keys).sorted(by: { (word1, word2) -> Bool in
                return wordfreqs[word1]! > wordfreqs[word2]!
            })
            tempCells.append(cellArray.sorted(by: { (cell1, cell2) -> Bool in
                return sortedWords.index(of: cell1.0)! < sortedWords.index(of: cell2.0)!
            }))
        }
        tempCells.removeFirst()
        cellsInCategory = tempCells
    }
    
    /**
     Dynamically changes the size of image cell collections so that they always expand to fill the whole
     view while trying to make the user have to scroll as little as possible.
     
     */
    func fillSpaceWithCollectionViews() {
        var iterator:[Int] = [3,2,0,1,4,5] // beacue the order of collections is on the piss
        let totalColumns: Int = 9 //width of the image to text view (in images)
        
        for item in iterator {
            let numCells = inputCollectionViews[item].numberOfItems(inSection: 0)
            if numCells == 0 {
                iterator.remove(at: iterator.index(of: item)!)
                inputCollectionViews[item].frame = CGRect(x: -100, y: -100, width: 0, height: 0)//get rid of empty collections
            }
        }
        //decides how many columns each collection should take up
        var numCols = iterator.count;
        var collsPerItem:[Int] = Array(repeatElement(1, count: 10))//10 magic number should change(or not)
        while numCols < totalColumns {
            var maxCellsIndex = 5;
            for item in iterator {
                if inputCollectionViews[item].numberOfItems(inSection: 0)/collsPerItem[item]
                    > inputCollectionViews[maxCellsIndex].numberOfItems(inSection: 0)/collsPerItem[maxCellsIndex] {
                    maxCellsIndex = item
                }
            }
            collsPerItem[maxCellsIndex] += 1
            numCols += 1
        }
        //moves each collection to its position based on above.
        var currentX = 30//changed from 43
        for item in iterator {
            let origin = CGPoint(x: currentX, y: 121)
            let size = CGSize(width: 109*collsPerItem[item], height: 532)//was 486
            
            inputCollectionViews[item].frame = CGRect(origin: origin, size: size)
            currentX += 109*collsPerItem[item]
            
        }

    }
    
    //----------------------------------------------------------------------------------90
    // Collection view stuff.
    //----------------------------------------------------------------------------------90
    
    /**
        Tells the colelction view how many cells it needs to hold.
     
        - Parameters:
            - collectionView:   The collection view requesting this information.
            - section:          An index number identifying a section in
                                `collectionView`. This index value is 0-based.
     
        - Returns:  The size of the given `collectionView`.
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if( collectionView == self.selectedCollectionView){
            return selectedWords.count
        }else{
            
            return cellsInCategory[collectionView.tag].count
        }
    }
    
    
    /**
        Makes the items within the given collection view upto the size of the
        collectionview.
     
        - Parameters:
            - collectionView:   The collection view requesting this information.
            - indexPath:        The index path that specifies the location of
                                the item.
     
        - Returns:  A configured cell object. Must not return nil.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.selectedCollectionView {
            //SelectedCollectionView
            // Gives the type of the custom class that was made for the cell.
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedCell", for: indexPath) as! ImageCell
            cell.addImageInputVC(parent: self)
            return cell
            
        }else{
            //input collection views
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputCell", for: indexPath) as! ImageCell
            cell.addData(cell: cellsInCategory[collectionView.tag][indexPath.item])
            cell.showType()
            cell.addImageInputVC(parent: self)
            return cell
        }
    }
       
    
    /**
        Controls what happens if an item is selected within a `collectionView`.
        Tells the delegate that the item at the specified index path was
        selected.
     
        - Parameters:
            - collectionView:   The collection view object that is notifying you
                                of the selection change.
            - indexPath:        The index path of the cell that was selected.
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != self.selectedCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as! ImageCell
            // Do something with the cell
            if cell.type == wordType.noun.rawValue {
                showSinglePluralVC(cell: cell, indexPath: indexPath)
            }else if cell.type == wordType.verb.rawValue || cell.type == wordType.modal.rawValue || cell.type == wordType.adjective.rawValue || cell.type == "prep" {
                showTenseVC(cell: cell, indexPath: indexPath)
            } else {
                selectedWords.append(cell.word)
                let insertedIndexPath = IndexPath(item: selectedWords.count-1, section: 0)
                selectedCollectionView?.insertItems(at: [insertedIndexPath]) // Add a new cell to bottom table view using the tuple.
                let newCell = selectedCollectionView?.cellForItem(at: insertedIndexPath) as! ImageCell
                newCell.addData(cell: cell.extractData())
                newCell.showType()
                selectedCells.append(newCell)
            }
        }
    }
    
    
    /**
        Bring up the popup that asks for single or plural.
     
        - Parameters:
            - cell:         The cell that was pressed.
            - indexPath:    The index path of the cell that was selected.
     */
    func showSinglePluralVC(cell: ImageCell, indexPath: IndexPath) {
        let singlePluralVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SinglePluralVC") as! SinglePlural_ViewController
        
        self.addChildViewController(singlePluralVC)
        singlePluralVC.view.frame = self.view.frame
        self.view.addSubview(singlePluralVC.view)
        singlePluralVC.didMove(toParentViewController: self)
        
        //need to add tute for these popups
        if currentTute == 1 {
            singlePluralVC.tuteNum = 1
        }
        singlePluralVC.setUp(delegate: self, cell: cell, indexPath: indexPath)
    }
    
    
    /**
        Shows the tense pop-up, giving user option to choose past, present, or
        future tense.
     
        - Parameters:
            - cell:         The cell that was pressed.
            - indexPath:    The index path of the cell that was selected.
     */
    func showTenseVC(cell: ImageCell, indexPath: IndexPath) {
        let tenseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tenseVC") as! Tense_ViewController
        selectedCell = cell
        selectedIndexPath = indexPath
        self.addChildViewController(tenseVC)
        tenseVC.view.frame = self.view.frame
        self.view.addSubview(tenseVC.view)
        tenseVC.didMove(toParentViewController: self)

        //need to add tute for these popups
        if currentTute == 1 {
            tenseVC.tuteNum = 1
        }
        tenseVC.setUp(delegate: self, cell: cell, indexPath: indexPath)
    }
    
    /**
     Used to send data across view controllers
     
     - Parameters:
         - segue:   Where to go
         - sender:  Who called the perform
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "TenseSegue") {
            let destinationVC = segue.destination as! Tense_ViewController
            if currentTute == 1 {
                destinationVC.tuteNum = 1
            }
            destinationVC.setUp(delegate: self, cell: selectedCell!, indexPath: selectedIndexPath!)
        }
    }
    
    
    /**
        Called by the delete button to remove an already selected cell.
     
        - Parameter sender: The object which called this function.
     */
    @IBAction func deleteSelectedCell(_ sender: Any) {
        if selectedCells.count > 0 {
            let indexPath = IndexPath(item: selectedWords.count-1, section: 0)
            selectedCells.remove(at: indexPath.item) //removes from the list of selected cells
            selectedWords.remove(at: indexPath.item) //removes word from selected word (needs to be done before deleteing item because its the data source)
            selectedCollectionView?.deleteItems(at: [indexPath]) //removes from input collection view
        }
    }
    /**
     Shows the popover
     
     - Parameters:
         - word:      Word to show
         - position:  Where the popover goes
     */
    func showPopover(word: String, position: CGPoint){
        let pos = CGPoint(x: position.x, y: position.y-40)
        
        self.view.addSubview(popover)
        popover.center = pos
        popoverWord.text = word
    }
    /**
     Hides the popover
     */
    func hidePopover(){
        self.popover.removeFromSuperview()
    }

} // End of ImageInput_ViewController class!
//--------------------------------------------------------------------------------------90


/**
    Adds a delegate to the `ImageInput_ViewController` so that it can get
    things from the plural/single pop-up.
 */
extension ImageInput_ViewController : SinglePluralDelegate {
    func selectedGNum(cell: ImageCell, grNum: String, indexPath: IndexPath) {
        selectedWords.append(cell.word)
        let insertedIndexPath = IndexPath(item: selectedWords.count-1, section: 0)
        selectedCollectionView?.insertItems(at: [insertedIndexPath]) // add a new cell to bottom table view using the tuple
        let newCell = selectedCollectionView?.cellForItem(at: insertedIndexPath) as! ImageCell
        newCell.addData(cell: cell.extractData())
        if grNum == "singular"{
            newCell.grNum = grNum
        }else if newCell.grNum == "r"{
            newCell.grNum = "plural"
        }
        if grNum == "plural"{
            newCell.showPlural()
        }
        newCell.showType()
        selectedCells.append(newCell)
    }
}


/**
    Adds a delegate to the `ImageInput_ViewController` so that it can get
    things from the plural/single pop-up.
 */
extension ImageInput_ViewController : TenseDelegate {
    func selectedTense(cell: ImageCell, tense: String, tenseType: String, indexPath: IndexPath) {
        selectedWords.append(cell.word)
        let insertedIndexPath = IndexPath(item: selectedWords.count-1, section: 0)
        selectedCollectionView?.insertItems(at: [insertedIndexPath]) // add a new cell to bottom table view using the tuple
        
        let newCell = selectedCollectionView?.cellForItem(at: insertedIndexPath) as! ImageCell
        newCell.addData(cell: cell.extractData())
        newCell.tense = tense
        newCell.tenseType = tenseType
        newCell.showTense(tenseType: tenseType)
        newCell.showType()
        selectedCells.append(newCell)
    }
}

