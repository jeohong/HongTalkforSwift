//
//  ChatRoomsViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/30.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController {
    @IBOutlet weak var chatRoomList: UITableView!
    
    var uid: String!
    var chatrooms: [ChatModel]! = []
    var destinationUsers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uid = Auth.auth().currentUser?.uid
        self.getChatroomsList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
    func getChatroomsList() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: .value) { datasnapshot in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                self.chatrooms.removeAll()
                if let chatroomdic = item.value as? [String:AnyObject] {
                    let chatmodel = ChatModel(JSON: chatroomdic)
                    self.chatrooms.append(chatmodel!)
                }
            }
            
            self.chatRoomList.reloadData()
        }
    }
    
}

extension ChatRoomsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let destinationUid = self.destinationUsers[indexPath.row]
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        chatVC.destinationUid = destinationUid
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}

extension ChatRoomsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! CustomCell
        
        var destinationUid: String?
        
        for item in chatrooms[indexPath.row].users {
            if (item.key != self.uid) {
                destinationUid = item.key
                destinationUsers.append(destinationUid!)
            }
        }
        
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: .value) { datasnapshot in
            let userModel = UserModel()
            userModel.setValuesForKeys(datasnapshot.value as! [String:AnyObject])
            
            cell.label_title.text = userModel.userName
            let url = URL(string: userModel.profileImageUrl!)
            URLSession.shared.dataTask(with: url!) { data, response, error in
                
                DispatchQueue.main.async {
                    cell.imageview.image = UIImage(data: data!)
                    cell.imageview.layer.cornerRadius = cell.imageview.frame.width / 2
                    cell.imageview.layer.masksToBounds = true
                }
            }.resume()
            
            let lastMessageKey = self.chatrooms[indexPath.row].comments.keys.sorted(){ $0 > $1 }
            cell.label_lastMessage.text = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.message
            
            let unixTime = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.timestamp
            cell.label_timestamp.text = unixTime?.toDayTime
        }
        
        return cell
    }
}

class CustomCell: UITableViewCell {
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_lastMessage: UILabel!
    @IBOutlet weak var label_timestamp: UILabel!
    
}
