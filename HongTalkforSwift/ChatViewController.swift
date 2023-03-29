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
    @IBOutlet weak var textField: UITextField!
    
    
    var uid: String?
    var chatRoomUid: String?
    
    public var destinationUid: String? // 채팅할 대상의 UID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        checkChatRoom()
    }
    
    @IBAction func createRoom(_ sender: UIButton) {
        let createRoomInfo: Dictionary<String,Any> = [
            "users": [
                uid!: true,
                destinationUid!: true
            ]
        ]
        if ( chatRoomUid == nil ) {
            // 방 생성 코드
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo)
        } else {
            // 방이 이미 있을경우 해당 방으로 입장
            let value: Dictionary<String,Any> = [
                "comments": [
                    "uid": uid!,
                    "message": textField.text!
                ]
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value)
        }
    }
    
    // 중복 방 생성 방지
    func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value) { dataSnapshot in
            for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                self.chatRoomUid = item.key
            }
        }
    }
}
