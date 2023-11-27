//
//  ProfileModel.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import UIKit

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(callData: ProfileResult) {
        self.username = callData.username
        self.name = (callData.firstName) + " " + (callData.lastName ?? "")
        self.loginName = "@" + (callData.username )
        self.bio = callData.bio
    }
}
