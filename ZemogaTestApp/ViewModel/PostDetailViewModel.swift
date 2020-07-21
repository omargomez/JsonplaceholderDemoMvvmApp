//
//  PostDetailViewModel.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

struct UserViewModel {
    let name: String
    let email: String
    let phone: String
    
    init(aName: String, anEmail: String, aPhone: String) {
        self.name = aName
        self.email = anEmail
        self.phone = aPhone
    }
}

struct CommentViewModel {
    let body: String
    
    init(aBody: String) {
        self.body = aBody
    }
}

protocol PostDetailViewModel {
    
    var postModel: PostListItemViewModel { get }
    var starred: Observable<Bool> { get }
    var user: Observable<UserViewModel?> { get }
    var comments: Observable<[CommentViewModel]?> { get }
    var waiting: Observable<Bool> { get }
    var errorMessage: Observable<String> { get }
    
    func updateAsReaded()
    func loadData()
}

class PostDetailViewModelImpl: PostDetailViewModel {
    
    let postModel: PostListItemViewModel
    var starred: Observable<Bool>
    var user: Observable<UserViewModel?>
    var errorMessage: Observable<String>
    var comments: Observable<[CommentViewModel]?>
    let updateReadedUseCase: UpdateReadedUseCase
    let updateStarUseCase: UpdateStartUseCase
    let loadAdditonalDataUseCase: LoadAdditionalPostDataUseCase
    var waiting: Observable<Bool>
    
    init(forPost: PostListItemViewModel, updateUseCase: UpdateReadedUseCase = UpdateReadedUseCaseImpl(),
         updateStarUseCase: UpdateStartUseCase = UpdateStartUseCaseImpl(),
         loadAdditonalDataUseCase: LoadAdditionalPostDataUseCase = LoadAdditionalPostDataUseCaseImpl()) {
        self.postModel = forPost
        self.updateReadedUseCase = updateUseCase
        self.updateStarUseCase = updateStarUseCase
        self.loadAdditonalDataUseCase = loadAdditonalDataUseCase
        self.starred = Observable<Bool>(postModel.starred)
        self.user = Observable<UserViewModel?>(nil)
        self.comments = Observable<[CommentViewModel]?>(nil)
        self.waiting = Observable<Bool>(false)
        self.errorMessage = Observable<String>("")
        
        self.starred.observe(on: self, observerBlock: { [weak self] value in
            guard let self = self else { return }
            self.updateStarUseCase.execute(postId: self.postModel.postId, starred: value, completion: { result in
                
            })
        })
    }
    
    func updateAsReaded() {
        // Update record on respository
        updateReadedUseCase.execute(postId: self.postModel.postId)
    }
    
    func loadData() {
        self.waiting.value = true
        loadAdditonalDataUseCase.execute(postId: self.postModel.postId, completion: { [weak self] result in
            guard let self = self else { return }
            defer {
                self.waiting.value = false
            }
            switch result {
            case .success(let data):
                self.user.value = UserViewModel(data.0)
                self.comments.value = data.1.map { CommentViewModel($0) }
            case .failure(let error):
                self.errorMessage.value = error.localizedDescription
            }
        })
    }
}

extension UserViewModel {
    init(_ entity: UserEntity) {
        self.init(aName: entity.name ?? "", anEmail: entity.email ?? "", aPhone: entity.phone ?? "")
    }
}

extension CommentViewModel {
    init(_ entity: CommentEntity) {
        self.init(aBody: entity.body ?? "")
    }
}

