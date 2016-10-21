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
    @IBOutlet var indicator: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var circularProgressBar: MBCircularProgressBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let consumeCache = LocalStorageManager.sharedInstance.getConsume()
        if let data = consumeCache["data"]{
            self.drawUsageInfo(consumeCache)
        }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        let token = LocalStorageManager.sharedInstance.getToken()
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
    
    func drawUsageInfo(_ receivedData:[String:AnyObject])
    {
        activityIndicator.stopAnimating()
        self.dataUsage.text = "\(receivedData["data"]!) MB"
        self.voiceUsage.text = "\(receivedData["voice"]!) Minutos"
        self.totalUsage.text = "\(receivedData["consume"]!) €"
        
        let dataLimit = LocalStorageManager.sharedInstance.getDataLimit()
        let dataUsage = CGFloat(receivedData["data"] as! Float)
        
        let percent = (receivedData["data"] as! Float) / Float(dataLimit)
        
        if percent >= 0.85
        {
            self.circularProgressBar.progressColor = UIColor.red
        }
        else if percent >= 0.65
        {
            self.circularProgressBar.progressColor = UIColor.orange
        }
        else if percent >= 0.5
        {
            self.circularProgressBar.progressColor = UIColor.yellow
        }
        else{
            self.circularProgressBar.progressColor = UIColor.cyan
        }
        
        self.circularProgressBar.maxValue = CGFloat(LocalStorageManager.sharedInstance.getDataLimit())
        self.circularProgressBar.setValue(dataUsage, animateWithDuration: 1.0)
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
                LocalStorageManager.sharedInstance.saveConsume(receivedData)
                
                // Main UI Thread
                DispatchQueue.main.async(execute: { () -> Void in
                    self.drawUsageInfo(receivedData)
                })
            }
            
        })
    }

    @IBAction func reloadBtnClick(_ sender: AnyObject) {
        
        activityIndicator.startAnimating()
        
        self.circularProgressBar.setValue(0.0, animateWithDuration: 1.0)
        
        self.getAndDrawUsageInfo()
        
    }

}

