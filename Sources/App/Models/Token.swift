//
//  Token.swift
//  App
//
//  Created by Ilya Sysoi on 12/1/19.
//

import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

struct Token: PostgreSQLModel {
    
    typealias ID = Int
    static var entity: String = "token"
    
    var id: ID?
    var token: String
    var userId: User.ID
    
    var `public`: Public {
        return Public(token: token)
    }

    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
    
    struct Public: Content {
        let token: String
    }
}

extension Token: Migration {}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(),
                         userId: user.requireID())
    }
}


extension Token: Authentication.Token {
    
    static var tokenKey: WritableKeyPath<Token, String> {
        return \Token.token
    }
    
    static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \Token.userId
    }
    
    typealias UserType = User
    typealias UserIDType = User.ID
    
}

extension Token {
    var user: Parent<Token, User> {
        return parent(\.userId)
    }
}

extension Future where T == Token {
    func convertToPublic() -> Future<Token.Public> {
        return self.map(to: Token.Public.self) { token in
            return token.public
        }
    }
}
