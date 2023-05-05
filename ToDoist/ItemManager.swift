//
//  ItemManager.swift
//  ToDoist
//
//  Created by Parker Rushton on 10/21/22.
//

import Foundation
import CoreData

class ItemManager {
    static let shared = ItemManager()
    
    var allItems = [Item]()
    var items: [Item] {
        allItems.filter { $0.completedAt == nil }.sorted(by: { $0.sortDate >  $1.sortDate })
    }
    var completedItems: [Item] {
        allItems.filter { $0.completedAt != nil }.sorted(by: { $0.sortDate >  $1.sortDate })
    }

    
    // Funcs
    
    func fetchIncompleteItems(for list: ToDoList) -> [Item] {
        let items = list.itemsArray
        let incompleteItems = items.filter { !$0.isCompleted }
        PersistenceController.shared.saveContext()
        return incompleteItems
    }
    
    func fetchCompletedItems(for list: ToDoList) -> [Item] {
        let items = list.itemsArray
        let completedItems = items.filter { $0.isCompleted }
        PersistenceController.shared.saveContext()
        return completedItems
    }
    
    func createNewItem(with title: String, for list: ToDoList) {
        let newItem = Item(context: PersistenceController.shared.viewContext)
        
        newItem.id = UUID().uuidString
        newItem.title = title
        newItem.createdAt = Date()
        newItem.completedAt = nil
        newItem.toDoList = list
        
        PersistenceController.shared.saveContext()
    }
    
    func toggleItemCompletion(_ item: Item) {
        item.completedAt = item.isCompleted ? nil : Date()
        PersistenceController.shared.saveContext()
    }
    
    func remove(_ item: Item) {
        let context = PersistenceController.shared.viewContext
        context.delete(item)
        PersistenceController.shared.saveContext()
    }

}
