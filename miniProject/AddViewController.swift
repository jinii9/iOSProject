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
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTextview.layer.borderWidth = 1.0
        contentTextview.layer.borderColor = UIColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1.0).cgColor
        contentTextview.layer.cornerRadius = 8.0
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let title = titleTextfield.text, !title.isEmpty,
              let content = contentTextview.text, !content.isEmpty else {
            // 입력값이 비어있을 경우 처리
            print("제목과 내용을 입력해주세요")
            return
        }
        
        // food 컬렉션에 데이터 추가
        db.collection("food").addDocument(data: [
            "title": title,
            "content": content,
            "createdAt": FieldValue.serverTimestamp() // 생성 시간도 저장
        ]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully!")
                // 성공적으로 저장되면 입력 필드 초기화
                self.titleTextfield.text = ""
                self.contentTextview.text = ""
                
                // 선택사항: 이전 화면으로 돌아가기
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
