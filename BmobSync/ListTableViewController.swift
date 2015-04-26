//
//  ListTableViewController.swift
//  BmobSync
//
//  Created by HuCharlie on 4/24/15.
//  Copyright (c) 2015 HuCharlie. All rights reserved.
//

import UIKit




class ListTableViewController: UITableViewController {
    @IBOutlet var NewsTableView: UITableView!
    
    
    var NewsTimelineData:NSMutableArray = NSMutableArray()
    var lastsyncStamp:NSDate = NSDate()
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshData"), forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl = refreshControl
        
        
        
    }
    
    func refreshData(){
        //load bmob online data
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        let results:NSArray = SwiftCoreDataHelper.fetchEntitiesForClass(NSStringFromClass(News), withPredicate: nil, inManagedObjectContext: moc)
        
        
        for item in results {
            let singleNews = item as! News
            let timestamp:NSDate = singleNews.timestamp as NSDate
            lastsyncStamp = lastsyncStamp.laterDate(timestamp)
        }

        
        var findNewsAuthor:BmobQuery = BmobQuery(className: "Company_News")
        
        var findTimelineData:BmobQuery = BmobQuery(className: "Company_News")
        findTimelineData.findObjectsInBackgroundWithBlock {
            (objects, error:NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    
                    let downloadNews:BmobObject = object as! BmobObject
                    let timestamp:NSDate = downloadNews.createdAt as NSDate
                    
                    // find new added news
                    var dateFormattor:NSDateFormatter = NSDateFormatter()
                    dateFormattor.dateFormat = "yyyy-MM-dd hh:mm:ss"
                    println(dateFormattor.stringFromDate(self.lastsyncStamp)+"refresh")
                    
                    if (self.lastsyncStamp.compare(timestamp) == NSComparisonResult.OrderedAscending){
                        
                        
                        println("tset")
                        var addNews:News = SwiftCoreDataHelper.insertManagedObjectOfClass(NSStringFromClass(News), inManagedObjectContext: moc) as! News
                        
                        let identifier:String = downloadNews.objectId as String
                        let content:String = downloadNews.objectForKey("Content") as! String
                        
                        var author:String = String()
                        
                        var findUserName:BmobQuery = BmobUser.query()
                        findUserName.whereKey("objectID" , equalTo:downloadNews.objectForKey("Company").objectID)
                        
                        findUserName.findObjectsInBackgroundWithBlock { (objects, error:NSError!) -> Void in
                            if error == nil {
                                let user:BmobUser = (objects as NSArray).lastObject as! BmobUser
                                author = user.objectForKey("username") as! String
                                addNews.author = author
                                addNews.identifier = identifier
                                addNews.content = content
                                addNews.timestamp = timestamp
                                
                                
                                SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                
                                let newsDict:NSDictionary = ["identifier":identifier,"timestamp":timestamp,"content":content,"author":author]
                                
                                self.NewsTimelineData.addObject(newsDict)
                                let dateDescriptor:NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                                var sortedArray:NSArray = self.NewsTimelineData.sortedArrayUsingDescriptors([dateDescriptor])
                                
                                self.NewsTimelineData = NSMutableArray(array: sortedArray)
                                
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
        
    }
     
    func loadData(){
        
        NewsTimelineData.removeAllObjects()
        lastsyncStamp = NSDate.distantPast() as! NSDate
        
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        
        let results:NSArray = SwiftCoreDataHelper.fetchEntitiesForClass(NSStringFromClass(News), withPredicate: nil, inManagedObjectContext: moc)
        
        
        println(results.count)
        //load local data and initialization
        
        if results.count > 0 {
            for item in results {
                let singleNews = item as! News
                let timestamp:NSDate = singleNews.timestamp as NSDate
                
                let newsDict:NSDictionary = ["identifier":singleNews.identifier,"timestamp":timestamp,"content":singleNews.content,"author":singleNews.author]
                
                NewsTimelineData.addObject(newsDict)
                lastsyncStamp = lastsyncStamp.laterDate(timestamp)
                
            }
            println(NewsTimelineData.count)
            let dateDescriptor:NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
            var sortedArray:NSArray = NewsTimelineData.sortedArrayUsingDescriptors([dateDescriptor])
            
            NewsTimelineData = NSMutableArray(array: sortedArray)
            self.tableView.reloadData()
            
            
        }
        
        //load bmob online data
        
        var findNewsAuthor:BmobQuery = BmobQuery(className: "Company_News")
        var findTimelineData:BmobQuery = BmobQuery(className: "Company_News")
        findTimelineData.findObjectsInBackgroundWithBlock {
            (objects, error:NSError?) -> Void in
                if error == nil {
                    
                    for object in objects! {
                        
                        let downloadNews:BmobObject = object as! BmobObject
                        let timestamp:NSDate = downloadNews.createdAt as NSDate
                        
                        // find new added news
                        
                        if (self.lastsyncStamp.compare(timestamp) == NSComparisonResult.OrderedAscending){
                            var addNews:News = SwiftCoreDataHelper.insertManagedObjectOfClass(NSStringFromClass(News), inManagedObjectContext: moc) as! News
                            
                            let identifier:String = downloadNews.objectId as String
                            let content:String = downloadNews.objectForKey("Content") as! String
                            
                            var author:String = String()
                            
                            var findUserName:BmobQuery = BmobUser.query()
                            findUserName.whereKey("objectID" , equalTo:downloadNews.objectForKey("Company").objectID)
                        
                            findUserName.findObjectsInBackgroundWithBlock { (objects, error:NSError!) -> Void in
                                if error == nil {
                                    let user:BmobUser = (objects as NSArray).lastObject as! BmobUser
                                    author = user.objectForKey("username") as! String
                                    addNews.author = author
                                    addNews.identifier = identifier
                                    addNews.content = content
                                    addNews.timestamp = timestamp
                                    
                                    
                                    SwiftCoreDataHelper.saveManagedObjectContext(moc)
                                    
                                    let newsDict:NSDictionary = ["identifier":identifier,"timestamp":timestamp,"content":content,"author":author]
                                    
                                    self.NewsTimelineData.addObject(newsDict)
                                    let dateDescriptor:NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                                    var sortedArray:NSArray = self.NewsTimelineData.sortedArrayUsingDescriptors([dateDescriptor])
                                    
                                    self.NewsTimelineData = NSMutableArray(array: sortedArray)
                                
                                    self.tableView.reloadData()
                                    
                                }
                            }
                        }
                    }

                }
            }
    }
    
    


    
    
    
    
    
    
    
    
//        var NewsTimeline:News = SwiftCoreDataHelper.insertManagedObjectOfClass(NSStringFromClass(News), inManagedObjectContext: moc)as! News
//
    
    
    
    

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return NewsTimelineData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ListTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ListTableViewCell

        // Configure the cell
        
        
        cell.newsAuthor.alpha = 0
        cell.newsTimestamp.alpha = 0
        cell.newsTitle.alpha = 0
        cell.newsContent.alpha = 0
        
        cell.CellUIView.alpha = 0
        
        cell.CellUIView.layer.cornerRadius = 0.2
        cell.CellUIView.layer.masksToBounds = false
        cell.CellUIView.layer.shadowColor = UIColor.blackColor().CGColor
        cell.CellUIView.layer.shadowOffset = CGSize(width: 0, height: 3);
        cell.CellUIView.layer.shadowOpacity = 0.2
        
        
        
        
        
        var dateFormattor:NSDateFormatter = NSDateFormatter()
        dateFormattor.dateFormat = "yyyy-MM-dd hh:mm:ss"

        
        
        
        
        let itemDict:NSDictionary = NewsTimelineData.objectAtIndex(indexPath.row) as! NSDictionary
        
        let content = itemDict.objectForKey("content") as! String
//        let title = itemDict.objectForKey("title") as! String
        let timestamp = itemDict.objectForKey("timestamp") as! NSDate
        let author = itemDict.objectForKey("author") as! String

        
        cell.newsAuthor.text = author
        cell.newsTimestamp.text = dateFormattor.stringFromDate(timestamp)
        cell.newsTitle.text = "myNewsTitle"
        cell.newsContent.text = content
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            cell.newsAuthor.alpha = 1
            cell.newsTimestamp.alpha = 1
            cell.newsTitle.alpha = 1
            cell.newsContent.alpha = 1
            
            cell.CellUIView.alpha = 1
            
            cell.CellUIView.layer.cornerRadius = 0.5
            cell.CellUIView.layer.masksToBounds = false
            cell.CellUIView.layer.shadowColor = UIColor.blackColor().CGColor
            cell.CellUIView.layer.shadowOffset = CGSize(width: 0, height: 3);
            cell.CellUIView.layer.shadowOpacity = 0.5
            
            
            })
        


        
        
        

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
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
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
//    func loadUserName(BmobArrayName:NSString, BmobObjectname:BmobObject)->String{
//        var userName:NSString = NSString()
//        var findUserName:BmobQuery = BmobUser.query()
//        
//
//        findUserName.whereKey("objectID" , equalTo:BmobObjectname.objectForKey(BmobArrayName).objectID)
//        
//        findUserName.findObjectsInBackgroundWithBlock { (objects, error:NSError!) -> Void in
//            if error == nil {
//                let user:BmobUser = (objects as NSArray).lastObject as! BmobUser
//                userName = user.objectForKey("username") as! String
//                
//            }
//        }
//        println("i am"+(userName as String))
//        return userName as String
//    }
    
    
    
    @IBAction func refreshBtnClicked(sender: AnyObject) {
        
        
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        let resultstoDelete:NSArray = SwiftCoreDataHelper.fetchEntitiesForClass(NSStringFromClass(News), withPredicate: nil, inManagedObjectContext: moc)
        
        for item in resultstoDelete {
            let singleitemtoDelete:News = item as! News
            
            singleitemtoDelete.managedObjectContext?.deleteObject(singleitemtoDelete)
            SwiftCoreDataHelper.saveManagedObjectContext(moc)
        }
        
        
        
        
        loadData()
        self.tableView.reloadData()

        
        
        
        
        
        
    }

}
