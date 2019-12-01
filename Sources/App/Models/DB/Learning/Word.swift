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
    let quiz: LearningQuiz

    init(word: Word, quiz: Quiz) {
        self.id = word.id
        self.name = word.name
        self.pos = word.pos
        self.transcription = word.transcription
        self.examples = word.examples
        self.quiz = LearningQuiz(quiz: quiz)
    }
}
