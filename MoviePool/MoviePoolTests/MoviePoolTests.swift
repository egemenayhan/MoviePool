//
//  MoviePoolTests.swift
//  MoviePoolTests
//
//  Created by EGEMEN AYHAN on 22.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Networker
@testable import MoviePool

class MoviePoolTests: XCTestCase {
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testSearch() {
        let expect = expectation(description: "Search test")
        setupTestStub(type: .search)
        let model = SearchViewModel()
        model.stateChangeHandler = { (change: SearchState.Change) in
            switch change {
            case .resultsUpdated:
                if let page = model.state.page {
                    XCTAssertEqual(1, page.currentPage, "Current page is wrong. Expected: 1")
                    XCTAssertEqual(3, page.movies.count, "Movie count is wrong. Expected: 3")
                    expect.fulfill()
                }
            default:
                return
            }
        }
        model.search("deadpool")
        waitForExpectations(timeout: 5.0) { (error: Error?) in
            print("Timeout Error: \(error.debugDescription)")
        }
    }
    
}

private extension MoviePoolTests {
    
    enum TestStubType: String {
        case search = "Search"
    }
    
    func setupTestStub(type stubType: TestStubType) {
        stub(condition: isHost(Networker.BaseURL.host!)) { _ in
            let stubFilePath = stubType.rawValue + ".json"
            let stubPath = OHPathForFile(stubFilePath, type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
    }
    
}
