//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 16.11.2023.
//

import UIKit
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private let keychainKeeping = KeychainWrapper.standard
    private let keyToken = "Bearer"
    private enum Keys: String {
        case token
    }
    
    var token: String? {
        get {
            keychainKeeping.string(forKey: keyToken)
        }
        set {
            if let token = newValue {
                keychainKeeping.set(token, forKey: keyToken)
            } else {
                keychainKeeping.removeObject(forKey: keyToken)
            }
        }
    }
    
    init() {}
}

