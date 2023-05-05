//
//  ListOfToDoListsTableViewController.swift
//  ToDoist
//
//  Created by David Granger on 5/3/23.
//

import UIKit

class ListOfToDoListsTableViewController: UITableViewController {

    var list: [ToDoList] = []
    
    //MARK: - IBActions
    
    @IBAction func addList(_ sender: Any) {
        let alert = UIAlertController(title: "Create new List?", message: "Name your list", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            if let textField = alert.textFields?.first, let textFieldResultText = textField.text {
                ToDoList.createNewToDoList(textFieldResultText)
                self.list = ToDoList.fetchToDoLists()
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(okAction)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter the List Name"
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBSegueAction func displayList(_ coder: NSCoder) -> ItemsViewController? {
        let itemsViewController = ItemsViewController(coder: coder)
        if let indexPath = tableView.indexPathForSelectedRow {
            itemsViewController?.selectedList = list[indexPath.row]
        }
        return itemsViewController
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        list = ToDoList.fetchToDoLists()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoIdentifier", for: indexPath) as! ToDoListTableViewCell
        cell.titleOfList.text = list[indexPath.row].title
        cell.numberOfItems.text = "\(list[indexPath.row].itemsArray.count) items"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let listToDelete = list[indexPath.row]
            ToDoList.removeList(listToDelete)
            list = ToDoList.fetchToDoLists()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
