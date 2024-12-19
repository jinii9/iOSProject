//
//  ViewController.swift
//  miniProject
//
//  Created by seojin on 12/19/24.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    var array: [Memo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        fetchDataFromFirestore()
    }
    
    // Firestore에서 데이터 가져오기
        func fetchDataFromFirestore() {
            db.collection("food").order(by: "createdAt", descending: true).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.array = [] // 데이터 초기화
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let title = data["title"] as? String, let content = data["content"] as? String {
                            self.array.append(Memo(title: title, content: content))
                        }
                    }
                    
                    // 테이블 뷰 갱신
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = array[indexPath.row].title
        cell.contentLabel.text = array[indexPath.row].content
        
        return cell
    }
    
    

}

