//
//  WordCategory.swift
//  App
//
//  Created by Ilya Sysoi on 11/22/19.
//

import Foundation
import Vapor

struct WordCategory {
    let id: Int
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

struct UserWordCategory: Content {
    let id: Int
    let name: String
    let isSelected: Bool
    
    init(id: Int, name: String, isSelected: Bool) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
    }
    
    init(category: WordCategory, isSelected: Bool) {
        self.init(id: category.id, name: category.name, isSelected: isSelected)
    }
    
}

let categoriesExample = [UserWordCategory(id: 1, name: "Common words", isSelected: true),
                         UserWordCategory(id: 2, name: "Food", isSelected: false),
                         UserWordCategory(id: 3, name: "Family", isSelected: false)]
