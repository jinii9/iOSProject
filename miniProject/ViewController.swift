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
    var firebaseMemos: [Memo] = [] // 공유 메모
    var localMemos: [Memo] = []     // 내 메모
    var currentMemos: [Memo] = []
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDataFromFirestore()
        fetchDataFromLocalStorage()
    }
    
    // Firestore에서 데이터 가져오기
    func fetchDataFromFirestore() {
        if let selectedIndex = tabBarController?.selectedIndex,
           let selectedCategory = Category(rawValue: selectedIndex)?.stringValue {
            db.collection("memo").whereField("category", isEqualTo: selectedCategory).order(by: "createdAt", descending: true).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.firebaseMemos = [] // 데이터 초기화
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let id = data["id"] as? String, let title = data["title"] as? String, let content = data["content"] as? String {
                            self.firebaseMemos.append(Memo(id: id, title: title, content: content))
                        }
                    }
                    
                    // 테이블 뷰 갱신
                    DispatchQueue.main.async {
                        if self.segmentControl.selectedSegmentIndex == 0 {
                            self.currentMemos = self.firebaseMemos
                            print(self.currentMemos)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
    func fetchDataFromLocalStorage() {
        let myMemos = CoreDataManager.fetchData()
        localMemos = []
        if let selectedTabIndex = tabBarController?.selectedIndex,
           let selectedCategory = Category(rawValue: selectedTabIndex)?.stringValue {
            // 카테고리에 맞는 데이터만 필터링
            for myMemo in myMemos {
                if myMemo.category == selectedCategory {
                    let memo = Memo(id: myMemo.id, title: myMemo.title, content: myMemo.content, category: myMemo.category)
                    localMemos.append(memo)
                }
            }
        }
        if self.segmentControl.selectedSegmentIndex == 1 {
            self.currentMemos = self.localMemos
            self.tableView.reloadData()
        }
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // 공유 메모 선택
            currentMemos = firebaseMemos
        case 1: // 내 메모 선택
            currentMemos = localMemos
        default:
            break
        }
        // 테이블 뷰 갱신
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMemos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        cell.titleLabel.text = currentMemos[indexPath.row].title
        cell.contentLabel.text = currentMemos[indexPath.row].content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMemo = currentMemos[indexPath.row]
        print("selectedMemo: \(selectedMemo)")
        performSegue(withIdentifier: "showMemoDetail", sender: selectedMemo)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (_, _, completionHandler) in
            if let self = self, let documentId = self.currentMemos[indexPath.row].id {
                // Firestore 문서 삭제
                db.collection("memo").document(documentId).delete { error in
                    if let error = error {
                        print("Firestore에서 문서 삭제 실패: \(error.localizedDescription)")
                        completionHandler(false) // 실패 알림
                    } else {
                        print("Firestore에서 문서 삭제 성공")
                        // 로컬 데이터 삭제
                        self.currentMemos.remove(at: indexPath.row)
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
        if let addMemoVC = segue.destination as? AddViewController {
            if segue.identifier == "showMemoDetail", let selectedMemo = sender as? Memo {
                // 수정 버튼 동작: 선택된 메모와 현재 세그먼트 및 탭 상태 전달
                addMemoVC.memo = selectedMemo
            } else if segue.identifier == "addMemo" {
                // 추가 버튼 동작: 현재 세그먼트 및 탭 상태만 전달
                addMemoVC.memo = nil // 새로운 메모
            }
            
            // 현재 세그먼트와 탭 상태 전달
            addMemoVC.receivedSegmentIndex = segmentControl.selectedSegmentIndex
            addMemoVC.receivedTabIndex = tabBarController?.selectedIndex
        }
    }
    
}

