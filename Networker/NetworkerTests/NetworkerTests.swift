//
//  NetworkerTests.swift
//  NetworkerTests
//
//  Created by EGEMEN AYHAN on 22.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Networker

class NetworkerTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testSearchRequest() {
        let expect = expectation(description: "Search request test")
        setupTestStub(type: .search)
        let request = SearchRequest(forPage: 1, keyword: "Deadpool")
        NetworkManager.shared.execute(request) { (result: Result<MoviePoolPage>) in
            switch (result) {
            case .success(let page):
                XCTAssertEqual(1, page.currentPage, "Page current page is wrong. Expected: 1")
                XCTAssertEqual(3, page.movies.count, "Page movies count is wrong. Expected 3")
            case .failure(let error):
                XCTAssertNil(error, "Error occured! Reason: \(error.localizedDescription)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0) { (error: Error?) in
            print("Timeout Error: \(error.debugDescription)")
        }
    }
    
    func testMissingFieldsResponse() {
        let expect = expectation(description: "Missing movie fields test")
        setupTestStub(type: .missingMovieFields)
        // Request doesn`t matter because stub is important for us.
        let request = SearchRequest(forPage: 1, keyword: "Deadpool")
        NetworkManager.shared.execute(request) { (result: Result<MoviePoolPage>) in
            switch (result) {
            case .success(let page):
                XCTAssertEqual(1, page.currentPage, "Page current page is wrong. Expected: 1")
                XCTAssertEqual(1, page.movies.count, "Page movies count is wrong. Expected 1")
            case .failure(let error):
                XCTAssertNil(error, "Error occured! Reason: \(error.localizedDescription)")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0) { (error: Error?) in
            print("Timeout Error: \(error.debugDescription)")
        }
    }
    
    func testMappingFailResponse() {
        let expect = expectation(description: "Mapping fail test")
        setupTestStub(type: .mappingFail)
        // Request doesn`t matter because stub is important for us.
        let request = SearchRequest(forPage: 1, keyword: "Deadpool")
        NetworkManager.shared.execute(request) { (result: Result<MoviePoolPage>) in
            switch (result) {
            case .success(_):
                XCTFail("Should return error!")
            case .failure(let error):
                if let error = error as? NetworkManagerError {
                    switch error {
                    case .mappingFailed:
                        XCTAssert(true)
                    default:
                        XCTFail("Error should be mappingFailed")
                    }
                } else {
                    XCTFail("Error should be NetworkManagerError type")
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0) { (error: Error?) in
            print("Timeout Error: \(error.debugDescription)")
        }
    }
    
    func testCorruptedDataResponse() {
        let expect = expectation(description: "Corrupted data test")
        setupTestStub(type: .corrupted)
        // Request doesn`t matter because stub is important for us.
        let request = SearchRequest(forPage: 1, keyword: "Deadpool")
        NetworkManager.shared.execute(request) { (result: Result<MoviePoolPage>) in
            switch result {
            case .success(_):
                XCTFail("Should return error!")
            case .failure(let error):
                if let error = error as? NetworkManagerError {
                    switch (error) {
                    case .connectionError(_):
                        XCTAssert(true)
                    default:
                        XCTFail("Error should be connectionError case:\(error.localizedDescription)")
                    }
                } else {
                    XCTFail("Error should be NetworkManagerError type")
                }
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0) { (error: Error?) in
            print("Timeout Error: \(error.debugDescription)")
        }
    }
    
}

private extension NetworkerTests {
    
    enum TestStubType: String {
        case search = "Search"
        case missingMovieFields = "MissingMovieFields"
        case mappingFail = "MappingFail"
        case corrupted = "Corrupted"
    }
    
    func setupTestStub(type stubType: TestStubType) {
        stub(condition: isHost(BaseURL.host!)) { _ in
            let stubFilePath = stubType.rawValue + ".json"
            let stubPath = OHPathForFile(stubFilePath, type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
    }
    
}
