//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Никита Гончаров on 02.06.2023.
//
import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? {get set}
    func updateTableViewAnimated()
    var photos: [Photo] {get set}
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    @IBOutlet weak private var tableView: UITableView!
    private let ShowSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private let imagesListService = ImagesListService.shared
    var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    lazy var presenter: ImagesListViewPresenterProtocol? = {
        return ImageListViewPresenter()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            let indexPath = sender as? IndexPath
            guard let viewController = viewController,
                  let indexPath = indexPath,
                  let photoURL = photos[indexPath.row].largeImageURL,
                  let imageURL = URL(string: photoURL)
            else { return }
            viewController.fullImageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
    extension ImagesListViewController {
        func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
            let imageUrl = photos[indexPath.row].thumbImageURL!
            let url = URL(string: imageUrl)
            let placeholder = UIImage(named: "placeholder_stub")
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(with: url, placeholder: placeholder) { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                cell.cellImage.kf.indicatorType = .none
                if let data = imagesListService.photos[indexPath.row].createdAt {
                    cell.dateLabel.text = dateFormatter.string(from: data)
                } else {
                    cell.dateLabel.text = ""
                }
                let isLiked = imagesListService.photos[indexPath.row].isLiked == false
                let likeImage = isLiked ? UIImage(named: "like_button_off") : UIImage(named: "like_button_on")
                cell.likeButton.setImage(likeImage, for: .normal)
            }
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if !ProcessInfo.processInfo.arguments.contains("testMode") {
                if indexPath.row + 1 == imagesListService.photos.count {
                    presenter?.fetchPhotosNextPage()
                }
            }
        }
         func updateTableViewAnimated() {
            let oldCount = photos.count
            let newCount = imagesListService.photos.count
            photos = imagesListService.photos
            if oldCount != newCount {
                tableView.performBatchUpdates{
                    let indexPaths = (oldCount..<newCount).map { i in IndexPath(row: i, section: 0) }
                    tableView.insertRows(at: indexPaths, with: .bottom)
                } completion: { _ in }
            }
        }
    }

    extension ImagesListViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: ShowSingleImageSegueIdentifier, sender: indexPath)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let image = photos[indexPath.row]
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageWidth = image.size.width
            let scale = imageViewWidth / imageWidth
            let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
            return cellHeight
        }
    }

    extension ImagesListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photos.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
            
            guard let imageListCell = cell as? ImagesListCell else {
                return UITableViewCell()
            }
            imageListCell.delegate = self
            configCell(for: imageListCell, with: indexPath)
            return imageListCell
        }
    }

    extension ImagesListViewController: ImagesListCellDelegate {
        func imageListCellDidTapLike(_ cell: ImagesListCell) {
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            let photo = photos[indexPath.row]
            UIBlockingProgressHUD.show()
            presenter?.addPhotoLike(
                photoId: photo.id,
                isLike: photo.isLiked) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success:
                        guard let newPhotos = self.presenter?.imagesListService.photos else {return}
                        self.photos = newPhotos
                        cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    case .failure:
                        self.showError()
                    }
                    UIBlockingProgressHUD.dismiss()
                }
        }
    }

    extension ImagesListViewController {
        private func showError() {
            let alert = AlertModel(
                title: "Что-то пошло не так(",
                message: "Не удалось поставить или убрать лайк",
                buttonText: "Ок",
                completion: { [weak self] in
                    guard let self = self else { return }
                    dismiss(animated: true)
                })
            alertPresenter?.showError(for: alert)
        }
    }
