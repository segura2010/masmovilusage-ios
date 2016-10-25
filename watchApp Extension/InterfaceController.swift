//
//  InterfaceController.swift
//  watchApp Extension
//
//  Created by Alberto on 19/10/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import WatchKit
import Foundation

import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var dataUsage: WKInterfaceLabel!
    @IBOutlet var voiceUsage: WKInterfaceLabel!
    @IBOutlet var totalUsage: WKInterfaceLabel!
    @IBOutlet var loadingLbl: WKInterfaceLabel!
    
    // Communication Session
    var sess = WCSession.default()
    
    // vars..
    var dataLimit = 1000
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        sess.delegate = self
        sess.activate()
        
        addMenuItem(with: .resume, title: "Refresh", action: #selector(reloadData))
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func reloadData(){
        if sess.isReachable{
            sess.sendMessage(["token":0], replyHandler: nil, errorHandler: nil)
            sess.sendMessage(["datalimit":0], replyHandler: nil, errorHandler: nil)
            loadingLbl.setHidden(false)
        }
    }
    
    
    func drawUsageInfo(_ receivedData:[String:AnyObject])
    {
        loadingLbl.setHidden(true)
        self.dataUsage.setText("Data: \(receivedData["data"]!) MB")
        self.voiceUsage.setText("Voice: \(receivedData["voice"]!) Min.")
        self.totalUsage.setText("Total: \(receivedData["consume"]!) €")
        
        let dataUsage = CGFloat(receivedData["data"] as! Float)
        
        let percent = (receivedData["data"] as! Float) / Float(dataLimit)
        
        if percent >= 0.85
        {
            self.dataUsage.setTextColor(UIColor.red)
        }
        else if percent >= 0.65
        {
            self.dataUsage.setTextColor(UIColor.orange)
        }
        else if percent >= 0.5
        {
            self.dataUsage.setTextColor(UIColor.yellow)
        }
        else{
            self.dataUsage.setTextColor(UIColor.white)
        }
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
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        if activationState == .activated{
            loadingLbl.setHidden(false)
            session.sendMessage(["token":0], replyHandler: nil, errorHandler: nil)
            session.sendMessage(["datalimit":0], replyHandler: nil, errorHandler: nil)
        }else{
            print("Session not activated !!")
            DispatchQueue.main.async(execute: { () -> Void in
                self.drawUsageInfoError()
            })
        }
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        if let reference = message["data"] as? [String : Any] {
            self.drawUsageInfo(reference as [String : AnyObject])
        }else if let reference = message["datalimit"] as? Int {
            self.dataLimit = reference
        }else if let reference = message["error"] as? String {
            print(reference)
            self.drawUsageInfoError()
        }
        
    }

}
