import Vapor

private let apiVersion = "api/v1"
struct PostgreSQLVersion: Codable {
    let version: String
}

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
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
        struct TMP: Content {
            let id: Int
            let isSelected: Bool
        }
        guard let uCategories = try? req.content.decode([TMP].self) else {
            throw Abort(.badRequest, reason: "No id")
        }
        return User.query(on: req)
            .filter(\.login, .equal, "test")
            .first()
            .unwrap(or: Abort(.nonAuthoritativeInformation, reason: "User not found"))
            .and(uCategories)
            .then { arg -> EventLoopFuture<HTTPResponse> in
                var (user, newCategories) = arg
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
    
    router.get("\(apiVersion)/words") { req in
        return wordsExample
    }

    // Example of configuring a controller
//    let todoController = TodoController()
//    router.get("todos", use: todoController.index)
//    router.post("todos", use: todoController.create)
//    router.delete("todos", Todo.parameter, use: todoController.delete)
}
