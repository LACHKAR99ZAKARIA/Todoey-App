//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by zakaria lachkar on 30/03/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    var categorys = [Category]()
    
    //context pour la base de donnée
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //search Bar
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        
        //envoyer les items
        self.loadCat()
        
        //initialiser le search bar
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.searchBar.showsSearchResultsButton = true
        
        super.viewDidLoad()
    }

    
    
}

//MARK - les fonctions TODO
extension CategoryTableViewController{
    
    //MARK - le boutton ajouter
    @IBAction func addButtonPressed(_ sender: Any) {
            var textFierld = UITextField()
            let alert = UIAlertController(title: "ajouter un nouveau item Todoey", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "ajouter un Item", style: .default) { action in
                // after the add button
                if let safeText = textFierld.text {
                    var newCat = Category(context: self.context)
                    newCat.name = safeText
                    self.categorys.append(newCat)
                    self.saveCat()
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

//MARK -  les fonctions de tableView delegate
extension CategoryTableViewController: UIActionSheetDelegate{
    
    //MARK - set rows numbers
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorys.count
    }
    
    //MARK - remplire les cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a table view cell to return
        let cell = UITableViewCell(style: .default, reuseIdentifier: "TodoItemCell")
        //give the cell data
        let cat = categorys[indexPath.row]
        cell.textLabel?.text = cat.name
        return cell
    }
    
    //MARK - select Row fonction
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categorys[indexPath.row]
        }
    }
}

//MARK - les fonctions pour manipuler la Data
extension CategoryTableViewController {
    func saveCat()  {
        let encoder = PropertyListEncoder()
        do{
            try self.context.save()
        }catch{
            print("Error Saving Context")
        }
        self.tableView.reloadData()
    }
    
    func loadCat(with req : NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categorys = try self.context.fetch(req)
        }catch{
            print("Error featching Data")
        }
    }
}

//MARK - les fonctions de la search bar
extension CategoryTableViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.predicate = predicate
        let sortDesc = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortDesc]
        loadCat(with: request)
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCat()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            let request : NSFetchRequest<Category> = Category.fetchRequest()
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
            request.predicate = predicate
            let sortDesc = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortDesc]
            loadCat(with: request)
            tableView.reloadData()
        }
    }
}
