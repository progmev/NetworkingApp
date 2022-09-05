//
//  FotoVC.swift
//  NetworkAPICW
//
//  Created by Martynov Evgeny on 5.09.22.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class PhotoVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var photo: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPhoto()
    }
    
    func getPhoto() {
        if let photoURL = photo["url"].string {
            if let image = CacheManager.shared.imageCache.image(withIdentifier: photoURL) {
                activityIndicator.stopAnimating()
                imageView.image = image
            } else {
                AF.request(photoURL).responseImage { [weak self] response in
                    if case .success(let image) = response.result {
                        self?.activityIndicator.stopAnimating()
                        self?.imageView.image = image
                        CacheManager.shared.imageCache.add(image, withIdentifier: photoURL)
                    }
                }
            }
        }
    }
}
