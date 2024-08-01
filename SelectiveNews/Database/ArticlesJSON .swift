//
//  ArticlesJSON .swift
//  SelectiveNews
//
//  Created by Arshif on 26/06/2024.
//

import Foundation
struct ArticleJson: Decodable {
    
    let article_id: String
    let title: String?
    let pubDate: String
    let description: String?
    let image_url: URL?
    let creator: [String]?
    let category: [String]
}

struct ArticleResults : Decodable {
    let results: [ArticleJson]
    let nextPage: String?
}

