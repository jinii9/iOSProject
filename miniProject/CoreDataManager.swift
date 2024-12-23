//
//  CoreDataManager.swift
//  CoreDataStudy4
//
//  Created by User on 12/23/24.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    private static let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("AppDelegate가 초기화되지 않았습니다.")
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    static func saveData(title: String, content: String, category: String) {
        guard let context = context else { return }
        guard let entity = NSEntityDescription.entity(
            forEntityName: "MyMemo", in: context
        ) else { return }
        
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(UUID().uuidString, forKey: "id")
        object.setValue(title, forKey: "title")
        object.setValue(content, forKey: "content")
        object.setValue(category, forKey: "category")
        object.setValue(Date(), forKey: "createAt")
        
        do {
            try context.save()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    static func fetchData() -> [MyMemo] {
        guard let context = context else { return [] }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyMemo")
        
        do {
            guard let memoList = try context.fetch(fetchRequest) as? [MyMemo] else { return [] }
            memoList.forEach {
                print($0.title ?? "")
            }
            return memoList
        } catch {
            print("error: \(error.localizedDescription)")
            return []
        }
    }
    
    static func updateData(id: String, title: String, content: String, category: String) {
        guard let context = context else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "MyMemo")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            guard let result = try? context.fetch(fetchRequest),
                  let object = result.first as? NSManagedObject else { return }
            object.setValue(title, forKey: "title")
            object.setValue(content, forKey: "content")
            object.setValue(category, forKey: "category")
            try context.save()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    static func deleteData(id: String) {
        guard let context = context else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "MyMemo")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)

        do {
            guard let result = try? context.fetch(fetchRequest),
                  let object = result.first as? NSManagedObject else { return }
            context.delete(object)

            try context.save()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}
