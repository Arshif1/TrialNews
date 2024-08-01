//
//  Article.swift
//  SelectiveNews
//
//  Created by Arshif on 26/06/2024.
//

import Foundation

struct Article: Codable {
    let article_id: String
    let title: String
    let author: String?
    let publishedAt: String
    let category: String
    let imageURL: URL?
    let content: String
}
