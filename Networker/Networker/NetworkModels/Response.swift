//
//  Response.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 23.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

public struct RawResponse {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let error: Error?
}

// MARK: - Response

public protocol Response: RawDataMappable { }

// MARK: - Mappable

public protocol RawDataMappable {
    init(jsonDict: [String: Any]) throws
}
