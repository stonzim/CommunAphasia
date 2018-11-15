//
//  main.swift
//  NSLinguisticTagger_PROJ
//
//  Created by Max Huang on 18/09/18.
//  Copyright © 2018 RedSQ. All rights reserved.
//

import Foundation

func lemmaTag(inputString: String) -> [String] {
    var returnArray:[String] = []
    var count: Int = 0
    let tagger = NSLinguisticTagger(tagSchemes: [.lemma], options: 0)
    tagger.string = inputString
    tagger.enumerateTags(in: NSRange(location: 0, length: inputString.utf16.count),
                         unit: .word,
                         scheme: .lemma,
                         options: [.omitPunctuation, .omitWhitespace])
    { tag, tokenRange, _ in
        if let tag = tag {
            let word = (inputString as NSString).substring(with: tokenRange)
            returnArray.append(tag.rawValue)
            print("\(word): \(tag.rawValue)")
            count += 1
        } else {
            returnArray.append((inputString.components(separatedBy: " "))[count])
            count += 1
        }
    }
    return returnArray
}

print(lemmaTag(inputString: "Trees don't like to feel"))
