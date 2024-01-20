//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Никита Гончаров on 16.01.2024.
//

@testable import ImageFeed
import UIKit

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    func estimatedProgressObservtion() {
        
    }
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
