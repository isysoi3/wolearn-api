//
//  Word.swift
//  App
//
//  Created by Ilya Sysoi on 11/22/19.
//

import Foundation
import Vapor

struct Word: Content {
    let id: Int
    let name: String
    let pos: String
    let transcription: String
    let examples: [String]
    let quiz: Quiz
    
}

struct Quiz: Content {
    let indexOfRight: Int
    let options: [String]
}

let wordsExample = [Word(id: 1,
                         name: "strong",
                         pos: "adj",
                         transcription: "strɒŋ",
                         examples: ["An example of strong is someone who can lift 200 pounds.",
                                    "A strong hand shot out and grasped her arm"],
                         quiz: Quiz(indexOfRight: 0, options: ["Having or marked by great physical power",
                                                               "A short talk or conversation:",
                                                               "a procedure intended to establish the quality, performance, or reliability of something, especially before it is taken into widespread use.",
                                                               "Lacking the power to perform physically demanding tasks; having little physical strength or energy"])),
                    Word(id: 2,
                         name: "hope",
                         pos: "noun",
                         transcription: "həʊp",
                         examples: ["he looked through her belongings in the hope of coming across some information",
                                    "came in hopes of seeing you"],
                         quiz: Quiz(indexOfRight: 3, options: ["",
                                                               "",
                                                               "",
                                                               "a feeling of expectation and desire for a particular thing to happen."])),
                    Word(id: 3,
                         name: "explain",
                         pos: "verb",
                         transcription: "ɪkˈspleɪn,ɛkˈspleɪn",
                         examples: ["they explained that their lives centred on the religious rituals",
                                    "her father's violence explains her pacifism"],
                         quiz: Quiz(indexOfRight: 1, options: ["lay hold of (something) with one's hands; reach for and hold",
                                                               "make (an idea or situation) clear to someone by describing it in more detail or revealing relevant facts.",
                                                               "come to have (something); receive",
                                                               "move from one place to another; travel"]))]
