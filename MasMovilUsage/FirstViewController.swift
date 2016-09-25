//
//  FirstViewController.swift
//  MasMovilUsage
//
//  Created by Alberto on 25/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet var dataUsage: UILabel!
    @IBOutlet var voiceUsage: UILabel!
    @IBOutlet var totalUsage: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let token = MasMovilApi.sharedInstance.getToken()
        MasMovilApi.sharedInstance.validateToken(token, onCompletion: { (err, result) in
            
            if((err) != nil)
            {
                return;
            }
            
            self.getAndDrawUsageInfo()
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAndDrawUsageInfo()
    {
        let actualMonth = MasMovilApi.sharedInstance.getStartOfMonth()
        MasMovilApi.sharedInstance.getConsumeResume(actualMonth, onCompletion: { (err2, jsonResult) in
            
            if((err2) != nil)
            {
                return;
            }
            
            if let status = jsonResult?["status"]{
                // Normally, when we doesnt have an open session, we receive:
                // {"status":500,"message":"unauthorized"}
            }
            
            if let receivedData = jsonResult?["data"] as? [String: AnyObject]
            {
                
                // Main UI Thread
                DispatchQueue.main.async(execute: { () -> Void in
                    self.dataUsage.text = "\(receivedData["data"]!) MB"
                    self.voiceUsage.text = "\(receivedData["voice"]!) Minutos"
                    self.totalUsage.text = "\(receivedData["consume"]!) €"
                })
            }
            
        })
    }

    @IBAction func reloadBtnClick(_ sender: AnyObject) {
        
        self.dataUsage.text = "..."
        self.voiceUsage.text = "..."
        self.totalUsage.text = "..."
        
        self.getAndDrawUsageInfo()
        
    }

}

