//
//  ImageToText.swift
//  CommunAphasia
//
//  Created by RedSQ on 24/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import UIKit
import Foundation


// Flag that is toggled when the subject of the sentence is entered.
var haveSubject: Bool = false

// Flag that is toggled when the subject verb of the sentence is entered.
var subVerb: Bool = false


/**
    Class that takes the imageCell and computes the appropriate words to form
    sentences.
 */
class ImageToText {
    static let instance = ImageToText()
    var cell: ImageCell?
    var tenses: [String] = []

    /**
        Basic constructor
     */
    private init() {}

    /**
        Function that inputs the words which carry meaning (eg. nouns, pronouns,
        verbs etc.).
     
        - Parameter pics:   An array of `imageCells`.
     
        - Returns:  The completed sentence as a `String`.
     */
    func createSentence(pics: [ImageCell]) -> String {
        var returnString:Array<String> = []
        var temp:String = ""
        var wordToAppend = ""
        let dict = ["past":0,"present":1,"future":2]
        
        for imageNum in 0...pics.count-1 {
            tenses = pics[imageNum].tense.components(separatedBy: "+")
            // first word, probably add 'the'
            if imageNum==0 {
                if (pics[0].type == wordType.adjective.rawValue || pics[0].type == wordType.noun.rawValue){
                    returnString.append("The")          // index 0
                    haveSubject = true
                    if pics[0].type == wordType.noun.rawValue {
                        returnString.append((pics[0].grNum != "singular") ? pluralize(pic: pics[0]) : pics[0].word)   // index 1
                    } else {
                        returnString.append(pics[0].word)
                    }
                } else if pics[0].type == wordType.pronoun.rawValue {
                    haveSubject = true
                    returnString.append(pics[0].word.capitalized)
                } else {
                    returnString.append(pics[0].word.capitalized)
                }
            }else{
                let thisPic = pics[imageNum]  // only need to access value once, instead of thrice.
                let prevPic = pics[imageNum-1]
                
                if thisPic.type == wordType.noun.rawValue {
                    temp = isNoun(prevWord: prevPic)
                    if (thisPic.grNum == "singular") {
                        wordToAppend = thisPic.word
                    } else {
                        wordToAppend = pluralize(pic: thisPic)
                    }
                    if (prevPic.type == "number") {
                        if (prevPic.word == "one") {
                            wordToAppend = thisPic.word // make singular
                        }
                    }
                    
                    returnString.append(temp)
                    returnString.append(wordToAppend)
                }else if thisPic.type == wordType.pronoun.rawValue {
                    if prevPic.type == wordType.verb.rawValue {
                        if prevPic.suggestedWords[0] != "nil" {
                            returnString.append(prevPic.suggestedWords[0])
                        }
                    }
                    if haveSubject == true {
                        returnString.append(thisPic.grNum)
                    }
                    
                }else if thisPic.type == wordType.modal.rawValue {
                    temp = isModal(prevWord: prevPic, currentWord: thisPic)
                    returnString.append(temp)
                    returnString.append(tenses[dict[thisPic.tenseType]!])
                    subVerb = true
                }else if thisPic.type == wordType.adverb.rawValue {
                    temp = isAdverb(prevWord: prevPic)
                    returnString.append(temp)
                    returnString.append(thisPic.word)
                }else if thisPic.type == "number" {
                    temp = isNumber(prevWord: prevPic, currentWord: thisPic)
                    returnString.append(temp)
                    returnString.append(thisPic.word)
                }else if thisPic.type == wordType.adjective.rawValue {
                    temp = isAdj(prevWord: prevPic, currentWord: thisPic)
                    returnString.append(temp)
                    returnString.append(thisPic.word)
                }else if thisPic.type == "prep" {
                    temp = isPrep(prevWord: prevPic, currentWord: thisPic)
                    returnString.append(temp)
                    returnString.append(thisPic.word)
                }else if thisPic.type == wordType.verb.rawValue {
                    temp = isVerb(prevWord: prevPic, currentWord: thisPic)
                    returnString.append(temp)
                    if prevPic.type == wordType.modal.rawValue && prevPic.tenseType == "past" {
                        returnString.append(tenses[0])
                    }
                    else if subVerb == true {
                    returnString.append(thisPic.word)
                    } else {
                    returnString.append(tenses[dict[thisPic.tenseType]!])
                    }
                    subVerb = true
                }else{
                    returnString.append(thisPic.word)
                }
            }
        }
        return returnString.joined(separator: " ")
    }
    
    
    /**
        A function that returns the plural form of the word.
     
        - Parameter pics:   The `ImageCell` with the word to be 'pluralized'.
     
        - Returns:  The plural form of the word, as a `String`.
     */
    func pluralize(pic: ImageCell) -> String {
        if (pic.grNum == "plural") {
            return pic.word + "s"
        } else {
            return pic.grNum
        }
    }
    
    
    /**
        Function that inputs 'helper' words, with respect to nouns, into the
        final sentence (eg. prepositions, articles, the verb to be etc.).
     
        - Parameter prevWord:   The previous `ImageCell` in the array. Used to
                                get the previous function word in the sentence.
     
        - Returns:  a `String` with either nothing or a helper word.
     */
    func isNoun(prevWord: ImageCell) -> String{
        var temp = ""
        if prevWord.type == wordType.verb.rawValue {
            if prevWord.suggestedWords[0] != "nil" {
            temp = prevWord.suggestedWords[0] + " the"
            } else {
                temp = "the"
            }
        }else if prevWord.type == wordType.noun.rawValue {
            temp = (prevWord.grNum == "singular") ? "is" : "are"
        }else if prevWord.type == wordType.adjective.rawValue {
            temp = ""
        }else if prevWord.type == wordType.pronoun.rawValue {
            temp = prevWord.suggestedWords[1] + " the"
        }else if prevWord.type == wordType.modal.rawValue {
            temp = "the"
        }else if prevWord.type == "number" {
            temp = ""
        }else if prevWord.type == "prep" {
            if (prevWord.word == "in front" || prevWord.word == "on top") {
                temp = "of the"
            } else {
            temp = "the"
            }
        }else if prevWord.type == wordType.adverb.rawValue {
            temp = ""
        }
        return temp
    }
    
    
    /**
        Function that inputs 'helper' words, with respect to adjectives,
        into the final sentence (eg. prepositions, articles, the verb to be
        etc.).
     
        - Parameters:
            - prevWord:     The previous `ImageCell` in the array. Used to
                            get the previous function word in the sentence.
            - currentWord:  The current `ImageCell` in the array. Used to
                            get the current function word in the sentence.
     
        - Returns:  a `String` with either nothing or a helper word.
     */
    func isAdj(prevWord: ImageCell, currentWord: ImageCell) -> String{
        var temp = ""
        if prevWord.type == wordType.verb.rawValue {
            if prevWord.suggestedWords[0] != "nil" {
                temp = prevWord.suggestedWords[0] + " the"
            } else {
            temp = "the"
            }
        }else if prevWord.type == wordType.noun.rawValue {
            if currentWord.tenseType == "past" {
                temp = (prevWord.grNum == "singular") ? "was" : "were"
            } else if currentWord.tenseType == "present" {
                temp = (prevWord.grNum == "singular") ? "is" : "are"
            } else {
                temp = (prevWord.grNum == "singular") ? "will be" : "will be"
            }
        }else if prevWord.type == wordType.adjective.rawValue {
            temp = ","
        }else if prevWord.type == wordType.pronoun.rawValue {
            if currentWord.tenseType == "past" {
                temp = prevWord.suggestedWords[0]
            } else if currentWord.tenseType == "present" {
                temp = prevWord.suggestedWords[1]
            } else {
                temp = prevWord.suggestedWords[2]
            }
        }else if prevWord.type == wordType.modal.rawValue {
            temp = "the"
        }else if prevWord.type == "number" {
            temp = ""
        }else if prevWord.type == "prep" {
            if (prevWord.word == "in front" || prevWord.word == "on top") {
                temp = "of the"
            } else {
                temp = "the"
            }
        }else if prevWord.type == wordType.adverb.rawValue {
            temp = ""
        }
        return temp
    }
    
    
    /**
        Function that inputs 'helper' words, with respect to adverbs,
        into the final sentence (eg. prepositions, articles, the verb to be
        etc.).

        - Parameter prevWord:   The previous `ImageCell` in the array. Used to
                                get the previous function word in the sentence.

        - Returns:  a `String` with either nothing or a helper word.
     */
    func isAdverb(prevWord: ImageCell) -> String{
        var temp = ""
        if prevWord.type == wordType.verb.rawValue {
        }else if prevWord.type == wordType.noun.rawValue {
            temp = (prevWord.grNum == "singular") ? "is" : "are"
        }else if prevWord.type == wordType.adjective.rawValue {
            temp = ","
        }else if prevWord.type == wordType.pronoun.rawValue {
            temp = ""
        }else if prevWord.type == wordType.modal.rawValue {
            temp = "the"
        }else if prevWord.type == "number" {
            temp = ""
        }else if prevWord.type == "prep" {
            if (prevWord.word == "in front" || prevWord.word == "on top") {
                temp = "of the"
            } else {
                temp = "the"
            }
        }else if prevWord.type == wordType.adverb.rawValue {
            temp = ","
        }
        return temp
    }
    
    
    /**
        Function that inputs 'helper' words, with respect to verbs,
        into the final sentence (eg. prepositions, articles, the verb to be
        etc.).

        - Parameters:
            - prevWord:     The previous `ImageCell` in the array. Used to
                            get the previous function word in the sentence.
            - currentWord:  The current `ImageCell` in the array. Used to
                            get the current function word in the sentence.

        - Returns:  a `String` with either nothing or a helper word.
     */
    func isVerb(prevWord: ImageCell, currentWord: ImageCell) -> String{
        var temp = ""
        if prevWord.type == wordType.verb.rawValue {
            if subVerb == true {
                temp = "to"
            }
        }else if prevWord.type == wordType.noun.rawValue {
            if subVerb == false {
                if currentWord.tenseType == "present" {
                    temp = (prevWord.grNum == "singular") ? "is" : "are"
                }
            } else {
                temp = "to"
            }
        }else if prevWord.type == wordType.adjective.rawValue {
            temp = ""
        }else if prevWord.type == wordType.pronoun.rawValue {
            if currentWord.tenseType == "present" {
            temp = prevWord.suggestedWords[1]
            }
        }else if prevWord.type == wordType.modal.rawValue {
            temp = ""
        }else if prevWord.type == "number" {
            temp = ""
        }else if prevWord.type == "prep" {
                temp = ", "
        }else if prevWord.type == wordType.adverb.rawValue {
            temp = ""
        }
        return temp
    }
    
    
    /**
        Function that inputs 'helper' words, with respect to modal verbs,
        into the final sentence (eg. prepositions, articles, the verb to be
        etc.).

        - Parameters:
            - prevWord:     The previous `ImageCell` in the array. Used to
                            get the previous function word in the sentence.
            - currentWord:  The current `ImageCell` in the array. Used to
                            get the current function word in the sentence.

        - Returns:  a `String` with either nothing or a helper word.
     */
    func isModal(prevWord: ImageCell, currentWord: ImageCell) -> String{
        var temp = ""
        if prevWord.type == wordType.verb.rawValue {
            temp = ""
        }else if prevWord.type == wordType.noun.rawValue {
            temp = ""
        }else if prevWord.type == wordType.adjective.rawValue {
            temp = ""
        }else if prevWord.type == wordType.pronoun.rawValue {
            temp = ""
        }else if prevWord.type == "number" {
            temp = ""
        }else if prevWord.type == wordType.modal.rawValue {
            temp = ""
        }else if prevWord.type == "prep" {
            temp = ", "
        }else if prevWord.type == wordType.adverb.rawValue {
            temp = ""
        }
        return temp
    }
    
