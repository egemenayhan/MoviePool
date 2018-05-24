//
//  TopMoviesResponse.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 24.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Unbox

public struct PaginatedResponse: Response {
    
    public let page: MoviePoolPage
    
    public init(jsonDict: [String : Any]) throws {
        page = try unbox(dictionary: jsonDict)
    }
    
}
