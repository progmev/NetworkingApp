//
//  PhotoCollectionViewCell.swift
//  NetworkAPICW
//
//  Created by Martynov Evgeny on 5.09.22.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoImage: UIImageView!

    var photo: JSON!

    func configureCell() {
        photoImage.image = #imageLiteral(resourceName: "imageDef")
    }

    func getThumbnail() {
        if let thumbnailURL = photo["thumbnailUrl"].string {
            if let image = CacheManager.shared.imageCache.image(withIdentifier: thumbnailURL) {
                activityIndicator.stopAnimating()
                photoImage.image = image
            } else {
                AF.request(thumbnailURL).responseImage { [weak self] response in
                    if case .success(let image) = response.result {
                        self?.activityIndicator.stopAnimating()
                        self?.photoImage.image = image
                        CacheManager.shared.imageCache.add(image, withIdentifier: thumbnailURL)
                    }
                }
            }
        }
    }
}

