//
//  ViewController.swift
//  miniProject
//
//  Created by seojin on 12/19/24.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var array: [Memo] = [Memo(title: "제목", content: "내용입니다.....ㅏ어ㅏㅣㄹ너어리ㅏ너이ㅏ러ㅏ"),
                         Memo(title: "제목2", content: "내용입니다.....ㅏ어ㅏㅣㄹ너어리ㅏ너이ㅏ러ㅏ"),
                         Memo(title: "제목3", content: "내용입니다.....ㅏ어ㅏㅣㄹ너어리ㅏ너이ㅏ러ㅏ")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
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

