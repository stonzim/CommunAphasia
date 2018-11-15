//
//  Enums.swift
//  CommunAphasia
//
//  Created by RedSQ on 25/05/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import Foundation

/**
    An enum file containing all the enum declarations.
 */

// The type of word, in terms of linguistics (e.g. noun).
enum wordType: String {
    case noun, properNoun
    case verb, adverb
    case adjective = "adj" // .rawValue will return "adj".
    case preposition
    case pronoun
    case modal
}

// The category of the image (e.g. animals).
enum imageCategory: String {
    case animal
    case food
    case colours
    case emotions
}

// Grammatical number - categorises whether a word is singular or plural.
enum gNum: String {
    case singlular
    case plural
}
