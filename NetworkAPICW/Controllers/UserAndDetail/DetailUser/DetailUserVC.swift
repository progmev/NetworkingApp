//
//  DetailUserVC.swift
//  NetworkAPICW
//
//  Created by Martynov Evgeny on 1.09.22.
//

import UIKit

class DetailUserVC: UIViewController {
    
    var user: User?
    
    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var username: UILabel!
    @IBOutlet private weak var email: UILabel!
    @IBOutlet private weak var phone: UILabel!
    @IBOutlet private weak var website: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func postsAction() {
        let storyboard = UIStoryboard(name: "PostsAndComments", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PostsTVC") as! PostsTVC
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func albomsAction() {
        let storyboard = UIStoryboard(name: "AlbomsAndFotos", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AlbomsTVC") as! AlbomsTVC
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func todosAction() {
    }
    
    private func setupUI() {
        name.text = user?.name
        username.text = user?.username
        email.text = user?.email
        phone.text = user?.phone
        website.text = user?.website
    }
}
