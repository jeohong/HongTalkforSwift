//
//  MainViewController.swift
//  HongTalkforSwift
//
//  Created by 홍정민 on 2023/03/29.
//

import UIKit
import SnapKit
import Firebase
import FirebaseDatabase

class PeopleViewController: UIViewController {
    var array: [UserModel] = []
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        Database.database().reference().child("users").observe(.value) { snapshot in
            // 데이터 중복 방지를 위해 초기화
            self.array.removeAll()
            
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                
                userModel.setValuesForKeys(fchild.value as! [String : Any])
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
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
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController")
        self.navigationController?.pushViewController(chatVC!, animated: true)
    }
}

// DataSource
extension PeopleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let imageView = UIImageView()
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10)
            make.height.width.equalTo(50)
        }
                
        URLSession.shared.dataTask(with: URL(string: array[indexPath.row].profileImageUrl!)!) { data, response, error in
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data!)
                imageView.layer.cornerRadius = imageView.frame.size.width / 2
                imageView.clipsToBounds = true
            }
        }.resume()
        
        let label = UILabel()
        cell.addSubview(label)
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
