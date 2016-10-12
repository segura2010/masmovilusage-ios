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
    
    func saveUser(_ username:String, password:String, token:String)
    {
        
        let defaults = UserDefaults(suiteName: DEFAULTS_NAME)
        
        defaults?.setValue(username, forKey: "username")
        defaults?.setValue(password, forKey: "password")
        defaults?.setValue(token, forKey: "token")
        
        defaults?.synchronize()
    }
    
}