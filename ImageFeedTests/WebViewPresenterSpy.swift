//
//  WebViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Никита Гончаров on 16.01.2024.
//

@testable import ImageFeed
import UIKit

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
