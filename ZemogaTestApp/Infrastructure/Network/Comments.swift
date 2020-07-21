//
//  Comments.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

extension JSONEntity {
    struct Comment: Decodable, Equatable {
        let postId: Int
        let id: Int
        let name: String
        let email: String
        let body: String
    }
}
