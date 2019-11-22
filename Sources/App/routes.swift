import Vapor

private let apiVersion = "api/v1"

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    router.get("\(apiVersion)/categories") { req in
        return categoriesExample
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
