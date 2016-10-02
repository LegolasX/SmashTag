//
//  TableViewCell.swift
//  NewSmashtag
//
//  Created by Legolas on 16/8/18.
//  Copyright © 2016年 Legolas. All rights reserved.
//

import UIKit
import Twitter

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    
    private func updateUI()
    {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.text = tweet.text
            
            let myMutableAttributedString = NSMutableAttributedString(attributedString: tweetTextLabel.attributedText!)
            for hashtag in tweet.hashtags {
                myMutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.orangeColor(), range: hashtag.nsrange)
            }
            for mention in tweet.userMentions {
                myMutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: mention.nsrange)
            }
            for url in tweet.urls {
                myMutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: url.nsrange)
            }
            if tweetTextLabel?.text != nil  {
                for _ in tweet.media {
                    myMutableAttributedString.appendAttributedString(NSAttributedString(string: " 📷"))
                }
            }
            tweetTextLabel.attributedText = myMutableAttributedString
            
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = NSData(contentsOfURL: profileImageURL) { // blocks main thread!
                    tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
        
    }
}



