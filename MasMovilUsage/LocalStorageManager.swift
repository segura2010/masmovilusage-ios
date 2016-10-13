//
//  LocalStorageManager.swift
//  MasMovilUsage
//
//  Created by Alberto on 12/10/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import Foundation

class LocalStorageManager {
    static let sharedInstance = LocalStorageManager()
    
    let DEFAULTS_NAME = "group.masmovilusage"
    
    
    func getUsername() -> String
    {
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        if let username = defaults?.string(forKey: "username") {
            return username
        }
        else{
            return ""
        }
    }
    
    func getPassword() -> String
    {
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        if let password = defaults?.string(forKey: "password") {
            return password
        }
        else{
            return ""
        }
    }
    
    func getToken() -> String
    {
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        if let token = defaults?.string(forKey: "token") {
            return token
        }
        else{
            return ""
        }
    }
    
    func getDataLimit() -> Int
    {
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        if let d = defaults?.integer(forKey: "datalimit") {
            return d
        }
        else{
            return 0
        }
    }
    
    func saveDataLimit(_ data:Int)
    {
        
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        defaults?.setValue(data, forKey: "datalimit")
        
        defaults?.synchronize()
    }
    
    func getConsume() -> [String:AnyObject]
    {
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        if let d = defaults?.dictionary(forKey: "consume") {
            return d as [String : AnyObject]
        }
        else{
            return [String : AnyObject]()
        }
    }
    
    func saveConsume(_ data:[String:AnyObject])
    {
        
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        defaults?.setValue(data, forKey: "consume")
        
        defaults?.synchronize()
    }
    
    func saveUser(_ username:String, password:String, token:String)
    {
        
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        defaults?.setValue(username, forKey: "username")
        defaults?.setValue(password, forKey: "password")
        defaults?.setValue(token, forKey: "token")
        
        defaults?.synchronize()
    }
    
}
