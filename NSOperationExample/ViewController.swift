//
//  ViewController.swift
//  NSOperationExample
//
//  Created by RHVALL on 07/08/2015.
//  Copyright © 2015 . All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, OperationObserver {

    @IBOutlet weak var OptionsBtn: UIButton!
    @IBOutlet weak var provisionBtn: UIButton!
    @IBOutlet weak var mailBtn: UIButton!
    @IBOutlet weak var calBtn: UIButton!
    @IBOutlet weak var contactsBtn: UIButton!
    @IBOutlet weak var galBtn: UIButton!
    @IBOutlet weak var concurrencyLbl: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var optionsView: OperationView!
    @IBOutlet weak var provisionView: OperationView!
    
    var listProcess : [OperationView] = []
    
//----------------------------------------
//	UIVIEW
//----------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        optionsView = changeNameState(optionsView, name: "Options")
        provisionView = changeNameState(provisionView, name: "Provision")

        let optionsObserver = optionsView as OperationObserver
        let provisionObserver = provisionView as OperationObserver
        SyncEngine.prepare(optionsObserver, provisionObserver: provisionObserver)
        
        increaseConcurrency(galBtn)
        
        SyncEngine.startEngine()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//----------------------------------------
//	TABLE VIEW DELEGATE
//----------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        listProcess = listProcess.filter { $0.processState.backgroundColor != UIColor.orangeColor() }
        return listProcess.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("OperationCell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "OperationCell")
        }
        
        let oprView = listProcess[indexPath.row]
        
        cell!.contentView.addSubview(oprView);
        
        return cell!
    }
    
//----------------------------------------
//	PROCESS VIEW
//----------------------------------------

    func changeNameState(oprView : OperationView, name : String,  state : State = .Initialized) -> OperationView
    {
        let frame = oprView.frame
        oprView.removeFromSuperview()
        let otherOprView = OperationView.loadViewFromNib()
        otherOprView.changeLabel(name)
        otherOprView.changeState(state)
        otherOprView.backgroundColor = UIColor.whiteColor()
        otherOprView.frame = frame
        otherOprView.tag = 200
        self.view.addSubview(otherOprView)
        return otherOprView
    }

//----------------------------------------
//	IBACTIONS
//----------------------------------------
    
    @IBAction func optionsTapped(sender: UIButton)
    {
        SyncEngine.runOptions(optionsView as OperationObserver)
    }
    
    @IBAction func provisionTapped(sender: UIButton)
    {
        SyncEngine.runProvision(provisionView as OperationObserver)
    }
    
    @IBAction func mailTapped(sender: UIButton)
    {
        let oprView = OperationView.loadViewFromNib()
        oprView.changeLabel("Mail")
        listProcess.append(oprView)
        SyncEngine.runSyncMail(oprView, obs2: self)
        
        tableView.reloadData()
    }
    
    @IBAction func calendarTapped(sender: UIButton)
    {
        let oprView = OperationView.loadViewFromNib()
        oprView.changeLabel("Cal")
        listProcess.append(oprView)
        SyncEngine.runSyncCal(oprView, obs2: self)
        
        tableView.reloadData()
    }
    
    @IBAction func contactsTapped(sender: UIButton)
    {
        let oprView = OperationView.loadViewFromNib()
        oprView.changeLabel("Contacts")
        listProcess.append(oprView)
        SyncEngine.runSyncContacts(oprView, obs2: self)
        
        tableView.reloadData()
    }
    
    @IBAction func galTapped(sender: UIButton)
    {
        let oprView = OperationView.loadViewFromNib()
        oprView.changeLabel("GAL")
        listProcess.append(oprView)
        SyncEngine.runGAL(oprView, obs2: self)
        
        tableView.reloadData()
    }
    
    @IBAction func increaseConcurrency(sender: UIButton)
    {
        let val = SyncEngine.add1ToConcurrency()
        concurrencyLbl.text = "Conc \(val)"
    }
    
    @IBAction func decreaseConcurrency(sender: UIButton)
    {
        let val = SyncEngine.remove1ToConcurrency()
        concurrencyLbl.text = "Conc \(val)"
    }
    
//----------------------------------------
//	OPERATION OBSERVER
//----------------------------------------
    
    func operationDidStart(operation: Operation)
    { dispatch_async(dispatch_get_main_queue()) { self.tableView.reloadData() } }
    
    func operation(operation: Operation, didProduceOperation newOperation: NSOperation)
    { dispatch_async(dispatch_get_main_queue()) { self.tableView.reloadData() } }
    
    func operationDidFinish(operation: Operation, errors: [NSError])
    { dispatch_async(dispatch_get_main_queue()) { self.tableView.reloadData() } }
    
    func operationDidCancel(operation: Operation, error: NSError?)
    { }
}

