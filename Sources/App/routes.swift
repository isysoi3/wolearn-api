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
    
    router.get("\(apiVersion)/categories") { req in
        return WordCategory.query(on: req).all().map { (wordCategories) -> [UserWordCategory] in
            return wordCategories.map {
                return UserWordCategory.init(category: $0,
                                             isSelected: true)
            }
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
