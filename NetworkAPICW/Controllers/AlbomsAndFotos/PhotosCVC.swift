//
//  FotosCVC.swift
//  NetworkAPICW
//
//  Created by Martynov Evgeny on 5.09.22.
//

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class PhotosCVC: UICollectionViewController {

    var user: User!
    var album: JSON!
    var photos: [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = album["title"].string
        getData()
    }

    override func viewWillAppear(_ animated: Bool) {
        let layout = UICollectionViewFlowLayout()
        let sizeWH = UIScreen.main.bounds.width / 2 - 5
        layout.itemSize = CGSize(width: sizeWH, height: sizeWH)
        collectionView.collectionViewLayout = layout
    }



    func getData() {
        if let album = album,
            let albumId = album["id"].int,
            let url = URL(string: "https://jsonplaceholder.typicode.com/photos?albumId=\(albumId)") {

            AF.request(url).responseJSON { response in
                switch response.result {
                case .success(let data):
                    self.photos = JSON(data).arrayValue
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.photo = photos[indexPath.row]
        cell.configureCell()
        cell.getThumbnail()
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "showPhoto", sender: photos[indexPath.row])
//    }
//    
//    // MARK: - Navigation
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let imageVC = segue.destination as? ImageVC,
//           let photo = sender as? JSON {
//            imageVC.photo = photo
//        }
//    }
}
