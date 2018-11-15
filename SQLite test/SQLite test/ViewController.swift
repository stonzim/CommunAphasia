//
//  ViewController.swift
//  SQLite test
//
//  Created by Mitchie Maluschnig on 7/05/18.
//  Copyright © 2018 Mitchie Maluschnig. All rights reserved.
//


//http://www.public-domain-photos.com/free-cliparts/
//http://www.freestockphotos.biz/photos.php?c=silhouette&o=popular&s=0&lic=all&a=all&set=all
import UIKit
import SQLite

class ViewController: UIViewController {
 
    var database: Connection!
    
    let usersTable = Table("users")
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    //Test storing of a list (e.g. image relationships)
    let list = [Expression<String>("item")]
    var listSize = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do {
        let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            let db = try Connection(fileUrl.path)
            self.database = db
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createTable(_ sender: Any) {
        print("CREATE TAPPED")
        
        let createTable = self.usersTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.email, unique: true)
        }
        do {
            try self.database.run(createTable)
            print("Created Table")
        } catch {
            print(error)
        }
    }
    @IBAction func inputUser() {
        print("INPUT TAPPED")
        let alert = UIAlertController(title: "Input User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "Name" }
        alert.addTextField { (tf) in tf.placeholder = "Email" }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in guard let name = alert.textFields?.first?.text, let email = alert.textFields?.last?.text
            else { return }
            print(name)
            print(email)
            
            let insertUser = self.usersTable.insert(self.name <- name, self.email <- email)
            do {
                try self.database.run(insertUser)
                print("Inserted User")
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //prints table to debug console, and makes a alert of the latest row
    @IBAction func listUsers() {
        print("LIST TAPPED")
        let alert = UIAlertController(title: "Print", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        do {
            let users = try self.database.prepare(self.usersTable)
            for user in users{
                
                alert.message = "UserID: \(user[self.id]), Name: \(user[self.name]), Email: \(user[self.email])"
                
                print("UserID: \(user[self.id]), Name: \(user[self.name]), Email: \(user[self.email])")
                //trying to print list (not sure if functional)
                for i in 0..<listSize {
                    print(" List: \(user[self.list[i]])")
                }
               //end of print list
            }
        } catch {
            print(error)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func updateUsers() {
        print("UPDATE TAPPED")
        let alert = UIAlertController(title: "Update User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "User ID" }
        alert.addTextField { (tf) in tf.placeholder = "Name" }
        alert.addTextField { (tf) in tf.placeholder = "Email" /*; tf.insertText("")*/}
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in guard
            let userIdString = alert.textFields?.first?.text,
            let userID = Int(userIdString),
            let email = alert.textFields?.last?.text,
            let name = alert.textFields?[1].text
            else { return }
            print(userIdString)
            print(name)
            print(email)
            
            let user = self.usersTable.filter(self.id == userID)
            let updateUser = user.update(self.email <- email, self.name <- name)
            do {
                try self.database.run(updateUser)
                print("Updated User")
            } catch {
                print(error)
            }
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)

    }
    @IBAction func deleteUser() {
        print("DELETE TAPPED")
        let alert = UIAlertController(title: "Delete User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "User ID" }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in guard
            let userIdString = alert.textFields?.first?.text,
            let userID = Int(userIdString)
            else { return }
            print(userIdString)
            
            let user = self.usersTable.filter(self.id == userID)
            let deleteUser = user.delete()
            do {
                try self.database.run(deleteUser)
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)

    }
    //trying to add items to a list (currently crashes app)
    @IBAction func addToList() {
        let alert = UIAlertController(title: "add to list", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "User ID" }
        alert.addTextField { (tf) in tf.placeholder = "item" }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in guard
            let userIdString = alert.textFields?.first?.text,
            let userID = Int(userIdString),
            let item = alert.textFields?.last?.text
            else { return }
            print(userID)
            print(item)
            
            let user = self.usersTable.filter(self.id == userID)
            let insertItem = user.update(self.list[self.listSize] <- item)
            self.listSize += 1
            do {
                try self.database.run(insertItem)
                print("Inserted Item")
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

