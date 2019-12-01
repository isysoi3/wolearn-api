import Vapor
import Crypto

private let apiVersion = "api/v1"
struct PostgreSQLVersion: Codable {
    let version: String
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    // MARK: - some info
    router.get { _ in
        return "It works!"
    }

    router.get("sql") { req in
        return req.withPooledConnection(to: .psql) { conn in
            return conn.raw("SELECT version()")
                .all(decoding: PostgreSQLVersion.self)
        }.map { rows in
            return rows[0].version
        }
    }

    // MARK: - no auth
    router.post("\(apiVersion)/login") { req -> Future<Token> in
        return try req.content.decode(RequestLoginData.self)
            .then { requestInfo in
                return User.query(on: req)
                    .filter(\.login, .equal, requestInfo.login)
                    .first()
                    .unwrap(or: Abort(.unauthorized, reason: "User not found"))
                    .map { user in
                        guard (try? BCrypt.verify(requestInfo.password, created: user.password)) != nil else {
                            throw Abort(.unauthorized, reason: "User not found")
                        }
                        return Token(token: user.login)
                }

        }
    }

    router.post("\(apiVersion)/register") { req -> Future<HTTPStatus> in
        return try req.content
            .decode(User.self)
            .map { arg -> User in
                var user = arg
                guard let hashPWD = try? BCrypt.hash(user.password, cost: 5) else {
                    throw Abort(.unauthorized, reason: "Some error")
                }
                user.password = hashPWD
                return user
            }
            .save(on: req).map { _ in HTTPStatus.ok }
    }

    // MARK: - auth
    router.get("\(apiVersion)/categories") { req -> Future<[UserWordCategory]> in
        guard let token = try? req.query.get(String.self, at: ["token"]) else {
            throw Abort(.badRequest, reason: "No token")
        }
        return User.query(on: req)
            .filter(\.login, .equal, token)
            .first()
            .unwrap(or: Abort(.nonAuthoritativeInformation, reason: "User not found"))
            .and(WordCategory.query(on: req).all())
            .map { (arg) -> [UserWordCategory] in
                let (user, wordCategories) = arg
                return wordCategories.map { category in
                    let isSelected = user.categories?.contains(category.id!) ?? false
                    return UserWordCategory(category: category,
                                            isSelected: isSelected)
                }
        }
    }

    router.post("\(apiVersion)/categories") { req -> Future<HTTPStatus> in
        guard let token = try? req.query.get(String.self, at: ["token"]) else {
            throw Abort(.badRequest, reason: "No token")
        }
        guard let requestInfo = try? req.content.decode([RequestCategoryData].self) else {
            throw Abort(.badRequest, reason: "No requestInfo")
        }
        return requestInfo
            .then { newCategories -> EventLoopFuture<HTTPStatus> in
                return User.query(on: req)
                    .filter(\.login, .equal, token)
                    .first()
                    .unwrap(or: Abort(.unauthorized, reason: "User not found"))
                    .then { user -> EventLoopFuture<HTTPStatus> in
                        var user = user
                        var newUserCategories = newCategories.compactMap { $0.isSelected ? $0.id : nil }
                        user.categories?.forEach { categoryId in
                            if !newUserCategories.contains(where: {$0 == categoryId}) {
                                newUserCategories.append(categoryId)
                            }
                        }
                        newCategories.compactMap { !$0.isSelected ? $0.id : nil }
                            .forEach { categoryId in
                                if newUserCategories.contains(where: {$0 == categoryId}) {
                                    newUserCategories.removeAll(where: {$0 == categoryId})
                                }
                        }
                        user.categories = newUserCategories
                        return user.update(on: req).map { _ in HTTPStatus.ok }
                }
            }
    }

    router.get("\(apiVersion)/words") { req -> Future<[LearningWord]> in
        guard let _ = try? req.query.get(String.self, at: ["token"]) else {
            throw Abort(.badRequest, reason: "No token")
        }
        return Word.query(on: req)
            .join(\Quiz.wordId, to: \Word.id)
            .alsoDecode(Quiz.self)
            .all()
            .map { array -> [LearningWord] in
                return array.map { word, quiz -> LearningWord in
                    LearningWord(word: word, quiz: quiz)
                }
        }
    }

    router.post("\(apiVersion)/word") { req -> Future<RequestWordData> in
        guard let _ = try? req.query.get(String.self, at: ["token"]) else {
            throw Abort(.badRequest, reason: "No token")
        }
        //        guard let requestInfo = try? req.content.decode(RequestInfo.self) else {
        //            throw Abort(.badRequest, reason: "No requestInfo")
        //        }
        return try req.content.decode(RequestWordData.self)
    }

    // Example of configuring a controller
//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
