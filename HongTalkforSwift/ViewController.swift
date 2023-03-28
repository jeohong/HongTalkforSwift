//
//  ViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/28.
//

import UIKit
import SnapKit
import Firebase

class ViewController: UIViewController {
    
    var box = UIImageView()
    var remoteConfig: RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFirebaseRemote()
        
        self.view.addSubview(box)
        box.snp.makeConstraints { make in
            make.center.equalTo(self.view)
        }
        box.image = UIImage(named: "loading")
    }
    
    func setupFirebaseRemote() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        // 서버랑 연결이 되지 않은경우 Default값 사용
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        // 서버와 연결이 성공된 후
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { changed, error in
                    // ...
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }
    }
    
    func displayWelcome() {
        let color = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if(caps) {
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                exit(0)
            }))
            
            self.present(alert, animated: true)
        } else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            
            self.present(loginVC, animated: false)
        }
        
        self.view.backgroundColor = UIColor(hex: color!)
    }
}
