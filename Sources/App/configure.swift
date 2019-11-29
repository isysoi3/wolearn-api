import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    try services.register(FluentPostgreSQLProvider())
    
    guard
        let dbPassword = Environment.get("DB_PASSWORD"),
        let dbUsername = Environment.get("DB_USERNAME"),
        let dbName = Environment.get("DB_NAME"),
        let dbHost = Environment.get("DB_HOST")
        else {
            throw Abort(.internalServerError)
    }

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directoryˆ
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let postgresql = PostgreSQLDatabase(config:
        PostgreSQLDatabaseConfig(
            hostname: dbHost,
            port: 5432,
            username: dbUsername,
            database: dbName,
            password: dbPassword,
            transport: .unverifiedTLS)
    )

    /// Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgresql, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: WordCategory.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    services.register(migrations)
}
