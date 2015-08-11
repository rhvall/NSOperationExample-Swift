//
//  CommandFactory.swift
//  NSOperationExample
//
//  Created by RVALL on 07/08/2015.
//  Copyright © 2015. All rights reserved.
//

import Foundation

let kSleepTime = 3

struct CommandFactory
{
    static func optionsCommand() -> Command
    {
        return  OptionsCommand()
    }
    
    static func provisionCommand() -> Command
    {
        return ProvisionCommand()
    }
    
    static func mailSync() -> Command
    {
        return MailSync()
    }
    
    static func calSync() -> Command
    {
        return CalendarSync()
    }
    
    static func contactsSync() -> Command
    {
        return CalendarSync()
    }
    
    static func galCommand() -> Command
    {
        return GAL()
    }
    
    
}

class Command : Operation
{
    let cmdDescription : String
    
    override init()
    {
        let cmdID = Int(arc4random_uniform(100))
        cmdDescription = "\(self.dynamicType):\(cmdID)"
        
        super.init()
    }
    
    func oprDescription() -> String
    {
        return cmdDescription
    }
    
    override internal func evaluateConditions()
    {
        assert(state == .Pending && !cancelled, "evaluateConditions() was called out-of-order")
        
        state = .EvaluatingConditions
        
        OperationConditionEvaluator.evaluate(conditions, operation: self) { failures in
            self._internalErrors.extend(failures)
            if failures.count < 1
            {
                self.state = .Ready
            }
            else
            {
                self.state = .Pending
            }
        }
    }

    override func execute()
    {
        NSLog("Executing %@", oprDescription())
        
        NSThread.sleepForTimeInterval(Double(kSleepTime))
        
        let tryError = Int(arc4random_uniform(100))

        NSLog("Processed %@ in %d", oprDescription(), kSleepTime)

        if tryError <= 10
        {
            let error = NSError(domain: "Sync returned 401", code: SyncErrors.NoProvision.rawValue, userInfo: nil)
            finishWithError(error)
        }
        else { finish() }
    }
    
    override func finished(errors: [NSError])
    {
        if errors.count > 0 { NSLog("Executing %@ had errors %@", oprDescription(), errors) }
    }

}

class OptionsCondition : OperationCondition
{
    static let name = "OptionsCondition"
    static let isMutuallyExclusive = true
    
    func dependencyForOperation(operation: Operation) -> NSOperation?
    {
        return nil
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void)
    {
        if SyncEngine.isValidOptions()
        {
            completion(.Satisfied)
        }
        else
        {
            completion(.Hold)
        }
    }
}

class ProvisionCondition : OperationCondition
{
    static let name = "ProvisionCondition"
    static let isMutuallyExclusive = false
    
    func dependencyForOperation(operation: Operation) -> NSOperation?
    {
        if SyncEngine.isValidOptions()
        {
            return nil
        }
        else
        {
            return OptionsCommand()
        }
    }
    
    func evaluateForOperation(operation: Operation, completion: OperationConditionResult -> Void)
    {
        if SyncEngine.isValidProvision()
        {
            completion(.Satisfied)
        }
        else
        {
            completion(.Hold)
        }
    }
}

class OptionsCommand : Command
{
    override func finished(errors: [NSError])
    {
        if errors.count > 0
        {
            NSLog("Executing %@ had errors %@", oprDescription(), errors)
            SyncEngine.optionsRan(false)
        }
        else
        {
            SyncEngine.optionsRan(true)
        }
    }
}

class ProvisionCommand : Command
{
    override init()
    {
        super.init()
        addCondition(OptionsCondition())
    }
    
    override func finished(errors: [NSError])
    {
        if errors.count > 0
        {
            NSLog("Executing %@ had errors %@", oprDescription(), errors)
            SyncEngine.provisionRan(false)
        }
        else
        {
            SyncEngine.provisionRan(true)
        }
    }
}

class SyncCommand : Command
{
    override init()
    {
        super.init()
        addCondition(ProvisionCondition())
    }
}

class MailSync : SyncCommand
{
}

class CalendarSync : SyncCommand
{
}

class Contacts : SyncCommand
{
    
}

class GAL : Command
{
    override init()
    {
        super.init()
        addCondition(ProvisionCondition())
        self.queuePriority = .VeryHigh
    }
}