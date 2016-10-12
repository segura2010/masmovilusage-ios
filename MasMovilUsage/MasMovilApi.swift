//
//  MasMovilApi.swift
//  MasMovilUsage
//
//  Created by Alberto on 25/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import Foundation


// For callbacks
typealias ServiceResponse = (NSError?, [String:AnyObject]?) -> Void
typealias ServiceBoolResponse = (NSError?, Bool) -> Void

class MasMovilApi {
    static let sharedInstance = MasMovilApi()
    
    let BASE_URL = "https://yosoymas.masmovil.es/api_v2/"
    let LOGIN_URL = "https://yosoymas.masmovil.es/rest/validateUser/"
    let VALIDATE_TOKEN_URL = "https://yosoymas.masmovil.es/validateJson/?s="
    
    func get(_ url:String, onCompletion:@escaping ServiceResponse)
    {
        let finalUrl = "\(BASE_URL)\(url)"
        var request = URLRequest(url: URL(string: finalUrl)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        do {
            request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
            request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                do{
                    //print("Response: \(response)")
                    let res = response as! HTTPURLResponse
                    //print(res)
                    
                    let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    //print("Body: \(strData)")
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? [String:AnyObject]
                    
                    if res.statusCode == 200{
                        onCompletion(nil, json)
                    }else{
                        onCompletion(NSError(domain: "get", code: 999, userInfo: nil), nil)
                    }
                }catch{
                    print("Error:\n \(error)")
                    onCompletion(NSError(domain: "get", code: 998, userInfo: nil), nil)
                }
                
            })
            
            task.resume()
        }catch{
            print("Error:\n \(error)")
            return
        }
    }
    
    func login(_ username:String, password:String, onCompletion:@escaping ServiceResponse)
    {
        
        let encodedPassword = (password.data(using: String.Encoding.utf8))?.base64EncodedString()
        let params = "data={\"username\":\"\(username)\",\"userpass\":\"\(encodedPassword!)\"}"
        
        var request = URLRequest(url: URL(string: LOGIN_URL)!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        do {
            request.httpBody = params.data(using: String.Encoding.utf8)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                do{
                    //print("Response: \(response)")
                    let res = response as! HTTPURLResponse
                    //print(res)
                    
                    let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    //print("Body: \(strData)")
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? [String:AnyObject]
                    
                    if res.statusCode == 200{
                        onCompletion(nil, json)
                    }else{
                        onCompletion(NSError(domain: "login", code: 999, userInfo: nil), nil)
                    }
                }catch{
                    print("Error:\n \(error)")
                    onCompletion(NSError(domain: "login", code: 998, userInfo: nil), nil)
                }
                
            })
            
            task.resume()
        }catch{
            print("Error:\n \(error)")
            return
        }
    }
    
    func loginWithDefaults(onCompletion:@escaping ServiceResponse)
    {
        let username = LocalStorageManager.sharedInstance.getUsername()
        let password = LocalStorageManager.sharedInstance.getPassword()
        
        if(username != "" && password != "")
        {
            self.login(username, password: password, onCompletion: onCompletion)
        }
        else{
            onCompletion(NSError(domain: "loginWithDefaults", code: 997, userInfo: nil), nil)
        }
    }
    
    func validateToken(_ token:String, onCompletion:@escaping ServiceResponse)
    {
        let finalUrl = "\(VALIDATE_TOKEN_URL)\(token)"
        var request = URLRequest(url: URL(string: finalUrl)!)
        let noRedirects = URLSessionNoRedirects()
        let session = URLSession.shared //URLSession(configuration: .ephemeral, delegate: noRedirects, delegateQueue: .main) // To stop redirects!!
        request.httpMethod = "GET"
        
        do {
            request.addValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
            request.addValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
            
            let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
                do{
                    //print("Response: \(response)")
                    let res = response as! HTTPURLResponse
                    //print(res)
                    
                    if res.statusCode == 200 || res.statusCode == 302{
                        onCompletion(nil, nil)
                    }else{
                        onCompletion(NSError(domain: "get", code: 999, userInfo: nil), nil)
                    }
                }catch{
                    print("Error:\n \(error)")
                    onCompletion(NSError(domain: "get", code: 998, userInfo: nil), nil)
                }
                
            })
            
            task.resume()
        }catch{
            print("Error:\n \(error)")
            return
        }
    }
    
    
    func getConsumeResume(_ startTimeStamp:String, onCompletion:@escaping ServiceResponse)
    {
        let url = "services/consume/resume/\(startTimeStamp)"
        get(url, onCompletion: onCompletion)
    }
    
    func getConsumeResume(_ startTimeStamp:String, endTimeStamp:String, onCompletion:@escaping ServiceResponse)
    {
        let url = "services/consume/resume/\(startTimeStamp)/\(endTimeStamp)"
        get(url, onCompletion: onCompletion)
    }
    
    func getConsumeDetails(_ startTimeStamp:String, onCompletion:@escaping ServiceResponse)
    {
        let url = "services/consume/details/\(startTimeStamp)"
        get(url, onCompletion: onCompletion)
    }
    
    func getConsumeDetails(_ startTimeStamp:String, endTimeStamp:String, onCompletion:@escaping ServiceResponse)
    {
        let url = "services/consume/details/\(startTimeStamp)/\(endTimeStamp)"
        get(url, onCompletion: onCompletion)
    }
    
    
    // Aux functions
    
    func getStartOfMonth() -> String
    {
        let date = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.month, Calendar.Component.year], from: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let someDateTime = formatter.date(from: "\(year!)/\(month!)/01 00:01")
        
        
        return "\(Int(someDateTime!.timeIntervalSince1970))"
    }
    
}


class URLSessionNoRedirects: NSObject, URLSessionDelegate, URLSessionTaskDelegate{
    
    // Handles redirection
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        print("noRedirects called!")
        // Stops the redirection, and returns (internally) the response body.
        completionHandler(nil)
    
    }
    
}
