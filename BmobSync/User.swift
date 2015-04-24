//
//  User.swift
//  BmobSync
//
//  Created by HuCharlie on 4/24/15.
//  Copyright (c) 2015 HuCharlie. All rights reserved.
//

import Foundation
import CoreData


@objc(User)
class User: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var name: String

}
