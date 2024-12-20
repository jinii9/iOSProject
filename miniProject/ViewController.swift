//
//  ViewController.swift
//  miniProject
//
//  Created by seojin on 12/19/24.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
    var array: [Memo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                        if let id = data["id"] as? String, let title = data["title"] as? String, let content = data["content"] as? String {
                            self.array.append(Memo(id: id, title: title, content: content))
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMemo = array[indexPath.row]
        print("selectedMemo: \(selectedMemo)")
        performSegue(withIdentifier: "showMemoDetail", sender: selectedMemo)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completionHandler) in
                if let self = self, let documentId = self.array[indexPath.row].id {
                    // Firestore 문서 삭제
                    db.collection("food").document(documentId).delete { error in
                        if let error = error {
                            print("Firestore에서 문서 삭제 실패: \(error.localizedDescription)")
                            completionHandler(false) // 실패 알림
                        } else {
                            print("Firestore에서 문서 삭제 성공")
                            // 로컬 데이터 삭제
                            self.array.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                            completionHandler(true) // 성공 알림
                        }
                    }
                } else {
                    print("Firestore 문서 ID가 nil이거나 self가 nil입니다.")
                    completionHandler(false) // 실패 알림
                }
            }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMemoDetail", let addMemoVC = segue.destination as? AddViewController, let selectedMemo = sender as? Memo {
                addMemoVC.memo = selectedMemo
        }
    }

}

