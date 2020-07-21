//
//  StubDecodableTask.swift
//  ZemogaTestAppTests
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation
@testable import ZemogaTestApp

enum UnitTestError: Error {
    case paramError
}

class StubDecodableTask: DecodableTask {
    func doDecodeTask<T>(_ type: T.Type, from url: URL, completion: @escaping (Result<T, Error>) -> Void) where T : Decodable {
        
        switch url {
        case Endpoints.posts.url:
            completion(.success(JSONDummies.posts as! T))
        case Endpoints.users.url:
            completion(.success(JSONDummies.users as! T))
        case Endpoints.comments.url:
            completion(.success(JSONDummies.comments as! T))
        default:
            completion(.failure(UnitTestError.paramError))
        }
        
    }
    
    
}

