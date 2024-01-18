//
//  UserResultModel.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 18.01.2024.
//

import UIKit

struct UserResult: Codable {
    let profileImage: [String:String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
