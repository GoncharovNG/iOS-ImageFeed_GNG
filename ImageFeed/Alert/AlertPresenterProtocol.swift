//
//  AlertPresenterProtocol.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import Foundation

protocol AlertPresenterProtocol: AnyObject {
    func showError(for model: AlertModel)
}
