//
//  UserResultModel.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import UIKit

struct UserResult: Codable {
    let profileImage: [String:String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
