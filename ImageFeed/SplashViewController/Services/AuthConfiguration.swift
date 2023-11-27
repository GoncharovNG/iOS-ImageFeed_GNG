//
//  Constants.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 14.11.2023.
//

import UIKit

let stackAccessKey = "X3RsC0L2a62xtTGAo7_-F0W4-RrPrpdB5Sy5X2t6Et4"
let stackSecretKey = "4bKB0wZ1DdN16MuDXKBtRAdy64NFUxt_CBWHfTRYmx8"
let stackRedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let stackAccessScope = "public+read_user+write_likes"
let stackDefaultBaseURL = URL(string: "https://api.unsplash.com")!
let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: stackAccessKey,
                                     secretKey: stackSecretKey,
                                     redirectURI: stackRedirectURI,
                                     accessScope: stackAccessScope,
                                     defaultBaseURL: stackDefaultBaseURL,
                                     authURLString: unsplashAuthorizeURLString)
        }
}
