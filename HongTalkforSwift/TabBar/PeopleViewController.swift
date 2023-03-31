//
//  MainViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/29.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher

class PeopleViewController: UIViewController {
    var array: [UserModel] = []
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
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
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PeopleViewTableCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.bottom.left.right.equalTo(view)
        }
    }
}

// Delegate
extension PeopleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        // 채팅할 대상의 uid 값을 넘겨줌
        chatVC?.destinationUid = self.array[indexPath.row].uid
        
        self.navigationController?.pushViewController(chatVC!, animated: true)
    }
}

// DataSource
extension PeopleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PeopleViewTableCell
        
        let imageView = cell.imageview!
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10)
            make.height.width.equalTo(50)
        }
        
        // Kingfisher 사용
        let url = URL(string: array[indexPath.row].profileImageUrl!)
        imageView.layer.cornerRadius = 50 / 2
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: url)
        
        // 킹피셔 라이브러리로 대체
        //        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { data, response, error in
        //            DispatchQueue.main.async {
        //                imageView.image = UIImage(data: data!)
        //                imageView.layer.cornerRadius = imageView.frame.size.width / 2
        //                imageView.clipsToBounds = true
        //            }
        //        }.resume()
        
        let label = cell.label!
        label.snp.makeConstraints { make in
            make.centerY.equalTo(cell)
            make.left.equalTo(imageView.snp.right).offset(20)
        }
        
        label.text = array[indexPath.row].userName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

class PeopleViewTableCell: UITableViewCell {
    var imageview: UIImageView! = UIImageView()
    var label: UILabel! = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
