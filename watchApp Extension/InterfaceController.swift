//
//  InterfaceController.swift
//  watchApp Extension
//
//  Created by Alberto on 19/10/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var dataUsage: WKInterfaceLabel!
    @IBOutlet var voiceUsage: WKInterfaceLabel!
    @IBOutlet var totalUsage: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        let dataLimit = LocalStorageManager.sharedInstance.getDataLimit()
        let token = LocalStorageManager.sharedInstance.getToken()
        MasMovilApi.sharedInstance.validateToken(token, onCompletion: { (err, result) in
            
            if((err) != nil)
            {
                return;
            }
            
            self.getAndDrawUsageInfo()
            
        })
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    func drawUsageInfo(_ receivedData:[String:AnyObject])
    {
        print("RECEIVED: \(receivedData["data"]!) MB")
        self.dataUsage.setText("\(receivedData["data"]!) MB")
        self.voiceUsage.setText("\(receivedData["voice"]!) Min.")
        self.totalUsage.setText("\(receivedData["consume"]!) €")
        
        /*
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
         */
    }
    
    func drawUsageInfoError()
    {
        self.dataUsage.setText("Data: ERR")
        self.voiceUsage.setText("Voice: ERR")
        self.totalUsage.setText("Total: ERR")
    }
    
    func getAndDrawUsageInfo()
    {
        let actualMonth = MasMovilApi.sharedInstance.getStartOfMonth()
        MasMovilApi.sharedInstance.getConsumeResume(actualMonth, onCompletion: { (err2, jsonResult) in
            
            if((err2) != nil)
            {
                DispatchQueue.main.async(execute: { () -> Void in
                    self.drawUsageInfoError()
                })
                return;
            }
            
            if let status = jsonResult?["status"]{
                // Normally, when we doesnt have an open session, we receive:
                // {"status":500,"message":"unauthorized"}
                // Main UI Thread
                DispatchQueue.main.async(execute: { () -> Void in
                    self.drawUsageInfoError()
                })
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

}
