//
//  MoviePoolPage.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 24.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Unbox

public struct MoviePoolPage {
    
    public var currentPage: Int = 0
    public var totalResults: Int = 0
    public var totalPage: Int = 0
    public var movies: [Movie] = []
    
    mutating func nextPage() -> Int? {
        return currentPage < totalPage ? (currentPage + 1) : nil
    }
    
}

extension MoviePoolPage: Unboxable {
    
    public init(unboxer: Unboxer) throws {
        currentPage = try unboxer.unbox(key: "page")
        totalResults = try unboxer.unbox(key: "total_results")
        totalPage = try unboxer.unbox(key: "total_pages")
        movies = try unboxer.unbox(key: "results", allowInvalidElements: true)
    }
    
}
