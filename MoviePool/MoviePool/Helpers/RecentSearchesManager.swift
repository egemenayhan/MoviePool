//
//  RecentSearchesManager.swift
//  MoviePool
//
//  Created by EGEMEN AYHAN on 28.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import UIKit

class RecentSearchesManager: NSObject {
    
    private enum Const {
        static let recentCount = 10
        static let recentKey = "RecentSearches"
    }
    
    static let shared = RecentSearchesManager()
    private(set) var recents: [String] = []
    
    override init() {
        super.init()
        
        if let recents = UserDefaults.standard.stringArray(forKey: Const.recentKey) {
            self.recents = recents
        }
    }
    
    func addKeyword(_ keyword: String) {
        if let index = recents.index(of: keyword) {
            recents.remove(at: index)
        }
        
        recents.insert(keyword, at: 0)
        
        if recents.count > Const.recentCount {
            recents.removeLast()
        }
        
        UserDefaults.standard.set(recents, forKey: Const.recentKey)
        UserDefaults.standard.synchronize()
    }
    
}
