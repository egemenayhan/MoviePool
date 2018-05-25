//
//  Movie.swift
//  Networker
//
//  Created by EGEMEN AYHAN on 23.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Unbox

public struct Movie {
    
    public var id: Int
    public var title: String = "No Title"
    public var overview: String?
    public var releaseDate: Date?
    fileprivate(set) var posterPath: String?
    
    private let BaseImagePath = "http://image.tmdb.org/t/p"
    
    // Helper
    static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }
    
}

extension Movie: Unboxable {
    
    public init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(key: "id")
        title = try unboxer.unbox(key: "title")
        overview = unboxer.unbox(key: "overview")
        posterPath = unboxer.unbox(key: "poster_path")
        releaseDate = unboxer.unbox(key: "release_date", formatter: Movie.dateFormatter())
    }
    
}

extension Movie {
    
    public enum ImageSize: String {
        case w92 = "/w92"
        case w185 = "/w185"
        case w500 = "/w500"
        case w780 = "/w780"
    }
    
    public func imageURL(forSize size:ImageSize) -> URL? {
        guard let posterPath = self.posterPath else { return nil }
        return URL(string: BaseImagePath + size.rawValue + posterPath)
    }
    
}
