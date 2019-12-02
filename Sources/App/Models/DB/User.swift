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
    var history: [Int]?

//    var history: Children<User, History> {
//        children(\.userId)
//    }

    init(id: ID? = nil,
         login: String,
         name: String,
         surname: String,
         password: String,
         categories: [Int]? = nil,
         history: [Int]? = nil) {
        self.id = id
        self.login = login
        self.name = name
        self.surname = surname
        self.password = password
        self.categories = categories
        self.history = history
    }

    struct Public: Content {
        var id: ID?
        var login: String
        var name: String
        var surname: String

        fileprivate init(user: User) {
            self.id = user.id
            self.login = user.login
            self.name = user.name
            self.surname = user.surname
        }
    }

    var `public`: Public {
        return Public(user: self)
    }

}

/// Allows `User` to be used as a dynamic migration.
extension User: PostgreSQLMigration {

    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.update(User.self, on: conn) { builder in
            builder.field(for: \.history)
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

extension User {
    func convetToPublic() -> User.Public {
        self.public
    }
}

extension Future where T == User {
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convetToPublic()
        }
    }
}
