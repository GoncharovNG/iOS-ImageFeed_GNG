//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 16.11.2023.
//

import UIKit
import ProgressHUD

class SplashViewController: UIViewController {
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private var profileService = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    private var alertPresenter: AlertPresenterProtocol?
    var presenter: ProfileViewPresenterProtocol?
    private let mainID = "Main"
    private let authViewControllerID = "AuthViewController"
    private let tabBarViewControllerID = "TabBarViewController"
    
    private let splashScreenLogoImageView: UIImageView = {
        let viewImageLogoScreenSplash = UIImageView()
        viewImageLogoScreenSplash.image = UIImage(named: "logo_of_unsplash")
        viewImageLogoScreenSplash.translatesAutoresizingMaskIntoConstraints = false
        
        return viewImageLogoScreenSplash
    }()
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        view.addSubview(splashScreenLogoImageView)
        splashScreenLogoImageViewSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let splashScreenLogo = splashScreenLogo()
        NSLayoutConstraint.activate([
            splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        if let token = OAuth2TokenStorage().token {
            self.profileService.fetchProfile(token)
            self.profileImageService.fetchProfileImageURL(username: profileService.getProfile()?.username ?? "") { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .failure(_):
                    DispatchQueue.main.async {
                        self.showAlert()
                    }
                case .success(_):
                    DispatchQueue.main.async {
                        self.switchToTabBarController()
                    }
                }
            }
        } else {
            guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { fatalError("Invalid Configuration") }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = tabBarController
    }
}


// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    private func switchToAuthViewController() {
        let storyboard = UIStoryboard(name: mainID, bundle: .main).instantiateViewController(identifier: authViewControllerID)
        guard let authViewController = storyboard as? AuthViewController else {
            assertionFailure("Failed to show Authentication Screen")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

extension SplashViewController {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func showToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { assertionFailure("Invalid Configuration")
            return }
        let tabBarController = UIStoryboard(name: mainID, bundle: .main)
            .instantiateViewController(withIdentifier: tabBarViewControllerID)
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                guard let username = self.profileService.profile?.username else { return }
                self.profileImageService.fetchProfileImageURL(username: username)  { _ in }
                DispatchQueue.main.async {
                    self.showToTabBarController()
                }
            case .failure:
                self.showAlert()
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func splashScreenLogoImageViewSetup() {
        NSLayoutConstraint.activate([
            splashScreenLogo().heightAnchor.constraint(equalToConstant: 77),
            splashScreenLogo().widthAnchor.constraint(equalToConstant: 74),
            splashScreenLogo().centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashScreenLogo().centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.oauth2TokenStorage.token = token
                self.fetchProfile(token: token)
            case .failure:
                self.showAlert()
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
}

extension SplashViewController {
    private func showAlert() {
        let alert = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "ОК",
            completion: { [weak self] in
                guard let self = self else {
                    return
                }
                oauth2TokenStorage.token = nil
                profileService.cleanCookies()
                profileService.peel()
            })
        switchToAuthViewController()
        alertPresenter?.showError(for: alert)
    }
    
    func splashScreenLogo() -> UIImageView {
        let splashScreenLogo = UIImageView(image: UIImage(named: "splash_screen_logo"))
        view.addSubview(splashScreenLogo)
        splashScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        
        return splashScreenLogo
    }
}
