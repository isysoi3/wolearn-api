//
//  UserInfo.swift
//  App
//
//  Created by Ilya Sysoi on 12/2/19.
//

import Foundation
import Vapor

struct UserInfo: Content {
    let info: User.Public
    let statistics: UserStatistics
}

struct UserStatistics: Content {

    let today: Int
    let total: Int
    let categories: Int

}
