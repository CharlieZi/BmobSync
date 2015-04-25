//
//  News.swift
//  BmobSync
//
//  Created by HuCharlie on 4/24/15.
//  Copyright (c) 2015 HuCharlie. All rights reserved.
//

import Foundation
import CoreData

@objc(News)
class News: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var content: String
    @NSManaged var timestamp: NSDate
    @NSManaged var author: String

}
