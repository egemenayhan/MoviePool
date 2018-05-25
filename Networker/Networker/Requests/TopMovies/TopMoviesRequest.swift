//
//  FetchPageRequest.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 24.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

public struct TopMoviesRequest: Request {
    
    public var method: HTTPMethod = .get
    public var path: String = "/movie/top_rated"
    public var parameters: [String : Any]
    
    public init(forPage page: Int) {
        self.parameters =  ["page": page]
    }
    
}
