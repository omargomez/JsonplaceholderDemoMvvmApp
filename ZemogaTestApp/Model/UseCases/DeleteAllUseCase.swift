//
//  DeleteAllUseCase.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

protocol DeleteAllUseCase {
    func execute(completion: @escaping (Result<Void, Error>) -> Void)
}

class DeleteAllUseCaseImpl: DeleteAllUseCase {
    let repository: CacheRepository
    
    init(aRepository: CacheRepository = CacheRepositoryImpl()) {
        self.repository = aRepository
    }
    
    func execute(completion: @escaping (Result<Void, Error>) -> Void) {
        repository.deleteAll(completion: { result in
            completion(result)
        })
    }
}
