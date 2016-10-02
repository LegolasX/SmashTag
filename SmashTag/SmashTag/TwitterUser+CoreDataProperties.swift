//
//  TwitterUser+CoreDataProperties.swift
//  NewSmashtag
//
//  Created by Legolas on 16/9/19.
//  Copyright © 2016年 Legolas. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TwitterUser {

    @NSManaged var name: String?
    @NSManaged var screenName: String?
    @NSManaged var tweets: NSSet?

}
