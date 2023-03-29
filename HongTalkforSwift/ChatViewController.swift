//
//  ChatViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/29.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    @IBOutlet weak var sendButton: UIButton!
    
    public var destinationUid: String? // 채팅할 대상의 UID
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    func createRoom() {
//        let createRoomInfo = [
//            "uid": Auth.auth().currentUser?.uid,
//            "destinationUid": destinationUid
//        ]
//        
//        Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
//    }
    @IBAction func createRoom(_ sender: UIButton) {
        let createRoomInfo = [
            "uid": Auth.auth().currentUser?.uid,
            "destinationUid": destinationUid
        ]
        
        Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
    }
}
