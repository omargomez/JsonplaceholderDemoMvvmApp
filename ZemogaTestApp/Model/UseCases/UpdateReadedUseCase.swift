//
//  UpdateReadedUseCase.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

protocol UpdateReadedUseCase {
    func execute(postId: Int32)
}

class UpdateReadedUseCaseImpl: UpdateReadedUseCase {
    
    let repository: CacheRepository
    
    init(aRepository: CacheRepository = CacheRepositoryImpl()) {
        self.repository = aRepository
    }
    
    func execute(postId: Int32) {
        repository.update(postId: postId, asReaded: true, completion: { result in
            
        })
    }
}
