//
//  SecondViewController.swift
//  MasMovilUsage
//
//  Created by Alberto on 25/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var dataTxt: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SecondViewController.DismissKeyboard))
        view.addGestureRecognizer(tap)
        
        usernameTxt.text = LocalStorageManager.sharedInstance.getUsername()
        
        passwordTxt.text = LocalStorageManager.sharedInstance.getPassword()
        
        dataTxt.text = "\(LocalStorageManager.sharedInstance.getDataLimit())"
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func loginBtnClick(_ sender: AnyObject) {
        
        let username = usernameTxt.text!
        let password = passwordTxt.text!
        
        MasMovilApi.sharedInstance.login(username, password: password) { (err, result) in
            
            if((err) != nil)
            {
                print("Error!")
                return;
            }
            
            if let token = result?["token"]{
                LocalStorageManager.sharedInstance.saveUser(username, password: password, token:token as! String)
            }
            
        }
        
    }
    
    @IBAction func saveDataBtnClick(_ sender: AnyObject) {
        
        let data = Int(dataTxt.text!)
        LocalStorageManager.sharedInstance.saveDataLimit(data!)
        
    }
}

