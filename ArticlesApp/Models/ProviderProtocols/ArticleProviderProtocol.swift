//
//  ArticleProviderProtocol.swift
//  ArticlesApp
//
//  Created by Ankush Mittal on 10/10/26.
//



import Foundation

protocol ArticleProviderProtocol {
    func fetchArticles(
        completion: @escaping (Result<[Article], Error>) -> Void
    )
}
