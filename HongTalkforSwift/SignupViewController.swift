//
//  SignupViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/29.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class SignupViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    let statusBar = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // statusBar 추가
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.right.top.left.equalTo(self.view)
            make.height.equalTo(20)
        }
        
        // Event , Setting
        setupImageView()
        setupColor()
        joinButton.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancleButton.addTarget(self, action: #selector(cancleEvent), for: .touchUpInside)
        
    }
    
    func setupImageView() {
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
    }
    
    func setupColor() {
        color = remoteConfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        joinButton.backgroundColor = UIColor(hex: color)
        cancleButton.backgroundColor = UIColor(hex: color)
    }
    
    @objc
    func signupEvent() {
        // MARK: 강제 언래핑 추후 고민해서 해제할것
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, err) in
            let uid = user?.user.uid
            
            let image = self.imageView.image!.jpegData(compressionQuality: 0.1)
            let imageRef = Storage.storage().reference().child("userImages").child(uid!)
            
            imageRef.putData(image!) { data, err in
                imageRef.downloadURL { url, err in
                    Database.database().reference().child("users").child(uid!).setValue(["userName": self.name.text, "profileImageUrl": url?.absoluteString])
                }
            }
            
            Database.database().reference().child("users").child(uid!).setValue(["userName": self.name.text])
        }
    }
    
    @objc
    func cancleEvent() {
        self.dismiss(animated: true)
    }
}

// Navigation Delegate
extension SignupViewController: UINavigationControllerDelegate {
    
}

// UIImagePicker Delegate
extension SignupViewController: UIImagePickerControllerDelegate {
    @objc
    func imagePicker() {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        dismiss(animated: true)
    }
}
