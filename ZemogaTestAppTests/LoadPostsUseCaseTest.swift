//
//  LoadPostsUseCaseTest.swift
//  ZemogaTestAppTests
//
//  Created by Omar Eduardo Gomez Padilla on 7/19/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import XCTest
@testable import ZemogaTestApp

class LoadPostsUseCaseTest: XCTestCase {

    var service: JSONPlaceholderService!
    var repository: CacheRepository!
    var sut: LoadPostsUseCase!
    
    override func setUp() {
        self.service = JSONPlaceholderServiceImpl(decodableTask: StubDecodableTask())
        self.repository = CacheRepositoryImpl(stack: MockDataStack())
        self.sut = LoadPostsUseCaseImpl(repository: repository, service: service)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let exp = expectation(description: "Calling execute")
        
        sut.execute(completion: {result in
            switch result {
            case .success(let entities):
                XCTAssert(entities.count > 0)
            case .failure:
                XCTFail()
            }
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3)
        
        // cache must be full
        let expCache = expectation(description: "Calling cache")
        
        repository.fetchAllPosts(completion: { result in
            switch result {
            case .success(let idArray):
                XCTAssertTrue(idArray.count > 0)
            case .failure:
                XCTFail()
            }
            expCache.fulfill()
        })
        
        waitForExpectations(timeout: 3)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
