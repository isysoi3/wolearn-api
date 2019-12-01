//
//  User.swift
//  App
//
//  Created by Ilya Sysoi on 11/29/19.
//

import Foundation
import FluentPostgreSQL
import Vapor
import Crypto

struct User: PostgreSQLModel {

    typealias ID = Int

    static let entity = "user"
    static let name: String = "user"

    var id: ID?
    var login: String
    var name: String
    var surname: String
    var password: String
    var categories: [Int]?

    init(id: ID? = nil,
         login: String,
         name: String,
         surname: String,
         password: String,
         categories: [Int] = []) {
        self.id = id
        self.login = login
        self.name = name
        self.surname = surname
        self.password = password
        self.categories = categories
    }
}

/// Allows `User` to be used as a dynamic migration.
extension User: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: conn) { builder in
            let defaultValueConstraint = PostgreSQLColumnConstraint.default(.literal(""))
            builder.field(for: \.name, type: PostgreSQLDataType.text, defaultValueConstraint)
            builder.field(for: \.surname, type: PostgreSQLDataType.text, defaultValueConstraint)
            builder.field(for: \.password, type: PostgreSQLDataType.text, defaultValueConstraint)
        }
    }

    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return conn.future()
    }

}

extension User {

    func willCreate(on conn: PostgreSQLConnection) throws -> EventLoopFuture<User> {
        var user = self
        guard let hashPWD = try? BCrypt.hash(user.password, cost: 5) else {
            throw Abort(.unauthorized, reason: "Some error")
        }
        user.password = hashPWD
        return Future.map(on: conn) { user }
    }

}

extension User: Content { }
