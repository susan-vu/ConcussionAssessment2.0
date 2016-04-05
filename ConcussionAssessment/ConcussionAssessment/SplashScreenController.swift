//
//  TableViewController.swift
//  ConcussionAssessment
//
//  Created by Yvone Chau on 2/22/16.
//  Copyright © 2016 PYKS. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
var database: DataModel = DataModel(persistentStoreCoordinator: appDelegate.persistentStoreCoordinator, managedObjectContext: appDelegate.managedObjectContext)
var currentScoreID: String?
var currentPlayerID: String?

class SplashScreenController: UITableViewController {
    
    
    var fullDiagnostic: UITableViewCell = UITableViewCell()
    var playerProfile: UITableViewCell = UITableViewCell()
    var individualTests: UITableViewCell = UITableViewCell()
    var currentScoreView: UITableViewCell = UITableViewCell()

    override func loadView() {
        super.loadView()
        
        // set the title
        self.title = "Splash Screen"
        
        self.fullDiagnostic.textLabel?.text = "Take Full Diagnostic"
        self.fullDiagnostic.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.fullDiagnostic.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        self.playerProfile.textLabel?.text = "View Player Profiles"
        self.playerProfile.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.playerProfile.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        self.individualTests.textLabel?.text = "Take Individual Tests"
        self.individualTests.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.individualTests.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        self.currentScoreView.textLabel?.text = "Current Score"
        self.currentScoreView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        self.currentScoreView.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
    
    
    // Return the number of sections
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Return the number of rows for each section in your static table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 0: return 4    // section 0 has 2 rows
        //case 1: return 1    // section 1 has 1 row
        default: fatalError("Unknown number of sections")
        }
    }
    
    // Return the row for the corresponding section and row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section) {
            case 0:
                switch(indexPath.row) {
                case 0: return self.fullDiagnostic   // section 0, row 0 is the first name
                case 1: return self.playerProfile    // section 0, row 1 is the last name
                case 2: return self.individualTests
                case 3: return self.currentScoreView
                    default: fatalError("Unknown row in section 0")
                }
            default: fatalError("Unknown section")
        }
    }
    
    // Configure the row selection code for any cells that you want to customize the row selection
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0:
                let lpp = MenuController(style: UITableViewStyle.Grouped)
                currentScoreID =  NSUUID().UUIDString
                database.insertNewScoreWithoutPlayer(currentScoreID!)
                self.navigationController?.pushViewController(lpp, animated:true)
                break;
            case 1:
                let ts = TestScreenController(style: UITableViewStyle.Grouped)
                self.navigationController?.pushViewController(ts, animated:true)
                break;
            
            case 2:
                let IndividualTestsView = IndividualTableViewController(style: UITableViewStyle.Grouped)
                currentScoreID =  NSUUID().UUIDString
                database.insertNewScoreWithoutPlayer(currentScoreID!)
                self.navigationController?.pushViewController(IndividualTestsView, animated:true)
                break;
            case 3:
                let ScoreBoardView = ScoreBoardController()
                self.navigationController?.pushViewController(ScoreBoardView, animated: true)
                break;
            default:
                fatalError("Unknow Row");
            }
            break;
        default:
            fatalError("Unknown Section")
            break;
        }
    }
 
}