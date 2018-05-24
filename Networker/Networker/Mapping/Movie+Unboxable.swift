//
//  Movie+Unboxable.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 24.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Unbox

extension Movie: Unboxable {
    
    public init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        title = try unboxer.unbox(key: "title")
        overview = try unboxer.unbox(key: "overview")
        posterPath = try unboxer.unbox(key: "poster_path")
        releaseDate = try unboxer.unbox(key: "release_date", formatter: Movie.dateFormatter())
    }
    
}
