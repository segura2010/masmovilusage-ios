//
//  TodayViewController.swift
//  MasMovilUsageWidget
//
//  Created by Alberto on 25/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet var dataUsage: UILabel!
    @IBOutlet var voiceUsage: UILabel!
    @IBOutlet var totalUsage: UILabel!
    
    @IBOutlet var dataBar: UIProgressView!
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        
        self.indicatorView.hidesWhenStopped = true
        self.indicatorView.startAnimating()
        
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
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func getAndDrawUsageInfo()
    {
        DispatchQueue.main.async(execute: { () -> Void in
            self.indicatorView.startAnimating()
        })
        
        let actualMonth = MasMovilApi.sharedInstance.getStartOfMonth()
        MasMovilApi.sharedInstance.getConsumeResume(actualMonth, onCompletion: { (err2, jsonResult) in
            
            if((err2) != nil)
            {
                return;
            }
            
            if let status = jsonResult?["status"]{
                // Normally, when we doesnt have an open session, we receive:
                // {"status":500,"message":"unauthorized"}
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.dataUsage.text = "ERR"
                    self.voiceUsage.text = "ERR"
                    self.totalUsage.text = "ERR"
                    
                    self.dataBar.setProgress(0.0, animated: true)
                })
            }
            
            if let receivedData = jsonResult?["data"] as? [String: AnyObject]
            {
                
                // Main UI Thread
                DispatchQueue.main.async(execute: { () -> Void in
                    self.dataUsage.text = "\(receivedData["data"]!)"
                    self.voiceUsage.text = "\(receivedData["voice"]!)"
                    self.totalUsage.text = "\(receivedData["consume"]!)"
                    
                    let percent = (receivedData["data"] as! Float) / 1000.0
                    
                    self.dataBar.setProgress(percent, animated: true)
                    
                    if percent >= 0.85
                    {
                        self.dataUsage.textColor = UIColor.red
                        self.dataBar.progressTintColor = UIColor.red
                    }
                    else if percent >= 0.65
                    {
                        self.dataUsage.textColor = UIColor.orange
                        self.dataBar.progressTintColor = UIColor.orange
                    }
                    else if percent >= 0.5
                    {
                        self.dataUsage.textColor = UIColor.yellow
                        self.dataBar.progressTintColor = UIColor.yellow
                    }
                    
                })
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.indicatorView.stopAnimating()
            })
            
        })
    }
    
}
