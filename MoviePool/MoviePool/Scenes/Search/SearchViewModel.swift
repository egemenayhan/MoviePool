//
//  SearchViewModel.swift
//  MoviePool
//
//  Created by EGEMEN AYHAN on 27.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import Networker

// MARK: - State
struct SearchState {
    
    private var recentManager = RecentSearchesManager()
    private(set) var page: MoviePoolPage?
    private(set) var results: [Movie] = []
    private(set) var fetching = false
    var suggestions: [String] {
        return recentManager.recents
    }
    fileprivate(set) var activeKeyword: String? {
        didSet {
            if let keyword = activeKeyword {
                recentManager.addKeyword(keyword)
            }
        }
    }
    
    // changes are the states that view controller should handle. (kind of interface)
    enum Change {
        case resultsUpdated
        case nextPageFetched([IndexPath])
        case showLoading(Bool)
    }
    // possible error handlings
    enum StateError {
        case emptySearchKeyword
        case resultNotFound
        case networkError(Error)
    }
    
    // mutating functions updates state and returns change for informing view controller
    mutating func updateFetchigState(fetching: Bool) -> Change {
        self.fetching = fetching
        
        return .showLoading(fetching)
    }
    
    mutating func updatePage(page: MoviePoolPage, isNextPage: Bool) -> Change {
        let totalResult = results.count + page.movies.count
        if isNextPage {
            var indexPaths: [IndexPath] = []
            for index in results.count..<totalResult {
                indexPaths.append(IndexPath(row: index, section: SearchViewController.SearchSection.movies.rawValue))
            }
            self.page = page
            results.append(contentsOf: page.movies)
            
            return .nextPageFetched(indexPaths)
        } else {
            self.page = page
            results = page.movies
            
            return .resultsUpdated
        }
    }
    
    mutating func clearResults() -> Change {
        page = nil
        results = []
        
        return .resultsUpdated
    }
    
}

// MARK: - View Model
class SearchViewModel: NSObject {
    
    private(set) var state = SearchState()
    // handlers are used for update view controller about changes and errors on view model
    var stateChangeHandler: ((SearchState.Change)->())?
    var errorHandler: ((SearchState.StateError)->())?
    
    // used on fetching new search key data
    func search(_ key: String) {
        if !(key.count > 0) {
            errorHandler?(.emptySearchKeyword)
            stateChangeHandler?(state.clearResults())
            return
        }
        
        stateChangeHandler?(state.updateFetchigState(fetching: true))
        stateChangeHandler?(state.clearResults())
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
    
    // fetches next page on scrolling to page end
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
    
}
