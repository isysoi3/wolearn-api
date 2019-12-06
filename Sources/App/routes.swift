import Vapor
import Crypto

private let apiVersion = "api/v1"
struct PostgreSQLVersion: Codable {
    let version: String
}

/// Register your application's routes here.
// swiftlint:disable function_body_length
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
    router.post("\(apiVersion)/login") { req -> Future<Token.Public> in
        return try req.content.decode(RequestLoginData.self)
            .then { requestInfo -> Future<Token.Public> in
                return User.query(on: req)
                    .filter(\.login, .equal, requestInfo.login)
                    .first()
                    .unwrap(or: Abort(.unauthorized, reason: "User not found"))
                    .flatMap { user -> Future<Token.Public> in
                        guard (try? BCrypt.verify(requestInfo.password, created: user.password)) != nil else {
                            throw Abort(.unauthorized, reason: "User not found")
                        }
                        let token = try Token.generate(for: user)
                        return token.save(on: req).convertToPublic()
                }

        }
    }

    router.post("\(apiVersion)/register") { req -> Future<HTTPStatus> in
        return try req.content
            .decode(User.self)
            .save(on: req)
            .transform(to: HTTPStatus.created)
    }

    let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
    let authedRoutes = router.grouped(tokenAuthenticationMiddleware)
    
    // MARK: - auth
    authedRoutes.get("\(apiVersion)/categories") { req -> Future<[UserWordCategory]> in
        let user = try req.requireAuthenticated(User.self)
        return WordCategory.query(on: req).all()
            .map { wordCategories -> [UserWordCategory] in
                return wordCategories.map { category in
                    let isSelected = user.categories?.contains(category.id!) ?? false
                    return UserWordCategory(category: category,
                                            isSelected: isSelected)
                }
        }
    }

    authedRoutes.post("\(apiVersion)/categories") { req -> Future<HTTPStatus> in
        var user = try req.requireAuthenticated(User.self)
        guard let requestInfo = try? req.content.decode([RequestCategoryData].self) else {
            throw Abort(.badRequest, reason: "No requestInfo")
        }
        return requestInfo
            .then { newCategories -> EventLoopFuture<User> in
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
                return user.update(on: req)
        }
        .transform(to: HTTPStatus.ok )
    }

    authedRoutes.get("\(apiVersion)/learn") { req -> Future<[LearningWord]> in
        let user = try req.requireAuthenticated(User.self)
        return User.query(on: req)
            .join(\History.userId, to: \User.id)
            .filter(\.login, .equal, user.login)
            .alsoDecode(History.self)
            .all()
            .and(Word.query(on: req)
                .join(\Quiz.wordId, to: \Word.id)
                .alsoDecode(Quiz.self)
                .all()
            )
            .map { arg in
                let userWords = arg.0.map { $0.1 }.map { $0.wordId }
                let learningWords = arg.1.map { LearningWord(word: $0.0, quiz: $0.1) }

                return Array(learningWords.filter { !userWords.contains($0.id!) }.shuffled().choose(20))
        }
    }

    authedRoutes.get("\(apiVersion)/repeat") { req -> Future<[LearningWord]> in
        let user = try req.requireAuthenticated(User.self)
        return User.query(on: req)
            .join(\History.userId, to: \User.id)
            .filter(\.login, .equal, user.login)
            .alsoDecode(History.self)
            .join(\Word.id, to: \History.wordId)
            .alsoDecode(Word.self)
            .join(\Quiz.wordId, to: \Word.id)
            .alsoDecode(Quiz.self)
            .all()
            .then { array -> Future<[LearningWord]> in
                return array.map { item -> Future<LearningWord> in
                    return req.future(LearningWord(word: item.0.1, quiz: item.1))
                }.flatten(on: req)
        }.map { Array($0.shuffled().choose(20)) }
    }

    authedRoutes.post("\(apiVersion)/word") { req -> Future<HTTPStatus> in
        var user = try req.requireAuthenticated(User.self)
        guard let requestInfo = try? req.content.decode(RequestWordData.self) else {
            throw Abort(.badRequest, reason: "No requestInfo")
        }
        return requestInfo
            .then { info -> Future<HTTPStatus> in
                if info.isMemorized {
                    return History(userId: user.id!,
                                   wordId: info.id,
                                   learnedDate: Date())
                        .save(on: req)
                        .then { history -> Future<User> in
                            if user.history == nil {
                                user.history = []
                            }
                            user.history?.append(history.id!)
                            return user.update(on: req)
                        }
                        .transform(to: HTTPStatus.ok)
                } else {
                    return History.query(on: req).group(.and) { history in
                        history.filter(\.userId, .equal, user.id!)
                            .filter(\.wordId, .equal, info.id)
                    }
                    .first()
                    .flatMap { history -> Future<HTTPStatus> in
                        guard let history = history else {
                            return req.future(HTTPStatus.self).transform(to: HTTPStatus.ok)
                        }
                        let userHistory = user.history?.filter { history.id! != $0 }
                        user.history = userHistory
                        return history.delete(on: req)
                            .and(user.update(on: req))
                            .transform(to: HTTPStatus.ok)
                    }
                }
        }
    }

    authedRoutes.get("\(apiVersion)/user") { req -> UserInfo in
        let user = try req.requireAuthenticated(User.self)
        let stats = UserStatistics(today: 1,
                                   total: user.history?.count ?? 0,
                                   categories: user.categories?.count ?? 0)
        return UserInfo(info: user.public, statistics: stats)
    }

    authedRoutes.get("\(apiVersion)/user/history") { req -> Future<[LearningHistory]> in
        let user = try req.requireAuthenticated(User.self)
        guard
            let offset = try? req.query.get(Int.self, at: ["offset"]) else {
            throw Abort(.badRequest, reason: "No token")
        }
        let num = (try? req.query.get(Int.self, at: ["num"])) ?? 20

        return User.query(on: req)
            .join(\History.userId, to: \User.id)
            .filter(\.login, .equal, user.login)
            .alsoDecode(History.self)
            .join(\Word.id, to: \History.wordId)
            .alsoDecode(Word.self)
            .join(\WordCategory.id, to: \Word.categoryId)
            .alsoDecode(WordCategory.self)
            .range(lower: offset, upper: offset + num - 1)
            .all()
            .map { array in
                return array.compactMap {
                    LearningHistory(word: $0.0.1, category: $0.1, history: $0.0.0.1)
                }
        }
    }

    authedRoutes.post("\(apiVersion)/user/reset_statistics") { req -> Future<HTTPStatus> in
        var user = try req.requireAuthenticated(User.self)
        user.history = nil
        return History.query(on: req)
            .filter(\.userId, .equal, user.id!)
            .delete()
            .and(user.update(on: req))
            .transform(to: HTTPStatus.ok)
    }

    // Example of configuring a controller
//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
