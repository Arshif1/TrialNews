//
//  ArticlesViewModel.swift
//  SelectiveNews
//
//  Created by Arshif on 26/06/2024.
//

import Foundation

class ArticlesViewModel {
        
    private var urlString: String {
//        pub_457050f3022a220f2fee7f26b7bedf2ce8912
        var baseurl = "https://newsdata.io/api/1/latest?apikey=pub_4740411c97d4533dc0cb60e4f09dc5df81264&language=en"
        
        if let nextPage, !nextPage.isEmpty {
            baseurl += "&page=\(nextPage)"
        }
        
        if let searchText, !searchText.isEmpty {
            baseurl += "&q=\(searchText)"
        }

        return baseurl
    }
    
    var isloading = false
    var shouldShowLoadingIndicator: ((Bool) -> Void)?
    var onLoadArticles: (([Article]) -> Void)?
    var onResettingArticles: (() -> Void)?
    
    private var searchText: String?
    private var nextPage: String?
    
    typealias ArticleResult = (articles: [Article], nextPage: String?)
    
    var task: Task<ArticleResult, Error>?
    
    func loadArticles() {
        reset()
        fetchAndHandleArticles()
    }
    
    func searchArticles(with searchText: String?) {
        reset()
        self.searchText = searchText
        fetchAndHandleArticles()
    }
    
    func loadMore() {
        fetchAndHandleArticles()
    }
    
    private func reset() {
        
        isloading = false
        nextPage = nil
        self.searchText = nil
        task?.cancel()
        task = nil
        onResettingArticles?()
        shouldShowLoadingIndicator?(true)
    }
    
    private func fetchAndHandleArticles() {
        guard !isloading else { return }
        isloading = true
        setupTask()
        guard let task else { return }
        Task {
            do {
                let values = try await task.value
                await MainActor.run {
                    handleSuccess(result: values)
                }
            } catch {
                await MainActor.run {
                    handleFailure(error: error)
                }
            }
        }
    }
    
    private func setupTask() {
        task = Task {
            let json = try await fetchJSONResponse()
            return (json.results.compactMap(transform), json.nextPage)
        }
    }
    
    private func fetchJSONResponse() async throws -> ArticleResults {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "invalid url", code: 0)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let articleResult = try JSONDecoder().decode(ArticleResults.self, from: data)
        return articleResult
    }
    
    private func handleSuccess(result: ArticleResult) {
        nextPage = result.nextPage
        onLoadArticles?(result.articles)
        shouldShowLoadingIndicator?(false)
        isloading = false
    }
    
    private func handleFailure(error: Error) {
        shouldShowLoadingIndicator?(false)
        isloading = false
    }
    
    private func transform(_ jsonArticle: ArticleJson) -> Article? {
        guard let title = jsonArticle.title,
              let category = jsonArticle.category.first,
              let content = jsonArticle.description else { return nil }
        return Article(article_id: jsonArticle.article_id, title: title,
                       author: jsonArticle.creator?.first,
                       publishedAt: jsonArticle.pubDate,
                       category: category,
                       imageURL: jsonArticle.image_url,
                       content: content)
    }
}
