//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import Foundation
import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {

    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
