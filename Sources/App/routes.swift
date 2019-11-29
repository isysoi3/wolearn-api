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
    
    router.get("\(apiVersion)/categories", String.parameter) { req -> Future<[UserWordCategory]> in
        let login = try req.parameters.next(String.self)
        return req.requestPooledConnection(to: .psql).flatMap { conn in
            defer { try? req.releasePooledConnection(conn, to: .psql) }
            return conn
                .raw("""
                    select category.*
                    from \"user\" u
                    join category on category.id = ANY(u.categories)
                    where u.login = '\(login)'
                    """)
                .all(decoding: WordCategory.self)
                .and(WordCategory.query(on: req).all())
                .map { (arg) -> [UserWordCategory] in
                    let (userWordCategories, wordCategories) = arg
                    return wordCategories.map { category in
                        return UserWordCategory(category: category,
                                                isSelected: userWordCategories.contains(where: { $0 == category }))
                    }
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
