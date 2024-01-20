//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 18.01.2024.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
