//
//  BookmarkedArticleViewModel.swift
//  SelectiveNews
//
//  Created by Arshif on 16/07/2024.
//

import Foundation

class BookmarkedArticleViewModel {
    
    var onLoadArticles: (([Article]) -> ())?
    var onResettingArticles: (() -> Void)?
    
    private func fetchURLForBookMarkedIds() -> URL? {
        guard let bookmarkedArticleIds = UserDefaults.standard.array(forKey: "articleId") as? [String], !bookmarkedArticleIds.isEmpty else { return nil }
        var baseurl = "https://newsdata.io/api/1/latest?apikey=pub_4740411c97d4533dc0cb60e4f09dc5df81264"
        let ids = bookmarkedArticleIds.joined(separator: ",")
        baseurl.append("&id=\(ids)")
        return URL(string: baseurl)
    }
    
    func loadArticles() {
        guard let url = fetchURLForBookMarkedIds() else {
            onResettingArticles?()
            return
        }
        loadResponse(for: url)
    }
    
    private func loadResponse(for url: URL) {
        Task {
            do {
                let response = try await fetchArticleResults(for: url)
                await handleJsonResponse(json: response)
            } catch {
                print("oops")
            }
        }
    }
    
    private func fetchArticleResults(for url: URL) async throws -> ArticleResults {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(ArticleResults.self, from: data)
    }
    
    private func handleJsonResponse(json: ArticleResults) async {
        let articles = json.results.compactMap(transform)
        await handleArticles(articles: articles)
    }
    
    private func handleArticles(articles: [Article]) async {
        await MainActor.run {
            onLoadArticles?(articles)
        }
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
