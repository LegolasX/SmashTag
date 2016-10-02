//
//  DetailTableViewController.swift
//  Smashtag
//
//  Created by Legolas on 16/8/20.
//  Copyright © 2016年 Stanford University. All rights reserved.
//

import UIKit
import Twitter
class DetailTableViewController: UITableViewController {
    
    let headerName: [String] =  ["Image","Hashtag","Mention","URL","User"]
    var sectionHeaderExistence: [Bool] = [false,false,false,false,true]
    private struct StoryBoard {
        static let ImageCellIdentifier = "Image"
        static let TextCellIdentifier = "Text"
        static let URLCellIdentifier = "URL"
        static let GoBackSedue = "GoBack"
    }
    var tweetForDetail: Twitter.Tweet? {//得到推特的数据之后就会计算
        didSet {
            sectionHeaderExistence = [false,false,false,false,true]
            numberOfRowsInSection = [0,0,0,0,1]
            if let image = tweetForDetail?.media where image.count>0 {
                sectionHeaderExistence[0]=true
                numberOfRowsInSection[0] = image.count
            }
            if let hashtag = tweetForDetail?.hashtags where hashtag.count>0{
                sectionHeaderExistence[1]=true
                numberOfRowsInSection[1] = hashtag.count
            }
            if let mention = tweetForDetail?.userMentions where mention.count>0 {
                sectionHeaderExistence[2]=true
                numberOfRowsInSection[2] = mention.count
            }
            if let url = tweetForDetail?.urls where url.count>0 {
                sectionHeaderExistence[3]=true
                numberOfRowsInSection[3] = url.count
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        tableView.estimatedRowHeight = tableView.rowHeight
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
     //    Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return headerName.count
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !sectionHeaderExistence[section] {
            return CGFloat(0)
        }
        return UITableViewAutomaticDimension
    }
    var numberOfRowsInSection: [Int] = []
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection[section]
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerName[section]
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.frame.width / CGFloat((tweetForDetail?.media[indexPath.section].aspectRatio)! )
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //    let
        let cell: UITableViewCell
        if indexPath.section == 0 {//当的dection==0时 代表是图片的section 因此dequeue的是imageCell
            cell = (tableView.dequeueReusableCellWithIdentifier(StoryBoard.ImageCellIdentifier, forIndexPath: indexPath) as? ImageTableViewCell)!
        } else if indexPath.section != 3  {//否则 同理 dequeue的是textCell
            cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.TextCellIdentifier, forIndexPath: indexPath)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.URLCellIdentifier, forIndexPath:  indexPath)
        }
        if !sectionHeaderExistence[indexPath.section] { cell.hidden = true }
        switch indexPath.section {
        case 0:
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)){
                let data = NSData(contentsOfURL: (self.tweetForDetail?.media[0].url)!)
                dispatch_async(dispatch_get_main_queue()) {
                    if let imageCell = cell as? ImageTableViewCell {
                        imageCell.ImageView.image = UIImage(data: data!)
                    }
                }
            }
        case 1:
            cell.textLabel?.text = tweetForDetail?.hashtags[indexPath.row].keyword
        case 2:
            cell.textLabel?.text = tweetForDetail?.userMentions[indexPath.row].keyword
        case 3:
            cell.textLabel?.text = tweetForDetail?.urls[indexPath.row].keyword
        case 4:
            cell.textLabel?.text = tweetForDetail?.user.screenName
        default:
            break
        }
        return cell
    }
    
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let cell = sender as? UITableViewCell
        {
            let indexPath = tableView.indexPathForCell(cell)!
            switch indexPath.section {
            case 0:
                let scrollImageMVC = segue.destinationViewController as? ImageViewController
                scrollImageMVC?.imageURL = tweetForDetail?.media[indexPath.row].url
                //                scrollImageMVC?.scrollView.zoomScale = CGFloat(0.313715070012632)
                //                scrollImageMVC?.imageView.sizeToFit()
                //                scrollImageMVC?.scrollView.setZoomScale(0.313715070012632, animated: true)
            //                print(tweetForDetail?.media[indexPath.row].aspectRatio)
            case 1:
                let searchForHashtagMVC = segue.destinationViewController as? TweetTableViewController
                searchForHashtagMVC?.searchText = tweetForDetail?.hashtags[indexPath.row].keyword
            case 2:
                let searchForHashtagMVC = segue.destinationViewController as? TweetTableViewController
                searchForHashtagMVC?.searchText = tweetForDetail?.userMentions[indexPath.row].keyword
            case 3:
                if let WebMVC = segue.destinationViewController as? WebViewController ,
                    let urlString = tweetForDetail?.urls[indexPath.row].keyword,
                    let url = NSURL(string: urlString) {
                    WebMVC.webURL = url
                }
            case 4:
                let searchForHashtagMVC = segue.destinationViewController as? TweetTableViewController
                searchForHashtagMVC?.searchText = "from:\((tweetForDetail?.user.screenName)!)"
                
            default:
                break
            }
        }
        
    }
}
