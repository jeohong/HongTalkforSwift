//
//  ChatViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/29.
//

import UIKit
import Firebase
import Alamofire
import Kingfisher

class ChatViewController: UIViewController {
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var chattingView: UITableView!
    
    var uid: String?
    var chatRoomUid: String?
    
    var comments: [ChatModel.Comment] = []
    var destinationUserModel: UserModel?
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var peopleCount: Int?
    
    public var destinationUid: String? // 채팅할 대상의 UID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        checkChatRoom()
        
        // tabbar 숨기기
        self.tabBarController?.tabBar.isHidden = true
        
        // 영역 밖을 누르면 키보드 숨기기
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
        
        databaseRef?.removeObserver(withHandle: observe!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification: )), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstrain.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }, completion: { complete in
            if self.comments.count > 0 {
                self.chattingView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
            }
        })
    }
    
    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc
    func keyboardWillHide(notification: Notification) {
        self.bottomConstrain.constant = 20
        self.view.layoutIfNeeded()
    }
    
    @IBAction func createRoom(_ sender: UIButton) {
        if self.textField.text == "" { return }
        let createRoomInfo: Dictionary<String,Any> = [
            "users": [
                uid!: true,
                destinationUid!: true
            ]
        ]
        if ( chatRoomUid == nil ) {
            // 방이 있을 경우 버튼 비활성화
            self.sendButton.isEnabled = false
            // 방 생성 코드
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo) { error, dataRef in
                if (error == nil) {
                    self.checkChatRoom()
                }
            }
        } else {
            // 방이 이미 있을경우 해당 방으로 입장
            let value: Dictionary<String,Any> = [
                "uid": uid!,
                "message": textField.text!,
                "timestamp": ServerValue.timestamp()
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value) { error, dataRef in
                self.sendFcm()
                self.textField.text = ""
            }
        }
    }
    
    func sendFcm() {
        let url = "https://fcm.googleapis.com/fcm/send"
        
        let header: HTTPHeaders = [
            "Content-Type":"application/json",
            "Authorization":"key=\(API_KEY.FirebaseServer.rawValue)"
        ]
        
        let username = Auth.auth().currentUser?.displayName
        
        let notificationModel = NotificationModel()
        notificationModel.to = destinationUserModel?.pushToken
        notificationModel.notification.title = username
        notificationModel.notification.body = textField.text
        notificationModel.data.title = username
        notificationModel.data.body = textField.text
        
        let params = notificationModel.toJSON()
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            // response
        }
        
    }
    
    // 중복 방 생성 방지
    func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: .value) { dataSnapshot in
            for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                
                if let chatRoomdic = item.value as? [String:AnyObject] {
                    
                    let chatModel = ChatModel(JSON: chatRoomdic)
                    if(chatModel?.users[self.destinationUid!] == true) {
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        self.getDestinationInfo()
                    }
                }
            }
        }
    }
    
    func getDestinationInfo() {
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: .value) { dataSnapshot in
            self.destinationUserModel = UserModel()
            self.destinationUserModel?.setValuesForKeys(dataSnapshot.value as! [String:Any])
            self.getMessageList()
        }
    }
    
    func setReadCount(label: UILabel?, position: Int?) {
        let readCount = self.comments[position!].readUsers.count
        
        if (peopleCount == nil) {
            
        
        
        Database.database().reference().child("chatrooms").child(chatRoomUid!).child("users").observeSingleEvent(of: .value) { dataSnapshaot in
            let dic = dataSnapshaot.value as! [String:Any]
            self.peopleCount = dic.count
            let noReadCount = self.peopleCount! - readCount
            
            if(noReadCount > 0) {
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
        }
        } else {
            let noReadCount = self.peopleCount! - readCount
            
            if(noReadCount > 0) {
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
        }
    }
    
    func getMessageList() {
        databaseRef = Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments")
        observe = databaseRef?.observe(.value) { dataSnapshot in
            self.comments.removeAll()
            var readUserDic: Dictionary<String,AnyObject> = [:]
            
            for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                let key = item.key as String
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                let comment_motify = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                comment_motify?.readUsers[self.uid!] = true
                readUserDic[key] = comment_motify?.toJSON() as! NSDictionary
                
                self.comments.append(comment!)
            }
            
            let nsDic = readUserDic as NSDictionary
            if(!(self.comments.last?.readUsers.keys.contains(self.uid!))!){
                dataSnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any]) { error, ref in
                    
                    self.chattingView.reloadData()
                    
                    if self.comments.count > 0 {
                        self.chattingView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                    }
                }
            } else {
                self.chattingView.reloadData()
                
                if self.comments.count > 0 {
                    self.chattingView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.comments[indexPath.row].uid == uid) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            cell.label_message.text = self.comments[indexPath.row].message
            cell.label_message.numberOfLines = 0
            if let time = self.comments[indexPath.row].timestamp {
                cell.label_timestamp.text = time.toDayTime
            }
            
            setReadCount(label: cell.readCount, position: indexPath.row)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            cell.label_name.text = destinationUserModel?.userName
            cell.label_message.text = self.comments[indexPath.row].message
            cell.label_message.numberOfLines = 0
            
            if let time = self.comments[indexPath.row].timestamp {
                cell.label_timestamp.text = time.toDayTime
            }
            
            let url = URL(string: (self.destinationUserModel?.profileImageUrl)!)
            
            cell.imageView_Profile.layer.cornerRadius = cell.imageView_Profile.frame.width / 2
            cell.imageView_Profile.clipsToBounds = true
            cell.imageView_Profile.kf.setImage(with: url)
            
            // 대체 -> 킹피셔 라이브러리 사용
            //            URLSession.shared.dataTask(with: url!) { data, response, error in
            //                DispatchQueue.main.async {
            //                    cell.imageView_Profile.image = UIImage(data: data!)
            //                }
            //            }.resume()
            
            setReadCount(label: cell.readCount, position: indexPath.row)
            
            return cell
        }
    }
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var label_timestamp: UILabel!
    @IBOutlet weak var readCount: UILabel!
}

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var imageView_Profile: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_timestamp: UILabel!
    @IBOutlet weak var readCount: UILabel!
}
