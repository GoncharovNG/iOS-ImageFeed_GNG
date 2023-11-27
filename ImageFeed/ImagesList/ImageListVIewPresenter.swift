//
//  ImageListViewpresenter.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 27.11.2023.
//

import UIKit

protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? {get set}
    var imagesListService: ImagesListService {get}
    func viewDidLoad()
    func addPhotoLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func fetchPhotosNextPage()
}

final class ImageListViewPresenter: ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    let imagesListService = ImagesListService.shared
    
    func viewDidLoad() {
        configureNotificationObserver()
    }
    
    func addPhotoLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
            imagesListService.changeLike(photoId: photoId,
                                         isLike: isLike,
                                         { [weak self] result in
                guard self != nil else { return }
                switch result{
                case .success(_):
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                    print("Ошибка, возникшая при изменении типа: \(error)")
                }
            })
        }
    func configureNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                view?.updateTableViewAnimated()
            }
        imagesListService.fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage(){
        imagesListService.fetchPhotosNextPage()
    }
    
}
