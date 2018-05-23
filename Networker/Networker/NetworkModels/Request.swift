//
//  Request.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 22.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Alamofire

private let BaseURL = URL(string: "https://api.themoviedb.org/3")!
private let APIKey = "2696829a81b1b5827d515ff121700838"

protocol Request: URLRequestConvertible {
    var method: HTTPMethod              { get }
    var path: String                    { get }
    var parameters: [String: Any]       { get }
}

extension Request {
    
    var method: HTTPMethod              { return .get }
    var parameters: [String: Any]       { return [:] }
    
    func asURLRequest() throws -> URLRequest {
        let url = BaseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                fatalError("API URL can not be resolved.")
        }
        
        let apiKeyQueryItem = URLQueryItem(name: "api_key", value: APIKey)
        var queryItems = components.queryItems ?? []
        queryItems.append(apiKeyQueryItem)
        components.queryItems = queryItems
        guard let queriedURL = components.url else {
            fatalError("URL can not be constructed from URL components.")
        }
        do {
            var request = URLRequest(url: queriedURL)
            request.httpMethod = method.rawValue
            return try URLEncoding.methodDependent.encode(request, with: parameters)
        } catch {
            // TODO: Error handling
            throw error
        }
    }
    
}
