//
//  SearchViewController.swift
//  MoviePool
//
//  Created by EGEMEN AYHAN on 27.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    fileprivate(set) var searchBar = UISearchBar()
    fileprivate let model = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

}

private extension SearchViewController {
    
    func setupUI() {
        model.stateChangeHandler = handleStateChange
        model.errorHandler = handleError
        
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
    }
    
    func handleStateChange(change: SearchState.Change) {
        
    }
    
    func handleError(error: SearchState.StateError) {
        
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    enum SearchSection:Int {
        static let count = 2
        
        case movies
        case fetching
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SearchSection(rawValue: section) else { fatalError("Undefined section index!") }
        switch section {
        case .movies:
            return model.state.results.count
        case .fetching:
            return model.state.fetching ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
