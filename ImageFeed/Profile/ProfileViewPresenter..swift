//
//  ProfileVIewPresenter.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import WebKit
import UIKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func exitProfile()
    func profileServiceObserver()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        profileServiceObserver()
    }
    
    func exitProfile() {
        OAuth2TokenStorage().token = nil
        profileService.cleanCookies()
        profileService.peel()
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
    
    func profileServiceObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            view?.loadAvatar()
        }
        view?.loadAvatar()
    }
}
