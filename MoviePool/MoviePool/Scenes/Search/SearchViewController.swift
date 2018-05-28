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
    fileprivate var shouldShowSuggestions = false {
        didSet {
            tableView.reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

}

private extension SearchViewController {
    
    struct Const {
        static let movieRowHeight: CGFloat = 112.0
        static let fetchingRowHeight: CGFloat = 50.0
        static let fetchingCellIdentifier = "fetchingCell"
        static let suggestionCellIdentifier = "suggestionCell"
    }
    
    func setupUI() {
        model.stateChangeHandler = handleStateChange
        model.errorHandler = handleError
        
        searchBar.placeholder = "Tap here to search a movie"
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func handleStateChange(change: SearchState.Change) {
        switch change {
        case .fetchStateChanged:
            tableView.reloadSections(IndexSet(integer: SearchSection.fetching.rawValue), with: .automatic)
        case .resultsUpdated:
            tableView.reloadData()
        }
    }
    
    func handleError(error: SearchState.StateError) {
        var errorMessage = ""
        
        switch error {
        case .emptySearchKeyword:
            errorMessage = "Invalid search keyword!"
        case .resultNotFound:
            errorMessage = "Sorry, we can`t find any movie in the pool"
            model.clearMovies()
        case .networkError(_):
            errorMessage = "Network error occured please try again later"
        }
        
        let alertVC = UIAlertController(title: "Oops!", message: errorMessage, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alertVC.addAction(dismissAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func startSearch(_ keyword: String?) {
        searchBar.resignFirstResponder()
        if let key = keyword?.trimmingCharacters(in: .whitespacesAndNewlines) {
            model.clearMovies()
            model.search(key)
            searchBar.text = key
        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        startSearch(searchBar.text)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSuggestions = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        shouldShowSuggestions = false
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    enum SearchSection:Int {
        static let count = 3
        
        case suggestions
        case movies
        case fetching
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SearchSection(rawValue: section) else { fatalError("Undefined section index!") }
        switch section {
        case .suggestions:
            if shouldShowSuggestions {
                return model.state.suggestions().count
            }
        case .movies:
            if !shouldShowSuggestions {
                return model.state.results.count
            }
        case .fetching:
            if !shouldShowSuggestions {
                if  model.state.fetching {
                    return 1
                }
                if let page = model.state.page, page.nextPage() != nil {
                    return 1
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .suggestions:
            let cell = tableView.dequeueReusableCell(withIdentifier: Const.suggestionCellIdentifier, for: indexPath)
            cell.textLabel?.text = model.state.suggestions()[indexPath.row]
            return cell
        case .movies:
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as! MovieTableViewCell
            cell.configure(with: model.state.results[indexPath.row])
            return cell
        case .fetching:
            let cell = tableView.dequeueReusableCell(withIdentifier: Const.fetchingCellIdentifier, for: indexPath)
            return cell
        }
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .fetching:
            model.fetchNextPage()
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .movies:
            return UITableViewAutomaticDimension
        case .suggestions:
            fallthrough
        case .fetching:
            return Const.fetchingRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .movies:
            return Const.movieRowHeight
        case .suggestions:
            fallthrough
        case .fetching:
            return Const.fetchingRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .suggestions:
            let keyword = model.state.suggestions()[indexPath.row]
            searchBar.text = keyword
            startSearch(keyword)
        default:
            return
        }
    }
    
}
