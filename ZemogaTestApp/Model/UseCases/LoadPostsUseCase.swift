//
//  LoadPostsUseCase.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

protocol LoadPostsUseCase {
    
    func execute(completion: @escaping (Result<[PostItemEntity], Error>) -> Void)
    
}

class LoadPostsUseCaseImpl: LoadPostsUseCase {
    
    let repository: CacheRepository
    let service: JSONPlaceholderService
    
    init(repository: CacheRepository = CacheRepositoryImpl(), service: JSONPlaceholderService = JSONPlaceholderServiceImpl() ) {
        self.repository = repository
        self.service = service
    }
    
    func execute(completion: @escaping (Result<[PostItemEntity], Error>) -> Void) {
        
        repository.fetchAllPosts(completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let objects):
                if objects.count < 1 {
                    // load from service and update
                    self.service.fetchPosts(completion: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success(let jsonItems):
                            self.repository.insertPostArray(JSONEntity.PostItem.self, items: jsonItems, initWith: { context, item in
                                //TODO: convenience init
                                let new = PostItemEntity(context: context)
                                new.body = item.body
                                new.id = Int32(item.id)
                                new.starred = false
                                new.title = item.title
                                new.userId = Int32(item.userId)
                                new.readed = item.id > 20
                                return new
                            }, completion: { [weak self] result in
                                guard let self = self else { return }
                                switch result {
                                case .success(let idArray):
                                    let entities = self.repository.map(PostItemEntity.self, array: idArray).sorted { $0.id < $1.id }
                                    print("Use Case/ Newentities: \( entities.compactMap { ($0.id, $0.readed) } )")
                                    completion(.success(entities))
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            })
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    })
                } else {
                    let result: [PostItemEntity] = self.repository.map(PostItemEntity.self, array: objects).sorted { $0.id < $1.id }
                    completion(.success(result))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })

    }
}
