//
//  Movie.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 23.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

public struct Movie {
    
    var id: Int
    var title: String
    var posterPath: String
    var overview: String
    var releaseDate: Date
    
    // Helper
    static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }
    
}
    
extension Movie: Equatable {
    
    public static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id // IDs are assumed unique
    }
    
}
