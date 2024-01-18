//
//  URLRequestExtension.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import UIKit

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL? = DefaultBaseURL
    ) -> URLRequest? {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL) ?? DefaultBaseURL)
        request.httpMethod = httpMethod
        return request
    }
}
