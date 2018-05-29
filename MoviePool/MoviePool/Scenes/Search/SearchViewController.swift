//
//  SearchViewController.swift
//  MoviePool
//
//  Created by EGEMEN AYHAN on 27.05.2018.
//  Copyright © 2018 EGEMEN AYHAN. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    // MARK: - Properties
    private var searchBar = UISearchBar()
    private let model = SearchViewModel()
    private var loadingView: UIView!
    private var shouldShowSuggestions = false {
        didSet {
            tableView.reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.center = tableView.center
    }

}

private extension SearchViewController {
    
    struct Const {
        static let movieRowHeight: CGFloat = 112.0
        static let suggestionRowHeight: CGFloat = 50.0
        static let fetchingCellIdentifier = "fetchingCell"
        static let suggestionCellIdentifier = "suggestionCell"
    }
    
    // basic initializations for viewDidLoad
    func setupUI() {
        model.stateChangeHandler = handleStateChange
        model.errorHandler = handleError
        
        searchBar.placeholder = "Tap here to search a movie"
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        tableView.tableFooterView = UIView(frame: .zero)
        
        setupLoadingView()
    }
    
    // handling model state changes
    func handleStateChange(change: SearchState.Change) {
        switch change {
        case .showLoading(let show):
            loadingView.isHidden = !show
        case .nextPageFetched(let indexPaths):
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: .none)
            tableView.endUpdates()
        case .resultsUpdated:
            tableView.reloadData()
        }
    }
    
    // handling model errors
    func handleError(error: SearchState.StateError) {
        var errorMessage = ""
        
        switch error {
        case .emptySearchKeyword:
            errorMessage = "Invalid search keyword!"
        case .resultNotFound:
            errorMessage = "Sorry, we can`t find any movie in the pool"
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
            model.search(key)
            searchBar.text = key
        }
    }
    
    func setupLoadingView() {
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        loadingView.layer.cornerRadius = 10
        loadingView.layer.masksToBounds = true
        loadingView.isHidden = true
        view.addSubview(loadingView)
        
        let activity = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activity.startAnimating()
        activity.activityIndicatorViewStyle = .whiteLarge
        loadingView.addSubview(activity)
    }
    
}

// MARK: - UISearchBarDelegate
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

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    enum SearchSection:Int {
        case suggestions
        case movies
        
        static let count = 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SearchSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SearchSection(rawValue: section) else { fatalError("Undefined section index!") }
        switch section {
        case .suggestions:
            if shouldShowSuggestions {
                return model.state.suggestions.count
            }
        case .movies:
            if !shouldShowSuggestions {
                return model.state.results.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .suggestions:
            let cell = tableView.dequeueReusableCell(withIdentifier: Const.suggestionCellIdentifier, for: indexPath)
            cell.textLabel?.text = model.state.suggestions[indexPath.row]
            return cell
        case .movies:
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier, for: indexPath) as! MovieTableViewCell
            cell.configure(with: model.state.results[indexPath.row])
            return cell
        }
    }
    
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .movies:
            if indexPath.row == (model.state.results.count - 1) {
                model.fetchNextPage()
            }
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
            return Const.suggestionRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .movies:
            return Const.movieRowHeight
        case .suggestions:
            return Const.suggestionRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SearchSection(rawValue: indexPath.section) else { fatalError("Undefined section index!") }
        switch section {
        case .suggestions:
            let keyword = model.state.suggestions[indexPath.row]
            searchBar.text = keyword
            startSearch(keyword)
        default:
            return
        }
    }
    
}
