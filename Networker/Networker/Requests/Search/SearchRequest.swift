//
//  SearchRequest.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 25.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

public struct SearchRequest: Request {
    
    public var method: HTTPMethod = .get
    public var path: String = "/search/movie"
    public var parameters: [String : Any]
    
    public init(forPage page: Int, keyword: String) {
        self.parameters =  ["page": page,
                            "query": keyword]
    }
    
}
