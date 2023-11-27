//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 16.11.2023.
//

import Foundation

class OAuth2Service {
    
    static let shared = OAuth2Service()
    private var task: URLSessionTask?
    private var lastCode: String?
    private var currentTask: URLSessionTask?
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        currentTask?.cancel()
        lastCode = code
        
        guard let request = authTokenRequest(code: code) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    completion(.success(response.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                    self.lastCode = nil
                }
                self.currentTask = nil
            }
        }
        currentTask = task
        task.resume()
    }
}

    private extension OAuth2Service {
        func authTokenRequest(code: String) -> URLRequest? {
            URLRequest.makeHTTPRequest(
                path: "/oauth/token"
                + "?client_id=\(stackAccessKey)"
                + "&&client_secret=\(stackSecretKey)"
                + "&&redirect_uri=\(stackRedirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                httpMethod: "POST",
                baseURL: URL(string: "https://unsplash.com")!
            )
        }
    }
