//
//  HistoryTableViewController.swift
//  NewSmashtag
//
//  Created by Legolas on 16/9/9.
//  Copyright © 2016年 Legolas. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  print("viewDidLoad")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    override func viewWillAppear(animated: Bool) {
    //    searchHistory?.append("cc")
        tableView.reloadData()
       // print("viewWillAppear")
    }
    override func viewDidAppear(animated: Bool) {
      //  print("viewDidAppear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    var itemsCount : Int {
        if let history = searchHistory {
            return history.count
        } else {
            return 0
        }
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemsCount
    }
    var searchHistory: [String]? {
        get{
            if let history = NSUserDefaults.standardUserDefaults().valueForKey("history") as? [String] {
                return history
            } else {
                return nil
            }
        }
    }
    
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("History", forIndexPath: indexPath)
     cell.textLabel?.text = searchHistory![ indexPath.row]
     return cell
     }
 
    
    
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
 
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var tempHistory = NSUserDefaults.standardUserDefaults().valueForKey("history") as? [String]
            tempHistory?.removeAtIndex(indexPath.row)
            NSUserDefaults.standardUserDefaults().setObject(tempHistory, forKey: "history")
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     
    
    
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let searchForHashtagMVC = segue.destinationViewController as? TweetTableViewController,
            let cell = sender as? UITableViewCell,
            let index = tableView.indexPathForCell(cell) {
            searchForHashtagMVC.searchText = searchHistory?[(index.row)]
        }
       
    }
 
    
}
