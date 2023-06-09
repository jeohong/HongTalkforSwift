//
//  AccountViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/31.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {
    @IBOutlet weak var conditionsCommentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conditionsCommentButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
    }
    
    @objc
    func showAlert() {
        let alertController = UIAlertController(title: "상태 메세지", message: nil, preferredStyle: .alert)
        alertController.addTextField { textfield in
            textfield.placeholder = "상태메세지 입력"
        }
        
        alertController.addAction(UIAlertAction(title: "확인", style: .default) { action in
            if let textfield = alertController.textFields?.first {
                let dic = ["comment":textfield.text!]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
        })
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel) { action in
            
        })
        
        self.present(alertController, animated: true)
    }
}
