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
    let imageURL: String
    
    init(id: Int, name: String, imageURL: String) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}

struct UserWordCategory: Content {
    let id: Int
    let name: String
    let imageURL: String
    let isSelected: Bool
    
    init(id: Int, name: String, imageURL: String, isSelected: Bool) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.isSelected = isSelected
    }
    
    init(category: WordCategory, isSelected: Bool) {
        self.init(id: category.id,
                  name: category.name,
                  imageURL: category.imageURL,
                  isSelected: isSelected)
    }
    
}

let categoriesExample = [UserWordCategory(id: 1,
                                          name: "Common words",
                                          imageURL: "/images/categories/common_words.jpeg",
                                          isSelected: true),
                         UserWordCategory(id: 2,
                                          name: "Food",
                                          imageURL: "/images/categories/food.jpeg",
                                          isSelected: false),
                         UserWordCategory(id: 3,
                                          name: "Family",
                                          imageURL: "/images/categories/family.jpeg",
                                          isSelected: false)]
