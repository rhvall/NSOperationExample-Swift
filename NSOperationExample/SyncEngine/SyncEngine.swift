//
//  SyncEngine.swift
//  NSOperationExample
//
//  Created by RHVALL on 07/08/2015.
//  Copyright © 2015 . All rights reserved.
//

import Foundation

enum SyncErrors: Int
{
    case NoOptions = 400
    case NoProvision = 401
    case Unknown = 500
}

class SyncEngine : Operation, OperationObserver
{
    private static let watchdog : SyncEngine = SyncEngine();
    private let oprQueue : OperationQueue = OperationQueue();
    let user : String
    let pass : String
    
    var provisionStatus : Bool = false
    var optionsStatus : Bool = false
    
    private init(credentials : Dictionary<String,String> = ["user" : "EmptyUser", "pass" : "EmptyPass"])
    {
        guard let dicUuser = credentials["user"],
            let dicPass = credentials["pass"] else
        {
            user = "EmptyUser"
            pass = "EmptyPass"
            return
        }
        
        user = dicUuser
        pass = dicPass
    }
    
    static func prepare(optionsObserver : OperationObserver, provisionObserver : OperationObserver)
    {
        watchdog.oprQueue.maxConcurrentOperationCount = 0
        
        let options = OptionsCommand()
        options.addObserver(optionsObserver)
        options.addObserver(watchdog)
        watchdog.oprQueue.addOperation(options)
        
        let provision = ProvisionCommand()
        provision.addObserver(provisionObserver)
        provision.addObserver(watchdog)
        watchdog.oprQueue.addOperation(provision)
    }
    
    static func startEngine()
    {
        let asyncDispatch = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
        dispatch_async(asyncDispatch) {
            while(watchdog.ready != true){}
            watchdog.execute()
        }
    }
    
    static func runOptions(observer : OperationObserver)
    {
        if watchdog.optionsStatus == true { return }
        
        let cmd = CommandFactory.optionsCommand()
        cmd.addObserver(observer)
        cmd.addObserver(watchdog)
        watchdog.oprQueue.addOperation(cmd)
    }
    
    static func runProvision(observer : OperationObserver)
    {
        if watchdog.provisionStatus == true { return }
        
        let cmd = CommandFactory.provisionCommand()
        cmd.addObserver(observer)
        cmd.addObserver(watchdog)
        watchdog.oprQueue.addOperation(cmd)
    }
    
    static func runSyncMail(observer : OperationObserver, obs2 : OperationObserver)
    {
        let cmd = CommandFactory.mailSync()
        cmd.addObserver(observer)
        cmd.addObserver(obs2)
        cmd.addObserver(watchdog)
        watchdog.oprQueue.addOperation(cmd)
    }
    
    static func runSyncCal(observer : OperationObserver, obs2 : OperationObserver)
    {
        let cmd = CommandFactory.calSync()
        cmd.addObserver(observer)
        cmd.addObserver(obs2)
        cmd.addObserver(watchdog)
        watchdog.oprQueue.addOperation(cmd)
    }
    
    static func runSyncContacts(observer : OperationObserver, obs2 : OperationObserver)
    {
        let cmd = CommandFactory.contactsSync()
        cmd.addObserver(observer)
        cmd.addObserver(obs2)
        cmd.addObserver(watchdog)
        watchdog.oprQueue.addOperation(cmd)
    }
    
    static func runGAL(observer : OperationObserver, obs2 : OperationObserver)
    {
        let cmd = CommandFactory.galCommand()
        cmd.addObserver(observer)
        cmd.addObserver(obs2)
        cmd.addObserver(watchdog)
        watchdog.oprQueue.addOperation(cmd)
    }
    
    static func isValidProvision() -> Bool
    {
        return watchdog.provisionStatus
    }
    
    static func isValidOptions() -> Bool
    {
        return watchdog.optionsStatus
    }
    
    static func provisionRan(cmdStatus : Bool)
    {
        watchdog.provisionStatus = cmdStatus
    }
    
    static func optionsRan(cmdStatus : Bool)
    {
        watchdog.optionsStatus = cmdStatus
    }
    
    static func add1ToConcurrency() -> Int
    {
        watchdog.oprQueue.maxConcurrentOperationCount += 1
        return watchdog.oprQueue.maxConcurrentOperationCount;
    }
    
    static func remove1ToConcurrency() -> Int
    {
        if (watchdog.oprQueue.maxConcurrentOperationCount >= 1)
        { watchdog.oprQueue.maxConcurrentOperationCount -= 1 }
        
        return watchdog.oprQueue.maxConcurrentOperationCount
    }

    internal override func execute() {
        
        NSLog("Running watchdog")
        
        while(true)
        {
            
        }
    }
    
//----------------------------------------
//	OPERATOR OBSERVER
//----------------------------------------

    func operationDidStart(operation: Operation)
    { }
    
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation)
    { }
    
    func operationDidFinish(operation: Operation, errors: [NSError])
    {
        guard let error = errors.first else { return }
        
        if error.code == SyncErrors.NoProvision.rawValue
        {
            let observer = operation.observers.first!
            SyncEngine.runProvision(observer)
        }
        else if error.code == SyncErrors.NoOptions.rawValue
        {
            let observer = operation.observers.first!
            SyncEngine.runOptions(observer)
        }
    }
    
    func operationDidCancel(operation: Operation, error: NSError?)
    { }
    
//----------------------------------------
//	UI PROCESS VIEW
//----------------------------------------
    
    static func numberOfProcesses() -> Int
    {
        return watchdog.oprQueue.operationCount
    }

}