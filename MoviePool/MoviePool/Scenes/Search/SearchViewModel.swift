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
    private(set) var suggestions: [String] = []
    private(set) var fetching = false
    fileprivate(set) var activeKeyword: String?
    
    enum Change {
        case resultsUpdated
        case fetchStateChanged
    }
    
    enum StateError {
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
    
    mutating func updateResults(movies: [Movie]) -> Change {
        self.results = movies
        
        return .resultsUpdated
    }
    
}

class SearchViewModel: NSObject {
    
    fileprivate(set) var state = SearchState()
    var stateChangeHandler: ((SearchState.Change)->())?
    var errorHandler: ((SearchState.StateError)->())?
    
    func search(_ key: String) {
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
            case .failure(_):
                // TODO: handle error
                break
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
            case .failure(_):
                // TODO: handle error
                break
            }
            
            strongSelf.stateChangeHandler?(strongSelf.state.updateFetchigState(fetching: false))
        }
    }
    
    func clearMovies() {
        stateChangeHandler?(state.updateResults(movies: []))
    }
    
}
