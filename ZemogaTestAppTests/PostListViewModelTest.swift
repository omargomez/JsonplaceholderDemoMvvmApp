//
//  PostListViewModelTest.swift
//  ZemogaTestAppTests
//
//  Created by Omar Eduardo Gomez Padilla on 7/20/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import XCTest
@testable import ZemogaTestApp

class PostListViewModelTest: XCTestCase {

    var sut: PostListViewModel!
    var service: JSONPlaceholderService!
    var repository: CacheRepository!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        service = JSONPlaceholderServiceImpl(decodableTask: StubDecodableTask())
        repository = CacheRepositoryImpl(stack: MockDataStack())
        let loadPostsUseCase = LoadPostsUseCaseImpl(repository: repository, service: service)
        let deletePostCase = DeletePostUseCaseImpl(aRepository: repository)
        sut = PostListViewModelImpl(useCase: loadPostsUseCase, deletePostCase: deletePostCase)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.sut = nil
    }

    func testLoadAllItems() {
        let exp = expectation(description: "Load all posts")
        
        self.sut.items.observe(on: self, observerBlock: { [weak self] modelItems in
            XCTAssert(modelItems.count > 0, "There should be some Items to load")
            exp.fulfill()
        })
        
        self.sut.loadPosts(loadAll: true)
        waitForExpectations(timeout: 3)
    }

    func testLoadStarred() {
        let exp = expectation(description: "Load all posts")
        
        self.sut.items.observe(on: self, observerBlock: { [weak self] modelItems in
            XCTAssert(modelItems.count > 0, "There should be some Items to load")
            exp.fulfill()
        })
        
        self.sut.loadPosts(loadAll: true)
        waitForExpectations(timeout: 3)
        self.sut.items.remove(observer: self)
        
        // All loaded ... let's star something
        let first = self.sut.items.value[0]
        let expStar = expectation(description: "Star Item")
        let startUC = UpdateStartUseCaseImpl(aRepository: repository)
        startUC.execute(postId: first.postId, starred: true, completion: { result in
            print("star result: \(result)")
            expStar.fulfill()
        })
        waitForExpectations(timeout: 3)
        
        let expLoadStarred = expectation(description: "Load starred")
        self.sut.items.observe(on: self, observerBlock: { [weak self] modelItems in
            XCTAssert(modelItems.count == 1, "There should be only one that's starred")
            expLoadStarred.fulfill()
        })

        self.sut.loadPosts(loadAll: false)
        waitForExpectations(timeout: 3)
    }

}
