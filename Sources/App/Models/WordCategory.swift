//
//  WordCategory.swift
//  App
//
//  Created by Ilya Sysoi on 11/22/19.
//

import Foundation
import FluentPostgreSQL
import Vapor

struct WordCategory: PostgreSQLModel {
    
    static let entity: String = "category"
    static let name = "category"
    
    var id: Int?
    var name: String
    var image: String
    
    init(id: Int? = nil, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}

/// Allows `WordCategory` to be used as a dynamic migration.
extension WordCategory: PostgreSQLMigration { }

struct UserWordCategory: Content {
    
    let id: Int?
    let name: String
    let imageURL: String
    let isSelected: Bool
    
    init(id: Int?, name: String, imageURL: String, isSelected: Bool) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.isSelected = isSelected
    }
    
    init(category: WordCategory, isSelected: Bool) {
        self.init(id: category.id,
                  name: category.name,
                  imageURL: "images/categories/\(category.image)",
                  isSelected: isSelected)
    }
    
}
