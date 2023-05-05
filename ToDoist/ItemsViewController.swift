//
//  ViewController.swift
//  ToDoist
//
//  Created by Parker Rushton on 10/15/22.
//

import UIKit

class ItemsViewController: UIViewController, UITableViewDelegate {
    
    enum TableSection: Int {
        case incomplete, complete
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var selectedList: ToDoList?
    
    private let itemManager = ItemManager.shared
    private lazy var datasource: ItemDataSource = {
        let datasource = ItemDataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.reuseIdentifier) as! ItemTableViewCell
            cell.update(with: item)
            cell.delegate = self
            return cell
        }
        datasource.delegate = self
        return datasource
    }()

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = datasource
        generateNewSnapshot()
    }

    // MARK: - Table View Functions
    
}


// MARK: - Item Cell Delegate

extension ItemsViewController: ItemCellDelegate {

    func completeButtonPressed(item: Item) {
        itemManager.toggleItemCompletion(item)
        generateNewSnapshot()
    }
    
}


// MARK: - ItemDelegate

extension ItemsViewController: ItemDelegate {
    
    func deleteItem(at indexPath: IndexPath) {
        guard let selectedList = selectedList else { return }
        let section = TableSection(rawValue: indexPath.section)!
        let item: Item
        switch section {
        case .incomplete:
            item = ItemManager.shared.fetchIncompleteItems(for: selectedList)[indexPath.row]
        case .complete:
            item = ItemManager.shared.fetchCompletedItems(for: selectedList)[indexPath.row]
        }

        // Remove the item from the itemManager
        ItemManager.shared.remove(item)

        // Update the data source and delete the row from the table view
        generateNewSnapshot(deletingRowAt: indexPath)
    }
}


// MARK: - TextField Delegate

extension ItemsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty, let selectedList = selectedList else { return true }
        itemManager.createNewItem(with: text, for: selectedList)
        textField.text = ""
        generateNewSnapshot()
        return true
    }
    
}


// MARK: - Private

private extension ItemsViewController {
    
    func generateNewSnapshot(deletingRowAt indexPathToDelete: IndexPath? = nil) {
        guard let selectedList = selectedList else {return}
        // Create a snapshot
        var snapshot = NSDiffableDataSourceSnapshot<TableSection, Item>()
        // Fetch incomplete and completed items from Core Data
        let incompleteItems = itemManager.fetchIncompleteItems(for: selectedList)
        let completedItems = itemManager.fetchCompletedItems(for: selectedList)
        
        // If there are incomplete items to show, add them to the tableview
        if !incompleteItems.isEmpty {
            snapshot.appendSections([.incomplete])
            snapshot.appendItems(incompleteItems, toSection: .incomplete)
        }
        // If there are completed items to show, add them to the tableview
        if !completedItems.isEmpty {
            snapshot.appendSections([.complete])
            snapshot.appendItems(completedItems, toSection: .complete)
        }
        // Apply the snapshot
        DispatchQueue.main.async {
            self.datasource.apply(snapshot, animatingDifferences: true) {
                if let indexPath = indexPathToDelete {
                    // Animate the deletion of the row from the table view
                    self.tableView.performBatchUpdates({
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }, completion: { _ in
                        // Reload the table view to ensure correct display of data
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
}
