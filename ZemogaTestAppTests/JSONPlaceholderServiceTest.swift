//
//  JSONPlaceholderServiceTest.swift
//  ZemogaTestAppTests
//
//  Created by Omar Eduardo Gomez Padilla on 7/18/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import XCTest
@testable import ZemogaTestApp

class JSONPlaceholderServiceTest: XCTestCase {

    var sut: JSONPlaceholderService!
    
    override func setUp() {
        sut = JSONPlaceholderServiceImpl(decodableTask: StubDecodableTask())
    }

    override func tearDown() {
    }

    func testFetchPosts() {
        
        let exp = expectation(description: "Calling posts")
        
        sut?.fetchPosts(completion: {result in
            switch result {
            case .success(let posts):
                XCTAssert(posts.count > 0)
                XCTAssertEqual(posts, JSONDummies.posts, "Result should be the same as dummy")
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3)
        
    }
    
    func testFetchUsers() {
        
        let exp = expectation(description: "Calling users")
        
        sut?.fetchUsers(completion: {result in
            switch result {
            case .success(let users):
                XCTAssert(users.count > 0)
                XCTAssertEqual(users, JSONDummies.users, "Result should be the same as dummy")
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3)
        
    }
    
    func testFetchComments() {
        
        let exp = expectation(description: "Calling comments")
        
        sut?.fetchComments(completion: {result in
            switch result {
            case .success(let comments):
                XCTAssert(comments.count > 0)
                XCTAssertEqual(comments, JSONDummies.comments, "Result should be the same as dummy")
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3)
        
    }
    

}
