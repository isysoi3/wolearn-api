//
//  RequestLoginData.swift
//  App
//
//  Created by Ilya Sysoi on 12/1/19.
//

import Foundation
import Vapor

struct RequestLoginData: Content {

    let login: String
    let password: String

}
