//
//  OperationView.swift
//  NSOperationExample
//
//  Created by RHVALL on 07/08/2015.
//  Copyright © 2015 . All rights reserved.
//

import UIKit


@IBDesignable class OperationView : UIView, OperationObserver
{
    @IBOutlet weak var processLabel: UILabel!
    
    @IBOutlet weak var processState: UIView!
    
    var view: UIView!
    
    static func loadViewFromNib() -> OperationView {
        
        let bundle = NSBundle.mainBundle()
        let nib = UINib(nibName: "OperationView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! OperationView
        
        return view
    }
    
    func changeLabel(label : String)
    {
        processLabel.text = label;
    }
    
    func changeState(newState : State)
    {
        var color = UIColor.blackColor()
        switch newState
        {
            /// The `Operation` is ready to begin evaluating conditions.
        case .Pending : color = UIColor.brownColor()
            
            /// The `Operation` is evaluating conditions.
        case .EvaluatingConditions : color = UIColor.yellowColor()
            
            /**
            The `Operation`'s conditions have all been satisfied, and it is ready
            to execute.
            */
        case .Ready : color = UIColor.greenColor()
            
            /// The `Operation` is executing.
        case .Executing : color = UIColor.blueColor()
            
            /**
            Execution of the `Operation` has finished, but it has not yet notified
            the queue of this.
            */
        case .Finishing : color = UIColor.orangeColor()
            
            /// The `Operation` has finished executing.
        case .Finished : color = UIColor.magentaColor()
            // Default == Innitialized state
        default : color = UIColor.blackColor()
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.processState.backgroundColor = color
        }
    }
    
    func operationDidStart(operation: Operation)
    {
        changeState(.Pending)
    }
    
    /// Invoked when `Operation.produceOperation(_:)` is executed.
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation)
    {
        changeState(.Ready)
    }
    
    /**
    Invoked as an `Operation` finishes, along with any errors produced during
    execution (or readiness evaluation).
    */
    func operationDidFinish(operation: Operation, errors: [NSError])
    {
        changeState(.Finishing)
        NSThread.sleepForTimeInterval(Double(1))
        if self.tag == 0 { dispatch_async(dispatch_get_main_queue()) { self.removeFromSuperview() } }
    }
    
    func operationDidCancel(operation: Operation, error: NSError?)
    {
        
    }
}