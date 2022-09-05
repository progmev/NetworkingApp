= = = = = = = = = = = =

/// PostsTableViewController ///

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showComments",
            let postId = sender as? Int,
            let commentsVC = segue.destination as? CommentsTableViewController {
            commentsVC.getComments(pathUrl: "\(ApiConstants.postsPath)/\(postId)/comments")
        } else if segue.identifier == "addPost",
            let addPostVC = segue.destination as? AddPostVC {
            addPostVC.user = user
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postId = posts[indexPath.row].id
        performSegue(withIdentifier: "showComments", sender: postId)
    }

= = = = = = = = = = = =

class CommentsTableViewController: UITableViewController {
    
    var comments: [Comment] = []

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        let comment = comments[indexPath.row]
        cell.textLabel?.text = comment.name
        cell.detailTextLabel?.text = comment.body
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    func getComments(pathUrl: String) {

        guard let url = URL(string: pathUrl) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else { return }
            do {
                self.comments = try JSONDecoder().decode([Comment].self, from: data)
                print(self.comments)
            } catch let error {
                print(error)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
}

= = = = = = = = = = = =

import Alamofire
import SwiftyJSON
import UIKit

class AddPostVC: UIViewController {
    
    @IBOutlet var titlePostTF: UITextField!
    @IBOutlet var textPostTV: UITextView!

    var user: User!

    @IBAction func addPostAction(_ sender: Any) {
        if let userId = user.id,
           let title = titlePostTF.text,
           let text = textPostTV.text,
           let url = ApiConstants.postsPathURL
        {
            // SETUP request
            var request = URLRequest(url: url)

            // HEADER
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            // BODY
            let post: [String: Any] = ["userId": userId,
                                       "title": title,
                                       "body": text]

            guard let httpBody = try? JSONSerialization.data(withJSONObject: post, options: []) else { return }
            request.httpBody = httpBody

            // Create dataTask and post new request
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                print(response ?? "")
                if let data = data {
                    print(data)
                    let json = JSON(data)
                    print(json)
                    let userId = json["userId"].int
                    let title = json["title"].string
                    let body = json["body"].string
                    
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                } else if let error = error {
                    print(error)
                }
            }.resume()
        }
    }

    @IBAction func addAFPostAction(_ sender: Any) {
        if let userId = user.id,
           let title = titlePostTF.text,
           let text = textPostTV.text,
           let url = ApiConstants.postsPathURL
        {
            let post: Parameters = ["userId": userId,
                                       "title": title,
                                       "body": text]
            
            AF.request(url, method: .post, parameters: post, encoding: JSONEncoding.default)
                .responseJSON { response in

                    debugPrint(response)
                    print(response.request)
                    print(response.response)
                    debugPrint(response.result)

                    switch response.result {
                    case .success(let data):
                        print(data)
                        print(JSON(data))
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print(error)
                    }
                }
        }
    }
}

= = = = = = = = = = = =

REMOVE LOGIC

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let id = comments[indexPath.row].id {
            
            ApiService.deleteComment(idComment: id) { [weak self] json, error in
                if json != nil {
                    self?.comments.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else if let error = error {
                    print(error)
                }
                
                print(json)
                print(error)
            }
        }
    }
    
= = = = = = = = = = = =

import Alamofire
import Foundation
import SwiftyJSON

class ApiService {
    
    
    // Пример из реального проекта
    
//    class func putEFK(efk: String, fileId: String, callback: @escaping (_ result: JSON?, _ error: Error?) -> Void) {
//        let token = KeychainSwift().get(KeyConstants.token) ?? ""
//        let header: HTTPHeaders = [HttpKeys.authorization: token].merging(globalHeader()) { _, new in new }
//
//        let url = APPURL.shared + "/" + fileId + "/" + APPURL.efkUrl
//
//        Alamofire.request(url, method: .put, parameters: ["efk": efk], encoding: JSONEncoding.default, headers: header).validate().responseJSON { response in
//
//            var value: JSON?
//            var err: Error?
//
//            switch response.result {
//            case .success(let a):
//                value = JSON(a)
//            case .failure(let error):
//                err = error
//            }
//            callback(value, err)
//        }
//    }
    
    
    static func deleteComment(idComment: Int, callback: @escaping (_ result: JSON?, _ error: Error?) -> Void) {
        
        let url = ApiConstants.commentsPath + "/" + "\(idComment)"
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            var value: JSON?
            var err: Error?

            switch response.result {
            case .success(let a):
                value = JSON(a)
            case .failure(let error):
                err = error
            }
            callback(value, err)
        }
    }
}

= = = = = = = = = = = =

class AlbomsTableVC: UITableViewController {

    var user: User!
    var alboms: [JSON] = []

    override func viewDidLoad() {
        getData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos",
            let photosCollectionVC = segue.destination as? PhotosCollectionVC,
            let album = sender as? JSON {
            photosCollectionVC.user = user
            photosCollectionVC.album = album
        }
    }

    private func getData() {

        guard let userId = user.id else { return }
        
        guard let url = URL(string: "\(ApiConstants.albumsPath)?userId=\(userId)") else { return }

        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let data):
                self.alboms = JSON(data).arrayValue
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alboms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = (alboms[indexPath.row]["id"].int ?? 0).description
        cell.detailTextLabel?.text = alboms[indexPath.row]["title"].stringValue
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albom = alboms[indexPath.row]
        performSegue(withIdentifier: "showPhotos", sender: albom)
    }
}

= = = = = = = = = = = =

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

private let reuseIdentifier = "Cell"

class PhotosCollectionVC: UICollectionViewController {

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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageVC = segue.destination as? ImageVC,
           let photo = sender as? JSON {
            imageVC.photo = photo
        }
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
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.photo = photos[indexPath.row]
        cell.configureCell()
        cell.getThumbnail()
        return cell
    }

    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPhoto", sender: photos[indexPath.row])
    }
}

= = = = = = = = = = = =

import UIKit
import SwiftyJSON
import Alamofire
import AlamofireImage

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoImage: UIImageView!

    var photo: JSON!

    func configureCell() {
        photoImage.image = #imageLiteral(resourceName: "image-placeholder")
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

= = = = = = = = = = = =

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class ImageVC: UIViewController {

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

= = = = = = = = = = = =
