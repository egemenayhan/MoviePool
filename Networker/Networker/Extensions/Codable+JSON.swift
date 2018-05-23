//
//  Codable+JSON.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 23.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

public extension Decodable where Self: Codable {
    
    static var decoder: JSONDecoder { return JSONDecoder() }
    
    init?(jsonData: Data?) {
        guard let data = jsonData, let decodedInstance = try? Self.decoder.decode(Self.self, from: data) else {
            return nil
        }
        self = decodedInstance
    }
    
}

public extension Encodable where Self: Codable {
    
    static var encoder: JSONEncoder { return JSONEncoder() }
    
    func jsonData() -> Data? {
        return try? Self.encoder.encode(self)
    }
    
}
