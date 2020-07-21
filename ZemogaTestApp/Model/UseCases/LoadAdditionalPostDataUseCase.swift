//
//  LoadAdditionalPostDataUseCase.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

protocol LoadAdditionalPostDataUseCase {
    func execute(postId: Int32, completion: @escaping (Result<(UserEntity, [CommentEntity]), Error>) -> Void )
}

class LoadAdditionalPostDataUseCaseImpl: LoadAdditionalPostDataUseCase {
    
    let repository: CacheRepository
    let service: JSONPlaceholderService
    
    init(repository: CacheRepository = CacheRepositoryImpl(), service: JSONPlaceholderService = JSONPlaceholderServiceImpl() ) {
        self.repository = repository
        self.service = service
    }
    
    func execute(postId: Int32, completion: @escaping (Result<(UserEntity, [CommentEntity]), Error>) -> Void ) {
        
        self.repository.additionalDataAlreadyLoaded(completion: { [weak self] result in
            switch result {
            case .success(let loaded):
                if loaded {
                    self?.fetch(forPostId: postId, completion: completion)
                } else {
                    self?.updateCache(forPostId: postId, completion: completion)
                }
            default:
                print("Warning: Ignore error")
            }
        })
    }
    
    private func fetch(forPostId: Int32, completion: @escaping (Result<(UserEntity, [CommentEntity]), Error>) -> Void ) {
        
        self.repository.fetchPost(withId: forPostId, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let postIDs):
                let posts = self.repository.map(PostItemEntity.self, array: postIDs)
                self.repository.fetchUser(userId: posts[0].userId, completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let userIDs):
                        let users = self.repository.map(UserEntity.self, array: userIDs)
                        self.repository.fetchComments(forPostId: forPostId, completion: { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let commentsIds):
                                let comments = self.repository.map(CommentEntity.self, array: commentsIds)
                                let final = (users[0], comments)
                                completion(.success(final))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        })
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    private func updateCache(forPostId: Int32, completion: @escaping (Result<(UserEntity, [CommentEntity]), Error>) -> Void ) {
        
        self.service.fetchUsers(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                self.service.fetchComments(completion: { [weak self] result in
                    switch result {
                    case .success(let comments):
                        self?.doCacheUpdate(forPostId: forPostId, completion, users, comments)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    private func doCacheUpdate(forPostId: Int32, _ completion: @escaping (Result<(UserEntity, [CommentEntity]), Error>) -> Void, _ users: [JSONEntity.User], _ comments: [JSONEntity.Comment] ) {
        
        repository.insertUserArray(JSONEntity.User.self, items: users, initWith: { context, item in
            let new = UserEntity(context: context)
            new.email = item.email
            new.id = Int32(item.id)
            new.name = item.name
            new.phone = item.phone
            new.username = item.username
            return new

        }, completion: { [weak self] result in
            
            switch result {
            case .success(let userIDs):
                guard let self = self else { return }
                self.repository.insertCommentArray(JSONEntity.Comment.self, items: comments, initWith: { context, item in
                    let new = CommentEntity(context: context)
                    new.postId = Int32(item.postId)
                    new.id = Int32(item.id)
                    new.email = item.email
                    new.name = item.name
                    new.body = item.body
                    return new
                }, completion: { result in
                    switch result {
                    case .success(let commentIDs):
                        self.fetch(forPostId: forPostId, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
