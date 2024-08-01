//
//  BookmarkedArticleController.swift
//  SelectiveNews
//
//  Created by Arshif on 16/07/2024.
//

import UIKit

class BookmarkedArticleController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var bookmarkViewModel = BookmarkedArticleViewModel()
    private var articles = [Article]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        articles = []
        setupView()
        setupViewModel()
        
    }
    
    private func setupViewModel() {
        
        bookmarkViewModel.onLoadArticles = { articles in
            self.articles.append(contentsOf: articles)
        }
        
        bookmarkViewModel.onResettingArticles = {
            self.articles = []
        }
        
        bookmarkViewModel.loadArticles()
        
    }
    private func setupView() {
        title = "BookMarks"
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkedArticleCell", for: indexPath) as! BookmarkedArticleCell
        let article = articles[indexPath.row]
        cell.textLabel?.text = article.title
        return cell
        
    }
    
}

