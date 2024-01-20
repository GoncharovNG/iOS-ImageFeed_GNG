//
//  AlertPresenterProtocol.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 17.01.2024.
//

import UIKit

protocol AlertPresenterProtocol: AnyObject {
    func showError(for model: AlertModel)
}
