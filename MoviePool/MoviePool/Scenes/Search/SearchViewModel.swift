//
//  SearchViewModel.swift
//  MoviePool
//
//  Created by EGEMEN AYHAN on 27.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Networker

struct SearchState {
    fileprivate(set) var page: MoviePoolPage?
    fileprivate(set) var results: [Movie] = []
    fileprivate(set) var suggestions: [String] = []
    fileprivate(set) var fetching = false
    
    enum Change {
        case resultsUpdated
        case fetchStateChanged
    }
    enum StateError {
        case resultNotFound
        case networkError(Error)
    }
}

class SearchViewModel: NSObject {
    
    let state = SearchState()
    var stateChangeHandler: ((SearchState.Change)->())?
    var errorHandler: ((SearchState.StateError)->())?
    
}
