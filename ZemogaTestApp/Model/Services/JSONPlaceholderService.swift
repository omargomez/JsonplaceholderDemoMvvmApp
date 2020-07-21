//
//  JSONPlaceholderService.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

protocol JSONPlaceholderService {
    func fetchPosts(completion: @escaping (Result<[JSONEntity.PostItem], Error>) -> Void)
    func fetchUsers(completion: @escaping (Result<[JSONEntity.User], Error>) -> Void)
    func fetchComments(completion: @escaping (Result<[JSONEntity.Comment], Error>) -> Void)
}

class JSONPlaceholderServiceImpl: JSONPlaceholderService {
    
    let decodableTask: DecodableTask
    
    init(decodableTask: DecodableTask = URLSession.shared) {
        self.decodableTask = decodableTask
    }
    
    func fetchPosts(completion: @escaping (Result<[JSONEntity.PostItem], Error>) -> Void) {
        decodableTask.doDecodeTask([JSONEntity.PostItem].self, from: Endpoints.posts.url, completion: { result in
            switch result {
            case .success(let items):
                print("JSON/fetchPosts/count: \(items.count)")
            default:
                do {}
            }
            completion(result)
        })
    }
    
    func fetchUsers(completion: @escaping (Result<[JSONEntity.User], Error>) -> Void) {
        decodableTask.doDecodeTask([JSONEntity.User].self, from: Endpoints.users.url, completion: { result in
            switch result {
            case .success(let items):
                print("JSON/fetchUsers/count: \(items.count)")
            default:
                do {}
            }
            completion(result)
        })
    }
    
    func fetchComments(completion: @escaping (Result<[JSONEntity.Comment], Error>) -> Void) {
        decodableTask.doDecodeTask([JSONEntity.Comment].self, from: Endpoints.comments.url, completion: { result in
            switch result {
            case .success(let items):
                print("JSON/fetchUsers/count: \(items.count)")
            default:
                do {}
            }
            completion(result)
        })
    }
}
