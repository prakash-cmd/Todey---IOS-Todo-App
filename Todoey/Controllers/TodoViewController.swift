//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class TodoViewController: SwipeTableViewController {
    
    var items = [Item]()
    var categoryType: Category? {
        didSet {
            loadItem()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemTextField = UITextField()
    let context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = categoryType?.name
        loadItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let colorHexValue = categoryType?.color {
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation COntroller does not exist") }
            if let navBarColor = UIColor(hexString: colorHexValue) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true) ]
                searchBar.backgroundColor = navBarColor
                searchBar.placeholder = " Search items"
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        let colourValue = CGFloat(indexPath.row) / CGFloat(items.count)
        cell.backgroundColor = UIColor(hexString: (categoryType?.color)!)?.darken(byPercentage: colourValue)
        cell.accessoryType = items[indexPath.row].done ? .checkmark : .none
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        items[indexPath.row].done = !items[indexPath.row].done
        tableView.deselectRow(at: indexPath, animated: true)
        saveItem()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Item", message: "Add new Item to the Todoey", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            print("Item Added to the list")
            let newItem = Item(context: self.context)
            newItem.title = self.itemTextField.text
            newItem.color = self.categoryType?.color
            newItem.done = false
            newItem.parentItem = self.categoryType
            self.items.append(newItem)
            self.saveItem()
            
        }
        
        let actionTwo = UIAlertAction(title: "Cancel", style: .destructive) { action in
            print("Item not added")
        }
        alert.addTextField { textField in
            textField.placeholder = "Add new item to list"
            self.itemTextField = textField
            
        }
        alert.addAction(action)
        alert.addAction(actionTwo)
        present(alert, animated: true) {
            
        }
    }
    
    override func updateDataModel(with indexpath: IndexPath) {
        context.delete(items[indexpath.row])
        items.remove(at: indexpath.row)
        DispatchQueue.main.async {
            try! self.context.save()
        }
    }
    //MARK: - CoreData Methods
    
    func saveItem() {
        do {
            try context.save()
        } catch {
            print("Error while saving to database \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    func loadItem(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        request.predicate = NSPredicate(format: "parentItem.name MATCHES %@", categoryType!.name!)
        do {
            items = try context.fetch(request)
        } catch {
            print("Error while getting data \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate

extension TodoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do {
            items = try context.fetch(request)
        } catch {
            print("Error while getting data \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count == 0  {
            loadItem()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
