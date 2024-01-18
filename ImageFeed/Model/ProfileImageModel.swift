//
//  ProfileImageModel.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 18.01.2024.
//

import UIKit

struct ProfileImage: Codable {
    let smallImage: [String:String]
    
    init(callData: UserResult) {
        self.smallImage = callData.profileImage
    }
}
