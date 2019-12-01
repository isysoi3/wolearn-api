//
//  RequestWordData.swift
//  App
//
//  Created by Ilya Sysoi on 12/1/19.
//

import Foundation
import Vapor

struct RequestWordData: Content {

    struct RequestWord: Content {
        let id: Int
        let isMemorized: Bool
    }

    var token: String
    var word: RequestWord
}
