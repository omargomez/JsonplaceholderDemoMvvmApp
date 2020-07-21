//
//  DeletePostUseCase.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

protocol DeletePostUseCase {
    func execute(postId: Int32, completion: @escaping (Result<Void, Error>) -> Void )
}

class DeletePostUseCaseImpl: DeletePostUseCase {
    let repository: CacheRepository
    
    init(aRepository: CacheRepository = CacheRepositoryImpl()) {
        self.repository = aRepository
    }
    
    func execute(postId: Int32, completion: @escaping (Result<Void, Error>) -> Void ) {
        repository.delete(postId: postId, completion: { result in
            completion(result)
        })
    }
}
