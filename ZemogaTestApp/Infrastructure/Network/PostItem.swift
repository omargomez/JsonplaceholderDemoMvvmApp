//
//  PostItem.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

struct JSONEntity {
    struct PostItem: Decodable, Equatable {
        let userId: Int
        let id: Int
        let title: String
        let body: String
    }
}
