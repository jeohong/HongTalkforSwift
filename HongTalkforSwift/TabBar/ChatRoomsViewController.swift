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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uid = Auth.auth().currentUser?.uid
        self.getChatroomsList()
    }
    
    func getChatroomsList() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: .value) { datasnapshot in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
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
    
}

extension ChatRoomsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath)
        
        return cell
    }
    
    
}
