//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