    /**
     Function that inputs 'helper' words, with respect to modal verbs,
     into the final sentence (eg. prepositions, articles, the verb to be
     etc.).
     
     - Parameters:
     - prevWord:     The previous `ImageCell` in the array. Used to
     get the previous function word in the sentence.
     - currentWord:  The current `ImageCell` in the array. Used to
     get the current function word in the sentence.
     
     - Returns:  a `String` with either nothing or a helper word.
     */
    func isNumber(prevWord: ImageCell, currentWord: ImageCell) -> String{
        var temp = ""
        if prevWord.type == wordType.verb.rawValue {
            temp = ""
        }else if prevWord.type == wordType.noun.rawValue {
            temp = ""
        }else if prevWord.type == wordType.adjective.rawValue {
            temp = ""
        }else if prevWord.type == wordType.pronoun.rawValue {
            temp = ""
        }else if prevWord.type == wordType.modal.rawValue {
            temp = ""
        }else if prevWord.type == "number" {
            temp = ""
        }else if prevWord.type == "prep" {
            temp = ", "
        }else if prevWord.type == wordType.adverb.rawValue {
            temp = ""
        }
        return temp
    }
    
    /**
     Function that inputs 'helper' words, with respect to prepositions,
     into the final sentence (eg. prepositions, articles, the verb to be
     etc.).
     
     - Parameters:
     - prevWord:     The previous `ImageCell` in the array. Used to
     get the previous function word in the sentence.
     - currentWord:  The current `ImageCell` in the array. Used to
     get the current function word in the sentence.
     
     - Returns:  a `String` with either nothing or a helper word.
     */
    func isPrep(prevWord: ImageCell, currentWord: ImageCell) -> String{
        var temp = ""
        if prevWord.type == wordType.verb.rawValue {
            temp = ""
        }else if prevWord.type == wordType.noun.rawValue {
            if currentWord.tenseType == "past" {
                temp = (prevWord.grNum == "singular") ? "was" : "were"
            } else if currentWord.tenseType == "present" {
                temp = (prevWord.grNum == "singular") ? "is" : "are"
            } else {
                temp = (prevWord.grNum == "singular") ? "will be" : "will be"
            }
        }else if prevWord.type == wordType.adjective.rawValue {
            temp = ""
        }else if prevWord.type == wordType.pronoun.rawValue {
            if currentWord.tenseType == "past" {
                temp = prevWord.suggestedWords[0]
            } else if currentWord.tenseType == "present" {
                temp = prevWord.suggestedWords[1]
            } else {
                temp = prevWord.suggestedWords[2]
            }
        }else if prevWord.type == wordType.modal.rawValue {
            temp = ""
        }else if prevWord.type == wordType.adverb.rawValue {
            temp = ""
        }
        return temp
    }
    
    
    /**
        Function that resets the boolean flags for the subject and subject
        verb of the sentence.
     */
    public func reset() {
        haveSubject = false
        subVerb = false
    }
}

