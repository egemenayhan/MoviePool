//
//  SearchViewModel.swift
//  MoviePool
//
//  Created by EGEMEN AYHAN on 27.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Networker

struct SearchState {
    private(set) var page: MoviePoolPage?
    private(set) var results: [Movie] = []
    private(set) var fetching = false
    fileprivate(set) var activeKeyword: String? {
        didSet {
            if let keyword = activeKeyword {
                RecentSearchesManager.shared.addKeyword(keyword)
            }
        }
    }
    
    enum Change {
        case resultsUpdated
        case fetchStateChanged
    }
    
    enum StateError {
        case emptySearchKeyword
        case resultNotFound
        case networkError(Error)
    }
    
    mutating func updateFetchigState(fetching: Bool) -> Change {
        self.fetching = fetching
        
        return .fetchStateChanged
    }
    
    mutating func updatePage(page: MoviePoolPage, isNextPage: Bool) -> Change {
        self.page = page
        
        if isNextPage {
            results.append(contentsOf: page.movies)
        } else {
            results = page.movies
        }
        
        return .resultsUpdated
    }
    
    mutating func clearResults() -> Change {
        page = nil
        results = []
        
        return .resultsUpdated
    }
    
    func suggestions() -> [String] {
        return RecentSearchesManager.shared.recents
    }
    
}

class SearchViewModel: NSObject {
    
    fileprivate(set) var state = SearchState()
    var stateChangeHandler: ((SearchState.Change)->())?
    var errorHandler: ((SearchState.StateError)->())?
    
    func search(_ key: String) {
        
        if !(key.count > 0) {
            errorHandler?(.emptySearchKeyword)
            return
        }
        stateChangeHandler?(state.updateFetchigState(fetching: true))
        let request = SearchRequest(forPage: 1, keyword: key)
        NetworkManager.shared.execute(request) { [weak self] (result: Result<MoviePoolPage>) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let page):
                if page.totalResults > 0 {
                    strongSelf.state.activeKeyword = key
                    let change = strongSelf.state.updatePage(page: page, isNextPage: false)
                    strongSelf.stateChangeHandler?(change)
                } else {
                    strongSelf.errorHandler?(.resultNotFound)
                }
            case .failure(let error):
                strongSelf.errorHandler?(.networkError(error))
            }
            
            strongSelf.stateChangeHandler?(strongSelf.state.updateFetchigState(fetching: false))
        }
    }
    
    func fetchNextPage() {
        guard state.fetching == false,
            let nextPage = state.page?.nextPage(),
            let key = state.activeKeyword else { return }
        
        stateChangeHandler?(state.updateFetchigState(fetching: true))
        let request = SearchRequest(forPage: nextPage, keyword: key)
        NetworkManager.shared.execute(request) { [weak self] (result: Result<MoviePoolPage>) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let page):
                let change = strongSelf.state.updatePage(page: page, isNextPage: true)
                strongSelf.stateChangeHandler?(change)
            case .failure(let error):
                strongSelf.errorHandler?(.networkError(error))
            }
            
            strongSelf.stateChangeHandler?(strongSelf.state.updateFetchigState(fetching: false))
        }
    }
    
    func clearMovies() {
        stateChangeHandler?(state.clearResults())
    }
    
}
