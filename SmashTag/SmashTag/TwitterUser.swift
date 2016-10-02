//
//  TwitterUser.swift
//  NewSmashtag
//
//  Created by Legolas on 16/9/19.
//  Copyright © 2016年 Legolas. All rights reserved.
//

import Foundation
import CoreData
import Twitter

class TwitterUser: NSManagedObject
{
    // a class method which
    // returns a TwitterUser from the database if Twitter.User has already been put in
    // or returns a newly-added-to-the-database TwitterUser if not
    
    class func twitterUserWithTwitterInfo(twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser?
    {
        let request = NSFetchRequest(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        if let twitterUser = (try? context.executeFetchRequest(request))?.first as? TwitterUser {
            return twitterUser
        } else if let twitterUser = NSEntityDescription.insertNewObjectForEntityForName("TwitterUser", inManagedObjectContext: context) as? TwitterUser {
            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
            return twitterUser
        }
        return nil
    }
}
