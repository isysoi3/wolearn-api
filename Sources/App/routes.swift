import Vapor

private let apiVersion = "api/v1"
struct PostgreSQLVersion: Codable {
    let version: String
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
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

    router.get("\(apiVersion)/categories") { req -> Future<[UserWordCategory]> in
        guard let login = try? req.query.get(String.self, at: ["token"]) else {
            throw Abort(.badRequest, reason: "No token")
        }
        return User.query(on: req)
            .filter(\.login, .equal, login)
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

    router.post("\(apiVersion)/categories") { req -> Future<HTTPResponse> in
        guard let requestInfo = try? req.content.decode(RequestCategoryData.self) else {
            throw Abort(.badRequest, reason: "No requestInfo")
        }
        return requestInfo
            .then { info -> EventLoopFuture<HTTPResponse> in
                let newCategories = info.categories
                let token = info.token
                return User.query(on: req)
                    .filter(\.login, .equal, token)
                    .first()
                    .unwrap(or: Abort(.unauthorized, reason: "User not found"))
                    .then { user -> EventLoopFuture<HTTPResponse> in
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
                        return user.update(on: req).map { _ in HTTPResponse() }
                }
            }
    }

    router.get("\(apiVersion)/words") { req -> Future<[LearningWord]> in
        guard let login = try? req.query.get(String.self, at: ["token"]) else {
            throw Abort(.badRequest, reason: "No token")
        }
        return Word.query(on: req)
            .all()
            .map { words in
                return words.map { word in
                    return LearningWord(word: word,
                                        quiz: Quiz(indexOfRight: 0, options: ["Having or marked by great physical power",
                    "A short talk or conversation:",
                    "a procedure intended to establish the quality, performance, or reliability of something, especially before it is taken into widespread use.",
                    "Lacking the power to perform physically demanding tasks; having little physical strength or energy"]))
                }
            }
    }

    router.post("\(apiVersion)/word") { req -> Future<RequestWordData> in
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
