//
//  PostsListViewModel.swift
//  ZemogaTestApp
//
//  Created by Omar Eduardo Gomez Padilla on 7/19/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation

// TODO: Slipt?
struct PostListItemViewModel {
    let title: String
    let readed: Bool
    let starred: Bool
    let postId: Int32
    let body: String
    
    init(aTitle: String, isReaded: Bool, anId: Int32, isStarred: Bool, aDescription: String) {
        self.title = aTitle
        self.readed = isReaded
        self.postId = anId
        self.starred = isStarred
        self.body = aDescription
    }
}

protocol PostListViewModel {
    
    var items: Observable<[PostListItemViewModel]> { get }
    var errorMessage: Observable<String> { get }
    var starredOnly: Observable<Bool> { get }
    var waiting: Observable<Bool> { get }

    func loadPosts(loadAll: Bool)
    func deletePost(postId: Int32)
    func deleteAll()
}

class PostListViewModelImpl: PostListViewModel {
    
    let loadPostCase: LoadPostsUseCase
    let deletePostCase: DeletePostUseCase
    let deleteAllCase: DeleteAllUseCase
    var items: Observable<[PostListItemViewModel]>
    var errorMessage: Observable<String>
    var starredOnly: Observable<Bool>
    var waiting: Observable<Bool>

    var removed = false // Kind of a Hack
    
    init(useCase: LoadPostsUseCase = LoadPostsUseCaseImpl(), deletePostCase: DeletePostUseCase = DeletePostUseCaseImpl(), deleteAllCase: DeleteAllUseCase = DeleteAllUseCaseImpl() ) {
        self.loadPostCase = useCase
        self.deletePostCase = deletePostCase
        self.deleteAllCase = deleteAllCase
        self.items = Observable<[PostListItemViewModel]>([])
        self.errorMessage = Observable<String>("")
        self.starredOnly = Observable<Bool>(false)
        self.waiting = Observable<Bool>(false)

        self.starredOnly.observe(on: self, observerBlock: { [weak self] value in
            self?.loadPosts(loadAll: !value)
        })
    }
    
    func loadPosts(loadAll: Bool = true) {
        guard !self.removed else {
            self.items.value = []
            return
        }
        self.waiting.value = true
        self.loadPostCase.execute(completion: { result in
            defer {
                self.waiting.value = false
            }
            switch result {
            case .success(let entities):
                let all: [PostListItemViewModel] = entities.map { PostListItemViewModel(entity: $0) }
                if loadAll {
                    self.items.value = all
                } else {
                    self.items.value = all.filter { $0.starred }
                }
            case .failure(let error):
                self.errorMessage.value = error.localizedDescription
            }
        })
    }

    func deletePost(postId: Int32) {
        self.deletePostCase.execute(postId: postId) { [weak self] result in
            guard let self = self else { return }
            self.loadPosts(loadAll: !self.starredOnly.value)
        }
    }
    
    func deleteAll() {
        self.deleteAllCase.execute(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.removed = true
                self.loadPosts(loadAll: !self.starredOnly.value)
            case .failure(let error):
                print("Warning: \(error)")
            }
        })
    }
}

extension PostListItemViewModel {
    init(entity: PostItemEntity) {
        self.init(aTitle: entity.title ?? "", isReaded: entity.readed, anId: entity.id, isStarred: entity.starred, aDescription: entity.body ?? "")
    }
}
