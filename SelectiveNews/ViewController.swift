//
//  ViewController.swift
//  SelectiveNews
//
//  Created by Arshif on 26/06/2024.
//

import UIKit

struct UserDefaultsKey {
    static let bookMarkedIds = "articleId"
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    
    private var bookmarkedIds = Set<String>()
    
    private var viewModel = ArticlesViewModel()
    
    private var articles = [Article]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
        if let ids = UserDefaults.standard.stringArray(forKey: UserDefaultsKey.bookMarkedIds) {
            bookmarkedIds = Set(ids)
        }
    }
    
    private func setupView() {
        title = "News"
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    private func setupViewModel() {
        
        viewModel.shouldShowLoadingIndicator = { shouldShow in
            shouldShow ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
        }
        
        viewModel.onLoadArticles = { articles in
            self.articles.append(contentsOf: articles)
        }
        
        viewModel.onResettingArticles = {
            self.articles = []
        }
        
        viewModel.loadArticles()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        let article = articles[indexPath.row]
        cell.article = article
        cell.isBookMarked = isArticleBookMarked(for: article)
        
        
        cell.shouldBookMark = { shouldBookMark in
            shouldBookMark ? self.addToBookMarks(article: article) : self.removeArticleFromBookMarks(article: article)
        }
       
        return cell
    }
    
    private func addToBookMarks(article: Article) {
        bookmarkedIds.insert(article.article_id)
        resetBookMarkedIds(with: bookmarkedIds)
    }
    
    private func removeArticleFromBookMarks(article: Article) {
        bookmarkedIds.remove(article.article_id)
        resetBookMarkedIds(with: bookmarkedIds)
    }
    
    private func isArticleBookMarked(for article: Article) -> Bool {
        bookmarkedIds.contains(article.article_id)
    }
    
    private func resetBookMarkedIds(with ids: Set<String>) {
        UserDefaults.standard.set(Array(ids), forKey: UserDefaultsKey.bookMarkedIds)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            viewModel.loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        print(article.article_id)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchArticles(with: searchText)
    }
}
