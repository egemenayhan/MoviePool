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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        OHHTTPStubs.removeAllStubs()
    }
    
    func testTopMoviesRequest() {
        setupRequestStub(type: .topMovies)
        let request = TopMoviesRequest(forPage: 1)
        NetworkManager.shared.execute(request) { (result: Result<MoviePoolPage>) in
            switch (result) {
            case .success(let page):
                XCTAssertEqual(1, page.currentPage, "MoviePoolPage current page is wrong. Should be '1'")
            case .failure(let error):
                XCTAssertNil(error, "Error occured! Reason: \(error.localizedDescription)")
            }
        }
    }
    
}

private extension NetworkerTests {
    
    enum RequestType: String {
        case topMovies = "TopMovies"
        case search = "Search"
    }
    
    func setupRequestStub(type requestType: RequestType) {
        stub(condition: isHost(BaseURL.host!)) { _ in
            let stubFilePath = requestType.rawValue + ".json"
            let stubPath = OHPathForFile(stubFilePath, type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
    }
    
}
