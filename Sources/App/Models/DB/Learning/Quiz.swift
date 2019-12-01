//
//  Quiz.swift
//  App
//
//  Created by Ilya Sysoi on 12/1/19.
//

import Foundation
import Vapor
import FluentPostgreSQL

struct Quiz: PostgreSQLModel {

    typealias ID = Int
    static let entity = "quiz"

    var id: ID?
    let wordId: ID
    let rightAnswer: String
    let options: [String]

    init(id: ID? = nil,
         wordId: ID,
         rightAnswer: String,
         options: [String]) {
        self.id = id
        self.wordId = wordId
        self.rightAnswer = rightAnswer
        self.options = options
    }

}

/// Allows `Word` to be used as a dynamic migration.
extension Quiz: PostgreSQLMigration { }

struct LearningQuiz: Content {

    let options: [String]
    let indexOfRight: Int

    init(quiz: Quiz) {
        let rightAnswer = quiz.rightAnswer
        var options = Array(quiz.options.choose(3))
        options.append(rightAnswer)
        self.options = options.shuffled()
        indexOfRight = self.options.index(of: rightAnswer)!
    }

}
