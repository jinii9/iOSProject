//
//  AddViewController.swift
//  miniProject
//
//  Created by seojin on 12/19/24.
//

import UIKit
import FirebaseFirestore

class AddViewController: UIViewController {
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var contentTextview: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    var memo: Memo?
    var receivedSegmentIndex: Int?
    var receivedTabIndex: Int?
    let db = Firestore.firestore()
    
    let categoryMapping: [Int: String] = [
        0: "food",
        1: "drink",
        2: "networking",
        3: "company"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTextview.layer.borderWidth = 1.0
        contentTextview.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        contentTextview.layer.cornerRadius = 8.0
        
        if let memo = memo {
            titleTextfield.text = memo.title
            contentTextview.text = memo.content
        }
        
        if let receivedSegmentIndex = receivedSegmentIndex {
            segmentControl.selectedSegmentIndex = receivedSegmentIndex
        }
        
        if let tabIndex = receivedTabIndex {
            categorySegment.selectedSegmentIndex = tabIndex
        }
            
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if memo != nil {
            updateMemo()
        } else {
            addMemo()
        }
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func addMemo() {
        guard let title = titleTextfield.text, !title.isEmpty,
              let content = contentTextview.text, !content.isEmpty else {
            // 입력값이 비어있을 경우 처리
            print("제목과 내용을 입력해주세요")
            return
        }
        
        guard let category = Category(rawValue: categorySegment.selectedSegmentIndex)?.stringValue else {
            return
        }
        
        if segmentControl.selectedSegmentIndex == 0 {
            // memo 컬렉션에 데이터 추가
            let memoRef = db.collection("memo").addDocument(data: [
                "title": title,
                "content": content,
                "createdAt": FieldValue.serverTimestamp(), // 생성 시간도 저장
                "category": categoryMapping[categorySegment.selectedSegmentIndex] ?? ""
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully!")
                    // 성공적으로 저장되면 입력 필드 초기화
                    self.titleTextfield.text = ""
                    self.contentTextview.text = ""
                    
                    // 선택사항: 이전 화면으로 돌아가기
                }
            }
            db.collection("memo").document(memoRef.documentID).updateData(["id": memoRef.documentID]){ updateError in
                if let updateError = updateError {
                    print("Error updating document ID: \(updateError)")
                } else {
                    print("Document ID successfully updated")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else if segmentControl.selectedSegmentIndex == 1 {
            CoreDataManager.saveData(title: title, content: content, category: category)
            navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    func updateMemo() {
        if let memo = memo, let id = memo.id, let title = titleTextfield.text, let content = contentTextview.text, let category = Category(rawValue: categorySegment.selectedSegmentIndex)?.stringValue {
            
            if segmentControl.selectedSegmentIndex == 0 {
                if receivedSegmentIndex == 0 {
                    // Firestore 데이터 -> Firestore 업데이트
                    db.collection("memo").document(id).updateData([ "title":title, "content":content, "category": category]){ updateError in
                        if let updateError = updateError {
                            print("Error updating Memo: \(updateError)")
                        } else {
                            print("Memo successfully updated")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else if receivedSegmentIndex == 1 {
                    // Core Data -> Firestore로 이동
                    CoreDataManager.deleteData(id: id)
                    let memoRef = db.collection("memo").addDocument(data: [
                        "title": title,
                        "content": content,
                        "createdAt": FieldValue.serverTimestamp(), // 생성 시간도 저장
                        "category": category
                    ]) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added successfully!")
                        }
                    }
                    db.collection("memo").document(memoRef.documentID).updateData(["id": memoRef.documentID]){ updateError in
                        if let updateError = updateError {
                            print("Error updating document ID: \(updateError)")
                        } else {
                            print("Document ID successfully updated")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
            } else if segmentControl.selectedSegmentIndex == 1 {
                if receivedSegmentIndex == 0 {
                    // Firestore 데이터 -> Core Data로 이동
                    db.collection("memo").document(id).delete { error in
                        if let error = error {
                            print("Error deleting Memo from Firestore: \(error)")
                        } else {
                            CoreDataManager.saveData(title: title, content: content, category: category)
                            print("Memo successfully moved to Core Data")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else if receivedSegmentIndex == 1 {
                    // Core Data -> Core Data 업데이트
                    CoreDataManager.updateData(id: id, title: title, content: content, category: category)
                    print("Memo successfully updated in Core Data")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
