//
//  EndPoints.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/25/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

enum Endpoints {
    
    static let baseURL = "https://jsonplaceholder.typicode.com"

    case posts
    case users
    case comments

    var url: URL {
        switch self {
        case .posts:
            return URL(string: String(format: "%@/posts", Endpoints.baseURL))!
        case .users:
            return URL(string: String(format: "%@/users", Endpoints.baseURL))!
        case .comments:
            return URL(string: String(format: "%@/comments", Endpoints.baseURL))!
        }
    }

}

