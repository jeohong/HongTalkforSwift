//
//  SignupViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/29.
//

import UIKit
import Firebase
import FirebaseDatabase

class SignupViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var cancleButton: UIButton!
    
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    let statusBar = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        setupColor()
        joinButton.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancleButton.addTarget(self, action: #selector(cancleEvent), for: .touchUpInside)
    }
    
    func setupColor() {
        color = remoteConfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        joinButton.backgroundColor = UIColor(hex: color)
        cancleButton.backgroundColor = UIColor(hex: color)
    }
    
    @objc
    func signupEvent() {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, err) in
            let uid = user?.user.uid
            
            Database.database().reference().child("users").child(uid!).setValue(["name": self.name.text])
        }
    }
    
    @objc
    func cancleEvent() {
        self.dismiss(animated: true)
    }

}
