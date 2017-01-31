//
//  ViewController.swift
//  CoreDataLoginChallenge
//
//  Created by Ahmed T Khalil on 1/23/17.
//  Copyright © 2017 kalikans. All rights reserved.
//

import UIKit
//you need the Core Data framework to use Core Data (lol)
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var salutation: UILabel!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var signUp: UIButton!
    @IBOutlet var updateUsername: UIButton!
    @IBOutlet var login: UIButton!
    @IBOutlet var logout: UIButton!
    @IBOutlet var updateMessage: UILabel!
    
    var loggedInUser = ""
    var loggedInUserPass = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: Any) {
        //check if in system (i.e. restore data)
        //first start by creating a request
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.returnsObjectsAsFaults = false
        
        //then try to retrieve results
        do{
            let results = try context.fetch(request)
            
            //was username found in database?
            var found: Bool = false
            
            
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let usernameDB = result.value(forKey: "username") as? String {
                        if username.text == usernameDB {
                            //it was found
                            found = true
                            if let passwordDB = result.value(forKey: "password") as? String {
                                if password.text == passwordDB {
                                    salutation.text = "Welcome, \(usernameDB)"
                                    
                                    loggedInUser = usernameDB
                                    loggedInUserPass = passwordDB
                                    //hide the sign up and login buttons
                                    //more elegant to change titles instead of using two buttons, but this project was done in parts
                                    login.isHidden = true
                                    signUp.isHidden = true
                                    //unhide the logout and update username buttons
                                    logout.isHidden = false
                                    updateUsername.isHidden = false
                                    updateMessage.isHidden = false
                                    break
                                }else {
                                    salutation.text = "Wrong Password"
                                    break
                                }
                            }
                        }
                    }
                }
                if !found{
                    salutation.text = "Please sign up"
                }
            }
        }catch{
            print("Something went wrong")
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        //add to database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //need a request to check if already in the database
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.returnsObjectsAsFaults = false
        //need this to add new stuff into the database
        let newUser = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context)
        //then try to retrieve results
        do{
            let results = try context.fetch(request)
            
            //was username found in database?
            var found: Bool = false
            
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let usernameDB = result.value(forKey: "username") as? String {
                        if username.text == usernameDB {
                            found = true
                            salutation.text = "\(usernameDB) is in the database already"
                        }
                    }
                }
            }
            
            if !found {
                newUser.setValue(username.text, forKey: "username")
                newUser.setValue(password.text, forKey: "password")
                
                do {
                    
                    try context.save()
                    
                }catch {
                    print("Something went wrong")
                }
            }
        }catch{
            
            print("Something went wrong")
            
        }
    }
    
    @IBAction func updateUsername(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "username = %@", loggedInUser)
        
        if password.text == loggedInUserPass && username.text != ""{
            do{
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        result.setValue(username.text!, forKey: "username")
                        salutation.text = "Change successful"
                    }
                    
                    do{
                        try context.save()
                    }catch{
                        print("Something went wrong")
                    }
                }
            }catch{
                print("Something went wrong")
            }
        }else if password.text != loggedInUserPass{
            salutation.text = "Enter correct password to update username"
        }else if username.text == ""{
            salutation.text = "Username can't be empty!"
        }
        
    }
    
    @IBAction func logout(_ sender: Any) {
        salutation.text = "Log Out Successful"
        loggedInUser = ""
        loggedInUserPass = ""
        
        logout.isHidden = true
        login.isHidden = false
        
        updateUsername.isHidden = true
        signUp.isHidden = false
        
        updateMessage.isHidden = true
    }
    
    
    //make it so that when you touch outside the keyboard, the keyboard goes away (end editing)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //self refers to the View Controller
        //view refers to the view that the View Controller is managing
        self.view.endEditing(true)
    }
    
    
    //keyboard shuts down when you press 'return'
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

