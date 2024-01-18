//
//  ProfileResultModel.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 18.01.2024.
//

import UIKit

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}
