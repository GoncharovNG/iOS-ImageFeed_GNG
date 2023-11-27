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
        baseURL: URL? = stackDefaultBaseURL
    ) -> URLRequest? {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL) ?? stackDefaultBaseURL)
        request.httpMethod = httpMethod
        return request
    }
}
