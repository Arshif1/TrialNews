//
//  ArticleCell.swift
//  SelectiveNews
//
//  Created by Arshif on 26/06/2024.
//

import UIKit

class ArticleCell: UITableViewCell {
    
    var isBookMarked: Bool = false {
        didSet {
            updateBookmarkButton()
//            shouldBookMark?(isBookMarked)
        }
    }
//    private var isBookmarked = false
    
    var shouldBookMark: ((Bool) -> ())?
    
    var article: Article? {
        didSet {
            guard let article else { return }
            configure(with: article)
        }
    }
    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var imageViewArticle: UIImageView!
    @IBOutlet weak var labelPublisheAt: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelPublishedBy: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        updateBookmarkButton()
    }
    
    private func setupViews() {
        
        selectionStyle = .none
        labelTitle.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        labelPublishedBy.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        labelPublisheAt.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        labelCategory.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        labelTitle.textColor = .black
        labelPublishedBy.textColor = .black
        labelCategory.textColor = .blue
        labelPublisheAt.textColor = .gray
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        isBookMarked.toggle()
        shouldBookMark?(isBookMarked)
    }
    
    func updateBookmarkButton() {
           let imageName = isBookMarked ? "bookmark.fill" : "bookmark"
           bookmarkButton.setImage(UIImage(systemName: imageName), for: .normal)
       }
    
    private func configure(with article: Article) {
        
        labelTitle.text = article.title
        labelPublisheAt.text = article.publishedAt
        labelPublishedBy.text = article.author
        labelCategory.text = article.category.capitalized
        
    }
}
