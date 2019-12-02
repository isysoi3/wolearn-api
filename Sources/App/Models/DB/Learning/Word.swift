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
    var categoryId: WordCategory.ID
    var name: String
    var pos: String
    var transcription: String
    var examples: [String]
    var quiz: Children<Word, Quiz> {
        children(\.wordId)
    }
    var history: Children<Word, History> {
        children(\.wordId)
    }
    var category: Parent<Word, WordCategory> {
        parent(\.categoryId)
    }

    init(id: ID? = nil,
         categoryId: WordCategory.ID,
         name: String,
         pos: String,
         transcription: String,
         examples: [String]) {
        self.id = id
        self.categoryId = categoryId
        self.name = name
        self.pos = pos
        self.transcription = transcription
        self.examples = examples
    }

}

/// Allows `Word` to be used as a dynamic migration.
extension Word: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(Word.self, on: conn) { builder in
            let defaultValueConstraint = PostgreSQLColumnConstraint.default(.literal(1))
            builder.field(for: \.categoryId, type: PostgreSQLDataType.bigint, defaultValueConstraint)
        }
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return conn.future()
    }

}

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
