// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "WolearnApi",
    products: [
        .library(name: "WolearnApi", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.1"),

        // 🐘 Non-blocking, event-driven Swift client for PostgreSQL.
        //.package(url: "https://github.com/vapor/postgresql.git", from: "1.5.0"),
        
        //🖋🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgres-driver", from: "1.0.0"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

