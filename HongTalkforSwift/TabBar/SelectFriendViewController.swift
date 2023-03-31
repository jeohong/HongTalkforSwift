//
//  SelectFriendViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/31.
//

import UIKit
import Firebase
import BEMCheckBox

class SelectFriendViewController: UIViewController {
    var array: [UserModel] = []

    @IBOutlet weak var addChatButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Database.database().reference().child("users").observe(.value) { snapshot in
            // 데이터 중복 방지를 위해 초기화
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                
                userModel.setValuesForKeys(fchild.value as! [String : Any])
                
                if (userModel.uid == myUid) {
                    continue
                }
                
                self.array.append(userModel)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension SelectFriendViewController: UITableViewDelegate {
    
}

extension SelectFriendViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SelectFriendCell", for: indexPath) as! SelectFriendCell
        
        cell.labelName.text = array[indexPath.row].userName
        cell.imageviewProfile.kf.setImage(with: URL(string: array[indexPath.row].profileImageUrl!))
        return cell
    }
}

class SelectFriendCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var imageviewProfile: UIImageView!
    @IBOutlet weak var labelName: UILabel!
}
