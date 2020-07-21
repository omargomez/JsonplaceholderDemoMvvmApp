//
//  User.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

extension JSONEntity {
    struct User: Decodable, Equatable {
        let id: Int
        let username: String
        let name: String
        let email: String
        let phone: String
    }
}
