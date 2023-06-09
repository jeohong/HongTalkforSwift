//
//  LoginViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/28.
//

import UIKit
import Firebase
import FirebaseMessaging

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 처음 시작할 때 로그아웃
        try! Auth.auth().signOut()
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(UIApplication.shared.statusBarFrame.size.height)
            
        }
        color = remoteConfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signupButton.backgroundColor = UIColor(hex: color)
        
        signupButton.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if (user != nil) {
                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                mainVC.modalPresentationStyle = .fullScreen
                self.present(mainVC, animated: true)
                
                let uid = Auth.auth().currentUser?.uid
                // 문서 업데이트로 토큰 가져오는 방법이 변경됨
                Messaging.messaging().token { token, error in
                    if let error = error {
                        print("Error fetching remote FCM registration token: \(error)")
                    } else if let token = token {
                        print("Remote instance ID token: \(token)")
                        Database.database().reference().child("users").child(uid!).updateChildValues(["pushToken": token])
                    }
                }                
            }
        }
    }
    
    @objc
    func presentSignup() {
        let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        signupVC.modalPresentationStyle = .fullScreen
        
        self.present(signupVC, animated: true, completion: nil)
    }
    
    @objc
    func loginEvent() {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { user, error in
            if (error != nil) {
                let alert = UIAlertController(title: "에러", message: error.debugDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
}
