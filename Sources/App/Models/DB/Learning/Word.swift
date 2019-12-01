//
//  Word.swift
//  App
//
//  Created by Ilya Sysoi on 11/22/19.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Word: PostgreSQLModel {

    typealias ID = Int

    static let entity = "word"

    var id: ID?
    var name: String
    var pos: String
    var transcription: String
    var examples: [String]
//    let quiz: Quiz

    init(id: ID? = nil,
         name: String,
         pos: String,
         transcription: String,
         examples: [String]) {
        self.id = id
        self.name = name
        self.pos = pos
        self.transcription = transcription
        self.examples = examples
    }

}

/// Allows `Word` to be used as a dynamic migration.
extension Word: PostgreSQLMigration { }

struct LearningWord: Content {

    var id: Int?
    var name: String
    var pos: String
    var transcription: String
    var examples: [String]
    let quiz: Quiz

    init(word: Word, quiz: Quiz) {
        self.id = word.id
        self.name = word.name
        self.pos = word.pos
        self.transcription = word.transcription
        self.examples = word.examples
        self.quiz = quiz
    }

}

struct Quiz: Content {
    let indexOfRight: Int
    let options: [String]
}

/*
 quiz: Quiz(indexOfRight: 0, options: ["Having or marked by great physical power",
 "A short talk or conversation:",
 "a procedure intended to establish the quality, performance, or reliability of something, especially before it is taken into widespread use.",
 "Lacking the power to perform physically demanding tasks; having little physical strength or energy"])
 
 quiz: Quiz(indexOfRight: 3, options: ["",
                                       "",
                                       "",
                                       "a feeling of expectation and desire for a particular thing to happen."])
 quiz: Quiz(indexOfRight: 1, options: ["lay hold of (something) with one's hands; reach for and hold",
                                                                       "make (an idea or situation) clear to someone by describing it in more detail or revealing relevant facts.",
                                                                       "come to have (something); receive",
                                                                       "move from one place to another; travel"])
 
 */
