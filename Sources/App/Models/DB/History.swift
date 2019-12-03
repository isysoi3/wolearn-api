//
//  History.swift
//  App
//
//  Created by Ilya Sysoi on 12/2/19.
//

import Foundation
import FluentPostgreSQL
import Vapor

struct History: PostgreSQLModel {
    typealias ID = Int

    static let entity = "history"

    var id: ID?
    var userId: User.ID
    var wordId: Word.ID
    var learnedDate: Date

    var word: Parent<History, Word> {
        parent(\.wordId)
    }
    var user: Parent<History, User> {
        parent(\.userId)
    }

    init(id: ID? = nil,
         userId: User.ID,
         wordId: Word.ID,
        learnedDate: Date) {
        self.id = id
        self.userId = userId
        self.wordId = wordId
        self.learnedDate = learnedDate
    }

}

extension History: PostgreSQLMigration { }

struct LearningHistory: Content {

    let word: String
    let category: String
    let date: String

    init(word: Word, category: WordCategory, history: History) {
        self.word = word.name
        self.category = category.name
        date = history.learnedDate.description
    }

}
