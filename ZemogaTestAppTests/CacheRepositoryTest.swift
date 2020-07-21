//
//  CacheRepositoryTest.swift
//  ZemogaTestAppTests
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import XCTest
@testable import ZemogaTestApp

class CacheRepositoryTest: XCTestCase {

    var sut: CacheRepository!
    
    override func setUp() {
        sut = CacheRepositoryImpl(stack: MockDataStack())
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInsertOne() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let exp = expectation(description: "Calling insert")
        
        sut.insertPost({ context in
            let result = PostItemEntity(context: context)
            result.id = 1
            result.userId = 2
            result.title = "Some Tiple"
            result.body = "Some body"
            return result
        }, completion: { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 3)
        let expfetch = expectation(description: "Calling posts")
        
        sut.fetchAllPosts(completion: { [weak self] result in
            switch result {
            case .success(let idArray):
                XCTAssertTrue(idArray.count > 0)
                guard let post = self?.sut.instance(PostItemEntity.self, from: idArray[0]) else {
                    XCTFail()
                    return
                }
                XCTAssertTrue(post.userId == 2)
            case .failure:
                XCTFail()
            }
            expfetch.fulfill()
        })
        
        wait(for: [expfetch], timeout: 3)
    }

    func testInserMany() {
        let exp = expectation(description: "Calling insert")
        
        let jsonItems = JSONDummies.posts
        
        sut.insertPostArray(JSONEntity.PostItem.self, items: jsonItems, initWith: { context, item in
            let new = PostItemEntity(context: context)
            new.body = item.body
            new.id = Int32(item.id)
            new.starred = false
            new.title = item.title
            new.userId = Int32(item.userId)
            return new
        }, completion: { result in
            switch result {
            case .success(let objIDs):
                XCTAssert(objIDs.count > 0)
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 3)
    }

    func testInserManyUser() {
        let exp = expectation(description: "Calling insert")
        
        let jsonItems = JSONDummies.users
        
        sut.insertUserArray(JSONEntity.User.self, items: jsonItems, initWith: { context, item in
            let new = UserEntity(context: context)
            new.email = item.email
            new.id = Int32(item.id)
            new.name = item.name
            new.phone = item.phone
            new.username = item.username
            return new
        }, completion: { result in
            switch result {
            case .success(let objIDs):
                XCTAssert(objIDs.count > 0)
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 3)
    }
    
    func testInserManyComments() {
        let exp = expectation(description: "Calling insert")
        
        let jsonItems = JSONDummies.comments
        
        sut.insertCommentArray(JSONEntity.Comment.self, items: jsonItems, initWith: { context, item in
            let new = CommentEntity(context: context)
            new.body = item.body
            new.email = item.email
            new.id = Int32(item.id)
            new.name = item.name
            new.postId = Int32(item.postId)
            return new
        }, completion: { result in
            switch result {
            case .success(let objIDs):
                XCTAssert(objIDs.count > 0)
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 3)
    }

}
