//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController , UIActionSheetDelegate , UISearchBarDelegate  {
    
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    let defaults = UserDefaults.standard
    var itemArray = [Item]()
    let searchController = UISearchController(searchResultsController: nil)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
            itemArray = items
        } else {
            itemArray = [Item]()
        } */
        // Do any additional setup after loading the view.
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.searchBar.showsSearchResultsButton = true
        print(dataFilePath)
        tableView.delegate = self
    }
}

//MARK - Tableview Data

extension TodoListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a table view cell to return
        let cell = UITableViewCell(style: .default, reuseIdentifier: "TodoItemCell")
        //let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        //give the cell data
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        /* if item.done == true{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        */
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        
        //return the cell
        return cell
    }
}

//MARK - TableView Delegate Methode

extension TodoListViewController {
    //after clicking
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Handle the user's click on the cell here
        //print(self.itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveItems()
        
        /* if self.itemArray[indexPath.row].done == true{
            self.itemArray[indexPath.row].done = false
        }else{
            self.itemArray[indexPath.row].done = true
        } */
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}

//MARK - ajouter un nouveau element

extension TodoListViewController {
    @IBAction func addClick(_ sender: UIBarButtonItem) {
        var textFierld = UITextField()
        let alert = UIAlertController(title: "ajouter un nouveau item Todoey", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "ajouter un Item", style: .default) { action in
            // after the add button
            if let safeText = textFierld.text {
                var newItem = Item(context: self.context)
                newItem.title = safeText
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemArray.append(newItem)
                //self.defaults.set(self.itemArray, forKey: "TodoListArray")
                self.saveItems()
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Crée une Nouveau Item"
            textFierld = alertTextField
            
        }
        alert.addAction(action)
        
        present(alert, animated: true , completion: nil)
    }
}

//MARK - Core Data save/load Items


extension TodoListViewController {
    func saveItems()  {
        let encoder = PropertyListEncoder()
        do{
            
            try self.context.save()
            //let data = try encoder.encode(self.itemArray)
            //try data.write(to: self.dataFilePath!)
        }catch{
            print("Error Saving Context")
        }
        self.tableView.reloadData()
    }
    
    /* func loadItem(with req : NSFetchRequest<Item> = Item.fetchRequest(),predicate: NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate{
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,addtionalPredicate])
        }else{
            req.predicate = categoryPredicate
        }
        
        do{
            itemArray = try self.context.fetch(req)
        }catch{
            print("Error featching Data")
        }
    } */
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
            
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            
            if let addtionalPredicate = predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
            } else {
                request.predicate = categoryPredicate
            }

            
            do {
                itemArray = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }
            
            tableView.reloadData()
            
        }
    
    
    /*
    func loadItems(){
        if let Data = try? Data(contentsOf: dataFilePath!){
            let decoder = PropertyListDecoder()
            do{
                self.itemArray = try decoder.decode([Item].self, from: Data)
            }catch{
                print("Error Decoding")
            }
        }
        
    }*/
}

extension TodoListViewController{
    /* func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        let sortDesc = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDesc]
        loadItem(with: request)
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItem()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.predicate = predicate
            let sortDesc = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [sortDesc]
            loadItem(with: request)
            tableView.reloadData()
        }
    }*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

            let request : NSFetchRequest<Item> = Item.fetchRequest()
        
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request, predicate: predicate)
            
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchBar.text?.count == 0 {
                loadItems()
                
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
              
            }else{
                let request : NSFetchRequest<Item> = Item.fetchRequest()
            
                let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
                
                request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                
                self.loadItems(with: request, predicate: predicate)
            }
        }
}
