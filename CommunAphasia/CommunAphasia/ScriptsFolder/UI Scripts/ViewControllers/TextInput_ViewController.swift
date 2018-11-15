//
//  TextInput_ViewController.swift
//  CommunAphasia
//
//  Created by RedSQ on 17/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit
import Foundation
import Hero

/**
    Class that controls the Text input screen.
 */
class TextInput_ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // References the user input text field.
    @IBOutlet weak var textField: UITextField!
    
    var stringArray = [String]()
    var currentIndex:Int = 0
    var errorIndices = [Int]()
    
    var attributedArray = [NSMutableAttributedString]()
    
    var attributedString: NSMutableAttributedString?
    var errors = [String]()
    var errorIndex: Int = 0
    var synonyms = [[String]]()
    
    var invalidSentenceEntered: Bool = false
    var onlyOneError: Bool = false
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var synonymLabel: UILabel!
     var suggestedWordsArray = [Int]()
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pickerData:[String] = []
    
    var cells = [(word: String, type: String, image: UIImage, suggestions: [String], grNum: String,category: String,tense: String)]()
   
    var currentTute = 0
    
    /**
        Called after the controller's view is loaded into memory.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        if currentTute != 0 {
            showTute(num: currentTute)
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .right
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right && currentTute == 0{
            self.BackButtonAction(AnyObject.self)
        }
    }
    
    /**
     Called to go back to the main Menu
     */
    @IBAction func BackButtonAction(_ sender: Any) {
        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVC")
        mainVC.hero.isEnabled = true
        mainVC.hero.modalAnimationType = .pageOut(direction: HeroDefaultAnimationType.Direction.right)
        self.hero.replaceViewController(with: mainVC)
        
    }
    func showTute(num: Int) {
        let tuteVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tuteVC") as! ImageInputTutorial
        
        tuteVC.tuteNum = num
        self.addChildViewController(tuteVC)
        tuteVC.view.frame = self.view.frame
        self.view.addSubview(tuteVC.view)
        tuteVC.didMove(toParentViewController: self)
    }
    
    
    
    
    /**
        Makes an array of cells based on the input words and checks whether
        they exist in the database. It then retunrs the indices of the words
        which do not appear in the database.
     
        - Parameters:
            - wordArray:    An array of words (retrieved from the text field
                            and processed).
            - original:     The origional words (from the text field).
     
        - Returns:  an array containing the indices of the words which do not
                    exist in the database.
     */
    @available(iOS 11.0, *)
    func makeCells(using wordArray:[String], from original:[String])-> [Int] {
        var errorArray = [Int]()
        errors = []
        let originalArray = original.map { $0.lowercased() }
        let originalLemmaTagged = Utility.instance.lemmaTag(inputString: originalArray.joined(separator: " "))
        
        for word in wordArray {
            if wordArray.isEmpty && errorArray.isEmpty {
                invalidSentence()
                return []
            } else {
                var lemmaWord = ""
                if let word = originalLemmaTagged[safe: originalArray.index(of: word.lowercased())! ] {
                    lemmaWord = word
                } else {
                    invalidSentenceEntered = true
                    print("--- INVALID at: makeCells forLoop")
                    return errorArray
                }
                
                if Utility.instance.isInDatabase(word: lemmaWord) == false{
                    errorArray.append(originalArray.index(of: word)!)
                    errors.append(word)
                } else if errorArray.count == 0 {
                    let tempCell = Utility.instance.getDatabaseEntry(lemmaWord)
                    cells.append(tempCell)
                }
            }
        }
        
        stopActivityIndicator() // End loading wheel.
        
        return errorArray
    }


    
    /**
        Lets the user know that the sentence they entered is invalid.
     */
    func invalidSentence() {
        let str = "Please enter a valid sentence"
        attributedString = NSMutableAttributedString(string: str)
        attributedString?.setColor(color: UIColor.red, forText: str)
        synonymLabel.isHidden = false
        synonymLabel.attributedText = attributedString
        cells.removeAll()
    }
    
    
    /**
        This function executes when the user has finished typing their sentence
        and taps the done button. It checks that the words entered are valid
        and in the database and if they are not it will display them to the
        user in the text field.
     
        - Parameter sender: The object which called this function.
     */
    @available(iOS 11.0, *)
    @IBAction func done(_ sender: Any) {
        invalidSentenceEntered = false
        
        if textField.text != ""{
            if processTextResults(){
                let textToImageResultVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "textToImageResultVC") as! TextResult_ViewController
                textToImageResultVC.inputString = textField.text!
                textToImageResultVC.cellsToBeShown = cells
                
                textToImageResultVC.hero.isEnabled = true
                textToImageResultVC.hero.modalAnimationType = .fade
                self.hero.replaceViewController(with: textToImageResultVC)
            }
        }
    }
    
    
    /**
        Sent to the view controller when the app receives a memory warning.
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Start the loading wheel.
    func startActivityIndicator(){
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    /// Stop the loading wheel.
    func stopActivityIndicator(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()

    }
    
} // End of TextInput_ViewController class!


//--------------------------------------------------------------------------------------90
// All the synonym functionality.
//--------------------------------------------------------------------------------------90
extension TextInput_ViewController{
    
    @available(iOS 11.0, *)
    func processTextResults() -> Bool{
        stringArray = (textField.text?.components(separatedBy: " "))!
        pickerView.endEditing(true)
        pickerView.isHidden = true
        synonymLabel.isHidden = true
        synonyms = [[String]]()
        attributedString = NSMutableAttributedString()
        attributedArray.removeAll()
        errorIndex = 0
        
        
        let inputArray = Utility.instance.getSentenceToWords(from: textField.text!, separatedBy: .whitespaces, removeSelectWords: false).filter({ $0 != ""})
        let wordArray = Utility.instance.getSentenceToWords(from: textField.text!, separatedBy: .whitespaces).filter({ $0 != ""})
        
        
        let errorArray = makeCells(using: wordArray, from: inputArray)
        
        
        
        if errorArray.count > 0 {
            cells.removeAll()
            
            if errorArray.count == 1 {
                onlyOneError = true
            }
            
            suggestedWordsArray = [Int](repeating: 0, count: inputArray.count)
            //start async
            startActivityIndicator()
            DispatchQueue.global(qos: .userInitiated).async {
                for index in errorArray{
                    var availableSynonyms: [String] = []
                    // Check internet connection availability.
                    if Utility.instance.isConnectedToNetwork(){
                        print("Internet Connection Available!")
                        
                        if let synonyms = Utility.instance.getSynonym(inputArray[index]) {
                            
                            let matchedSynonyms = Utility.instance.synonymsInDataBase(from: synonyms)
                            if !matchedSynonyms.isEmpty {
                                self.suggestedWordsArray.insert(synonyms.count, at: index)
                                availableSynonyms += matchedSynonyms
                            }
                            
                        } else {
                            print("> No synonyms found from API for \"\(inputArray[index])\"")
                            
                            // Check if the word is a contraction if it cannot be sent to the WordsAPI
                            // to search for synonyms. If it is, break the contraction down to two words
                            // and add it to the suggested words.
                            var apostropheCount: Int = 0
                            for character in inputArray[index] {
                                // Using unicode to check for apostrophe because tried all other methods
                                // and can't figure out a way to check if an apostrophe exists in a String.
                                //
                                // The issue is that normal apostrophe is 39 (Unicode) but for whatever
                                // reason, the apostrophe contained in the inputArray is 8217 (Unicode).
                                if character.unicode() == 8217 || character.unicode() == 39 {
                                    apostropheCount += 1
                                }
                            }
                            
                            if apostropheCount == 1 {
                                let contraction = Utility.instance.lemmaTag(inputString: inputArray[index])
                                if !contraction.isEmpty {
                                    availableSynonyms.append(contraction.joined(separator: " "))
                                    self.suggestedWordsArray.insert(1, at: index)
                                } else {
                                    print("--- INVALID at: apostrophe")
                                    self.invalidSentenceEntered = true
                                }
                            }
                        }
                        
                        self.synonyms.append(availableSynonyms)
                    } else {
                        print("Internet Connection not Available!")
                    }
                }
                    
            
                DispatchQueue.main.async {
                    print("--- \(self.suggestedWordsArray)")
                    
                    if self.invalidSentenceEntered {
                        self.invalidInputSentence()
                    } else {
                        //do things with sysnonyms
                        self.updateSynonymLabel(word: self.errors[self.errorIndex])
                        self.synonymLabel.isHidden = false
                        
                        
                        self.pickerData = self.synonyms[self.errorIndex]
                        self.pickerData.insert("", at: 0)
                        self.currentIndex = errorArray[0]
                        self.errorIndices = errorArray
                        print("------- currentIndex", self.currentIndex)
                        self.pickerView.reloadAllComponents()
                        self.updatePickerViewVisibility()
                        
                        self.nextButton.isHidden = false
                        self.prevButton.isHidden = false
                        self.checkIfOnlyOneInvalidWord()
                        
                        for word in self.stringArray {
                            let atWord = NSMutableAttributedString(string: word)
                            if self.errors.contains(word){
                                atWord.setColor(color: UIColor.red, forText: atWord.string)
                            }
                            self.attributedArray.append(atWord)
                        }
                        self.attributedArray[self.errorIndices[0]].setColor(color: UIColor.blue, forText: self.attributedArray[self.errorIndices[0]].string)
                        self.setTextFromArray()
                        print("------- error array end", errorArray)
                    }
                    self.stopActivityIndicator()
                }
            }
        } else {
            var inputString: String = textField.text!
            var NSCount: Int = 0
            
            let tagger = NSLinguisticTagger(tagSchemes: [.lexicalClass], options: 0)
            tagger.string = inputString
            tagger.enumerateTags(in: NSRange(location: 0, length: inputString.utf16.count),
                                 unit: .word,
                                 scheme: .lexicalClass,
                                 options: [.omitPunctuation, .omitWhitespace])
            { tag, tokenRange, _ in
                if let tag = tag {
                    let word = (inputString as NSString).substring(with: tokenRange)
                    
                    
                    if cells.count > 0 {
                        if word == cells[NSCount].word {
                            cells[NSCount].type = tag.rawValue
                            NSCount += 1
                        }
                    }
                }
                
            }
            return true
        }
        return false
        
    }
                
    /**
     The number of columns of data in picker view.
     
     - Parameter pickerView: the `pickerView`.
     
     - Returns:  the number of columns in the picker view.
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    /**
     The number of rows of data in picker view.
     
     - Parameters:
     - pickerView:   the `pickerView`.
     - component:    the column in which to count the rows.
     
     - Returns:  the number of rows in selected column
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    /**
     The data to return for the row and component (column) that's being
     passed in, in picker view.
     
     - Parameters:
     - pickerView:   the `pickerView`.
     - row:          the selected row.
     - component:    the selected column.
     
     - Returns:  (Optional) the string held in the selected row and column
     if any exists.
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    /**
     Sets the colour of the text in the text input field depending on if the input is
     valid or not, and also which word is currently selected to be changed.
     */
    fileprivate func setTextLabelColour() {
        if Utility.instance.isInDatabase(word: attributedArray[currentIndex].string) {
            attributedArray[currentIndex].setColor(color: UIColor.green, forText: attributedArray[currentIndex].string)
        }else{
            attributedArray[currentIndex].setColor(color: UIColor.red, forText: attributedArray[currentIndex].string)
        }
    }
    
    
    /**
     If there are invalid characters in the input, the user is presented
     with an error message asking them to rephrase.
     */
    fileprivate func invalidInputSentence() {
        synonymLabel.isHidden = false
        pickerView.isHidden = true
        nextButton.isHidden = true
        prevButton.isHidden = true
        synonymLabel.text = "Invalid sentence. Please try again."
    }
    
    
    /**
        If there is only one invalid word in the input sentence, then don't
        display the left and right arrows.
     */
    fileprivate func checkIfOnlyOneInvalidWord() {
        if onlyOneError {
            nextButton.isHidden = true
            prevButton.isHidden = true
        }
    }
    
    
    /**
     Updates the error message displayed on screen if there are invalid words.
     */
    fileprivate func updateSynonymLabel(word: String) {
        if invalidSentenceEntered {
            invalidInputSentence()
        } else {
            checkIfOnlyOneInvalidWord()
            
            if Utility.instance.isInDatabase(word: word) {
                let displayText = NSMutableAttributedString(string: word + " is valid!")
                displayText.setColor(color: UIColor.blue, forText: word)
                synonymLabel.attributedText =  displayText
            } else {
                let displayText = NSMutableAttributedString(string: "Can't find: " + word + "\nTry one of these:")
                displayText.setColor(color: UIColor.blue, forText: word)
                synonymLabel.attributedText = displayText
            }
        }
    }
    
    
    /**
     Selects the current word to be changed and sets the colour to `blue`.
     */
    fileprivate func suggestionValidator() {
        currentIndex = errorIndices[errorIndex]
        updateSynonymLabel(word: stringArray[currentIndex])
        
        pickerData = synonyms[errorIndex]
        pickerData.insert("", at: 0)
        pickerView.reloadAllComponents()
        
        attributedArray[currentIndex].setColor(color: UIColor.blue, forText: attributedArray[currentIndex].string)
        setTextFromArray()
    }
    
    
    /**
     Updates the visibility of the picker view depending on whether there are
     suggestions to show or not.
     */
    fileprivate func updatePickerViewVisibility() {
        if invalidSentenceEntered {
            invalidInputSentence()
        } else {
            checkIfOnlyOneInvalidWord()
            
            if suggestedWordsArray[currentIndex] == 0 {
                pickerView.isHidden = true
                let displayText = NSMutableAttributedString(string: "Unable to find alternatives for: " + stringArray[currentIndex] + "\nPlease try a different word")
                displayText.setColor(color: UIColor.blue, forText: stringArray[currentIndex])
                synonymLabel.attributedText = displayText
            } else {
                pickerView.isHidden = false
            }
        }
    }
    
    
    /**
     When the user selects the next button the selected error (unfound word)
     in the text field moves to the right. The previous selection will turn
     green if it is in the database and red if not.
     The current selection will also turn blue.
     
     - Parameter sender: The object which called this function.
     */
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        setTextLabelColour()
        
        if currentIndex < errorIndices[errorIndices.count-1] {
            errorIndex += 1
            suggestionValidator()
            updatePickerViewVisibility()
        }
        
    }
    
    
    /**
     When the user selects the next button the selected error (unfound word)
     in the text field moves to the left. The previous selection will turn
     green if it is in the database and red if not.
     The current selection will also turn blue.
     
     - Parameter sender: The object which called this function.
     */
    @IBAction func prevButtonPressed(_ sender: Any) {
        
        setTextLabelColour()
        
        if currentIndex > errorIndices[0] {
            errorIndex -= 1
            suggestionValidator()
            updatePickerViewVisibility()
        }
    }
    
    
    /**
     This function changes the selected word in the text field depending on
     what the user selects in the `pickerView` (scroll thingy).
     
     - Parameters:
     - pickerView:   the `pickerView`.
     - row:          the row of the `pickerView` selected by the user.
     - component:    the component which is selected.
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            attributedArray[currentIndex] = NSMutableAttributedString(string: pickerData[row])
            attributedArray[currentIndex].setColor(color: UIColor.blue, forText: attributedArray[currentIndex].string)
            setTextFromArray()
        }
    }
    
    
    /**
     This function iterates through the array of attributed strings and
     adds them to a temporary string to be displayed in the text field then
     updates the text field with the changes.
     */
    func setTextFromArray(){
        let tempString = NSMutableAttributedString()
        for i in 0...attributedArray.count-1{
            tempString.append(attributedArray[i])
            tempString.append(NSMutableAttributedString(string: " "))
        }
        textField.attributedText = tempString
    }
}

extension Character {
    func unicode() -> UInt32 {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}



