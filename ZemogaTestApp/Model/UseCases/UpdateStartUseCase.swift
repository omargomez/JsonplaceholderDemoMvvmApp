//
//  UpdateStartUseCase.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

protocol UpdateStartUseCase {
    func execute(postId: Int32, starred: Bool, completion: @escaping (Result<PostItemEntity, Error>) -> Void )
}

class UpdateStartUseCaseImpl: UpdateStartUseCase {
    
    let repository: CacheRepository
    
    init(aRepository: CacheRepository = CacheRepositoryImpl()) {
        self.repository = aRepository
    }
    
    func execute(postId: Int32, starred: Bool, completion: @escaping (Result<PostItemEntity, Error>) -> Void ) {
        repository.update(postId: postId, asStarred: starred, completion: {  [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let objIDs):
                let entities = self.repository.map(PostItemEntity.self, array: objIDs)
                completion(.success(entities[0]))
            case .failure(let error):
                completion(.failure(error))
            }
            
        })
    }
}
