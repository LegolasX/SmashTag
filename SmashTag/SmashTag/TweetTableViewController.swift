//
//  TweetTableViewController.swift
//  NewSmashtag
//
//  Created by Legolas on 16/8/17.
//  Copyright © 2016年 Legolas. All rights reserved.
//

import UIKit
import Twitter
import CoreData
class TweetTableViewController: UITableViewController,UITextFieldDelegate{
    
    var managedObjectContext : NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    var searchText: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchText
            
            if NSUserDefaults.standardUserDefaults().valueForKey("isFirstOpen") != nil //这个值压根为nil的话意味着这之前未曾进行过查询或者是删除了
            {
                var tempHistory = NSUserDefaults.standardUserDefaults().valueForKey("history") as? [String]
                tempHistory?.insert(searchText!, atIndex: 0)
                NSUserDefaults.standardUserDefaults().setObject(tempHistory!, forKey: "history")
            } else {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstOpen")
                var searchHistory : [String] = []
                searchHistory.append(searchText!)
                NSUserDefaults.standardUserDefaults().setObject(searchHistory, forKey: "history")
                
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // searchText = "#paulrocks"
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    private  var twitterRepuest: Twitter.Request? {
        if let query = searchText where !query.isEmpty {
            return Twitter.Request(search: query + " -filter:retweets", count: 200)
        }
        return nil
    }
    private var lastTwitterRequest: Twitter.Request?
    
    @IBOutlet weak var Spinner: UIActivityIndicatorView!
    private func searchForTweets()
    {
        if let request = twitterRepuest {
            lastTwitterRequest = request
            Spinner.startAnimating()
            request.fetchTweets{ [weak weakSelf = self] newTweets in//这块是怎么就进入了新的线程了？暂时没看懂 //补：paul说了 这个fectchTweet的函数本身就是异步的 因此要在里面进入主线程
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updateDatabase(newTweets)
                            
                        }
                    }
                    self.Spinner.stopAnimating()
                }
            }
        }
    }
    // MARK: - Table view data source
    
    private func updateDatabase(newTweets: [Twitter.Tweet]) {
        managedObjectContext?.performBlock{
            for twitterInfo in newTweets {
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!) // 这个函数是有返回值的，但是我们并不需要 swift也不会检查这个 但是还在前面加上一个_ = 表示我们知道他是返回的 但是We Don‘t Care！
            }
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("error here:\(error)")
            }
            self.printDatabaseStatistics()
            print("done printing")
        }
    }
    
    private func printDatabaseStatistics() {
        managedObjectContext?.performBlock {
            if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results.count) TwitterUsers")
            }
            // a more efficient way to count objects ...
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) Tweets")
        }    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    private struct StoryBoard {
        static let TweetCellIdentifier = "Tweet"
        static let ShowCellDetailIdentifier = "ShowCellDetail"
        static let TweeterIdentifier = "Tweeter"
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.TweetCellIdentifier, forIndexPath: indexPath)
      //  print(indexPath.row)
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TableViewCell {
        //    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)) {//进入新的线程
                tweetCell.tweet = tweet
                dispatch_async(dispatch_get_main_queue()) {//回到主线程
                    cell.tag = indexPath.row
                }//这两句就是多线程带来的问题 如果把tweet的赋值放在主线程里 由于要将所有头像加载完成后才能滑动 滑动时就会带来卡顿 如果把tweet的赋值放在新的线程里 那么不再会有卡顿 而是流畅的滑动后才缓慢的加载图片 但是由于tableView会自动的reuse所有的Cell 导致加载过的头像图片也必须要重新加载 这个时候就需要缓存的出现了 而我目前还不能解决缓存的问题
                //同时 微博里头像的即便是第一次加载 也是不会如此卡顿的 也许用到了预加载的模式 which is more complicated 妈妈呀
                //回忆起paul说这些只是GCD的冰山一角 想来也是 多线程显然是非常重要的一部分。。
                
        //    }
        }
        // Configure the cell...
        
        return cell
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryBoard.ShowCellDetailIdentifier {
            if let ivc = segue.destinationViewController as? DetailTableViewController {
                ivc.tweetForDetail = tweets[0][(sender?.tag)!]
            }
        }
        if segue.identifier == StoryBoard.TweeterIdentifier {
            if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
                print("test")
            }
        }
        
    }
    private func makingSomePreparationWork(let ivc: UITableViewController) {
        
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
