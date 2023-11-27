//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 19.11.2023.
//

import UIKit
import WebKit

final class ProfileService {
    
    static let shared = ProfileService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileProviderDidChange")
    private let urlSession = URLSession.shared
    private (set) var profile: Profile?
    private var task: URLSessionTask?
    private var lastToken: String?
    private let lock = NSLock()
    private let semaphore = DispatchSemaphore(value: 0)
    private init() {}
    
    func fetchProfile(_ token: String) {
        self.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.profile = profile
                self.lock.unlock()
                self.semaphore.signal()
            case .failure(_ ):
                self.lastToken = nil
                self.lock.unlock()
                self.semaphore.signal()
            }
        }
    }
    
    func getProfile() -> Profile? {
        if self.profile == nil {
            self.semaphore.wait()
        }
        return self.profile
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == token { return }
        lock.lock()
        lastToken = token
        
        let url = URL(string: "https://api.unsplash.com/me")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request)  { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let profile = Profile(callData: body)
                self.profile = profile
                completion(.success(profile))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    func peel() {
            profile = nil
        }
}

extension ProfileService {
    func profileRequest(token: String) -> URLRequest {
        guard let url = URL(
            string: "\(stackDefaultBaseURL)"
            + "/me")
        else {
            fatalError("Failed to create URL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func cleanCookies() {
       HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
       WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
           records.forEach { record in
               WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
           }
       }
   }
}
