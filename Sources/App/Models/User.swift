//
//  User.swift
//  App
//
//  Created by Ilya Sysoi on 11/29/19.
//

import Foundation
import FluentPostgreSQL
import Vapor

struct User: PostgreSQLModel {

    typealias ID = Int

    static let entity = "user"
    static let name: String = "user"

    var id: ID?
    var login: String
    var categories: [Int]?

    init(id: ID? = nil, login: String, categories: [Int]) {
        self.id = id
        self.login = login
        self.categories = categories
    }
}

/// Allows `User` to be used as a dynamic migration.
extension User: PostgreSQLMigration { }

extension User: Content { }
