//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Avinash Kumar on 15/07/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    
    var categories = [Category]()
    var itemTextField = UITextField()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Controller does not exist") }

    }
       
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a Category", message: "Add a new category to your Todoey", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add category", style: .default) { action in
            let newCategory = Category(context: self.context)
            newCategory.name = self.itemTextField.text
            newCategory.color = UIColor.randomFlat().hexValue()
            self.categories.append(newCategory)
            self.saveCategory()
            
        }
        
        let actionTwo = UIAlertAction(title: "Cancel", style: .destructive) { action in
            
        }
        
        alert.addTextField { searchTextField in
            searchTextField.placeholder = "Add a new category"
            self.itemTextField = searchTextField
        }
        
        alert.addAction(action)
        alert.addAction(actionTwo)
        present(alert, animated: true)

    }
    
    override func updateDataModel(with indexpath: IndexPath) {
        context.delete(categories[indexpath.row])
        self.categories.remove(at: indexpath.row)
        print(categories)
        DispatchQueue.main.async {
            try! self.context.save()
        }
    }
    
    // MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        cell.backgroundColor = UIColor(hexString: categories[indexPath.row].color!)
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)

        return cell
    }
    
    //MARK: - TableView Deleagte Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoViewController
        if let indexpath = tableView.indexPathForSelectedRow {
            destinationVC.categoryType = categories[indexpath.row]
            
        }
    }
    
    
    //MARK: - Core Data Methods
    
    func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Error While saving Categories \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategory() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error while loading Categories \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    
}
