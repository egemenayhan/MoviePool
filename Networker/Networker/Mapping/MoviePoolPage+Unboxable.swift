//
//  MoviePoolPage+Unboxable.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 24.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Unbox

extension MoviePoolPage: Unboxable {
    
    public init(unboxer: Unboxer) throws {
        currentPage = try unboxer.unbox(key: "page")
        totalResults = try unboxer.unbox(key: "total_results")
        totalPage = try unboxer.unbox(key: "total_pages")
        movies = try unboxer.unbox(key: "results")
    }
    
}
