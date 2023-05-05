//
//  ToDoList.swift
//  ToDoist
//
//  Created by David Granger on 5/2/23.
//

import Foundation
import CoreData

extension ToDoList {
    var itemsArray: [Item] {
        do {
            let allItems = try PersistenceController.shared.viewContext.fetch(Item.fetchRequest())
            let itemsForList = allItems.filter { $0.toDoList == self }
            return itemsForList
        } catch let error {
            print("Error fetching array of items from CoreData. Error: \(error)")
            return []
        }
    }
    
    static func createNewToDoList(_ title: String) {
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "ToDoList", into: PersistenceController.shared.viewContext) as! ToDoList
        newItem.title = title
        ToDoList.saveLists()
    }
    
    static func fetchToDoLists() -> [ToDoList] { //R retrieve
        let fetchRequest = ToDoList.fetchRequest()
        let context = PersistenceController.shared.viewContext
        let fetchedLists = try? context.fetch(fetchRequest)
        return fetchedLists ?? []
    }
    
    static func saveLists() { //U update
        do {
            try PersistenceController.shared.viewContext.save()
        } catch let error {
            print("Error saving lists. \(error)")
        }
    }
    
    static func removeList(_ list: ToDoList) {
        PersistenceController.shared.viewContext.delete(list)
        PersistenceController.shared.saveContext()
    }
}
