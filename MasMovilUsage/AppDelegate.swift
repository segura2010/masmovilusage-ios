//
//  AppDelegate.swift
//  MasMovilUsage
//
//  Created by Alberto on 25/9/16.
//  Copyright © 2016 Alberto. All rights reserved.
//

import UIKit

import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var session = WCSession.default()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if WCSession.isSupported(){
            session.delegate = self
            session.activate()
        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

// Watch app Communication
extension AppDelegate: WCSessionDelegate {
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "activationDidCompleteWith"), object: self, userInfo: ["msg":"activationDidCompleteWith"]))
    }

    /*
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let tokenReply = ["token": LocalStorageManager.sharedInstance.getToken() as AnyObject]
        if let reference = message["token"] as? Int {
            replyHandler(tokenReply)
        }else{
            replyHandler(tokenReply)
        }
    }*/
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let tokenReply = ["token": LocalStorageManager.sharedInstance.getToken() as AnyObject]
        if let reference = message["token"] as? Int {
            
            let token = LocalStorageManager.sharedInstance.getToken()
            MasMovilApi.sharedInstance.validateToken(token, onCompletion: { (err, result) in
                
                if((err) != nil)
                {
                    session.sendMessage(["error":"1"], replyHandler: nil, errorHandler: nil)
                    return;
                }
                
                let actualMonth = MasMovilApi.sharedInstance.getStartOfMonth()
                MasMovilApi.sharedInstance.getConsumeResume(actualMonth, onCompletion: { (err2, jsonResult) in
                    
                    if((err2) != nil)
                    {
                        session.sendMessage(["error":"2"], replyHandler: nil, errorHandler: nil)
                        return;
                    }
                    
                    if let status = jsonResult?["status"]{
                        // Normally, when we doesnt have an open session, we receive:
                        // {"status":500,"message":"unauthorized"}
                        session.sendMessage(["error":"500"], replyHandler: nil, errorHandler: nil)
                    }
                    
                    if let receivedData = jsonResult?["data"] as? [String: AnyObject]
                    {
                        LocalStorageManager.sharedInstance.saveConsume(receivedData)
                        
                        session.sendMessage(["data":receivedData], replyHandler: nil, errorHandler: nil)
                    }
                    
                })
                
            })
            
        }else if let reference = message["datalimit"] as? Int {
            let limit = LocalStorageManager.sharedInstance.getDataLimit()
            session.sendMessage(["datalimit":limit], replyHandler: nil, errorHandler: nil)
        }else{
            session.sendMessage(["token":tokenReply], replyHandler: nil, errorHandler: nil)
        }
    }
    
}

