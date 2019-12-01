//
//  RequestCategoryData.swift
//  App
//
//  Created by Ilya Sysoi on 12/1/19.
//

import Foundation
import Vapor

struct RequestCategoryData: Content {

    struct RequestCategory: Content {
        let id: Int
        let isSelected: Bool
    }

    var token: String
    var categories: [RequestCategory]
}
