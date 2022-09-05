//
//  NetworkService.swift
//  NetworkAPICW
//
//  Created by Martynov Evgeny on 5.09.22.
//

import Alamofire
import Foundation
import SwiftyJSON

class NetworkService {
    
    static func deletePost(postID: Int, callback: @escaping (_ result: JSON?, _ error: Error?) -> Void) {
        let url = ApiConstants.postsPath + "/" + "\(postID)"
        
        AF.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                var jsonValue: JSON?
                var err: Error?
                
                switch response.result {
                    case .success(let data):
                        jsonValue = JSON(data)
                    case .failure(let error):
                        err = error
                }
                callback(jsonValue, err)
            }
    }
    
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
}
