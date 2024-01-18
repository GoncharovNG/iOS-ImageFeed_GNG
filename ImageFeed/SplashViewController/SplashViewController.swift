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
    
    private let splashScreenLogo: UIImageView = {
        let logoScreenSplash = UIImageView()
        logoScreenSplash.image = UIImage(named: "logo_of_unsplash")
        logoScreenSplash.translatesAutoresizingMaskIntoConstraints = false
        
        return logoScreenSplash
    }()
    // MARK: - UIViewController
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if oauth2TokenStorage.token != nil {
            guard let token = oauth2TokenStorage.token else { return }
            fetchProfile(token: token)
        } else {
            switchToAuthViewController()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        view.addSubview(splashScreenLogo)
        splashScreenLogoImageViewSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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
            splashScreenLogo.heightAnchor.constraint(equalToConstant: 77),
            splashScreenLogo.widthAnchor.constraint(equalToConstant: 74),
            splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
                profileService.clean()
            })
        switchToAuthViewController()
        alertPresenter?.showError(for: alert)
    }
}
