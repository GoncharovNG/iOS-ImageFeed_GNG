//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
    var nextButtonText: String?
    var nextCompletion: () -> Void = {}
}
