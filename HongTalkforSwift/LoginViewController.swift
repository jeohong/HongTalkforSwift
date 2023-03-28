//
//  LoginViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/28.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
    
        }
     
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signinButton.backgroundColor = UIColor(hex: color)
    }
}
