//
//  ListTableViewController.swift
//  BmobSync
//
//  Created by HuCharlie on 4/24/15.
//  Copyright (c) 2015 HuCharlie. All rights reserved.
//

import UIKit




class ListTableViewController: UITableViewController {
    
    
    var NewsTimelineData:NSMutableArray = NSMutableArray()
    var lastsyncStamp:NSDate = NSDate()
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func loadData(){
        
        NewsTimelineData.removeAllObjects()
        lastsyncStamp = NSDate.distantPast() as! NSDate
        
        let moc:NSManagedObjectContext = SwiftCoreDataHelper.managedObjectContext()
        
        let results:NSArray = SwiftCoreDataHelper.fetchEntitiesForClass(NSStringFromClass(News), withPredicate: nil, inManagedObjectContext: moc)
        
        //load local data and initialization
        
        if results.count > 0 {
            for item in results {
                let singleNews = item as! News
                let timestamp:NSDate = singleNews.timestamp as NSDate
                
                let newsDict:NSDictionary = ["identifier":singleNews.identifier,"timestamp":timestamp,"content":singleNews.content]
                NewsTimelineData.addObject(newsDict)
                lastsyncStamp = lastsyncStamp.laterDate(timestamp)
            }
            
            
        }
        
        var addNews:News = SwiftCoreDataHelper.insertManagedObjectOfClass(NSStringFromClass(News), inManagedObjectContext: moc) as! News
        var findTimelineData:BmobQuery = BmobQuery(className: "Company_News")
            
        findTimelineData.findObjectsInBackgroundWithBlock {
            (objects, error:NSError?) -> Void in
                if error == nil {
                    for object in objects! {
                        
                        let downloadNews:BmobObject = object as! BmobObject
                        let timestamp:NSDate = downloadNews.createdAt as NSDate
                        
//                        if (self.lastsyncStamp.laterDate(timestamp) == timestamp){
                            let identifier:String = downloadNews.objectId as String
                            let content:String = downloadNews.objectForKey("Content") as! String
                            
                            addNews.identifier = identifier
                            addNews.content = content
                            addNews.timestamp = timestamp
                            
                            SwiftCoreDataHelper.saveManagedObjectContext(moc)
                            
                            let newsDict:NSDictionary = ["identifier":identifier,"timestamp":timestamp,"content":content]
                            self.NewsTimelineData.addObject(newsDict)
                            println(self.NewsTimelineData.count)
                            println(content)
//                        }
                        
                    }
                }
            }
        
        println(self.NewsTimelineData.count)
//        let dateDescriptor:NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
//        var sortedArray:NSArray = NewsTimelineData.sortedArrayUsingDescriptors([dateDescriptor])
        
        
        
//        lastsyncStamp = sortedArray.firstObject?.objectForKey("timestamp") as! NSDate
        
        tableView.reloadData()
        
////            
//            let dateDescriptor:NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
//            var sortedArray:NSArray = NewsTimelineData.sortedArrayUsingDescriptors([dateDescriptor])
////            
//            
//            lastsyncStamp = sortedArray.firstObject!.objectForKey("timestamp") as! NSDate
            
            
        
        
        //load newly added online data
        
     /*
        
        var addNews:News = SwiftCoreDataHelper.insertManagedObjectOfClass(NSStringFromClass(News), inManagedObjectContext: moc) as! News
        
        var findTimelineData:BmobQuery = BmobQuery(className: "Company_News")
        

        
        findTimelineData.findObjectsInBackgroundWithBlock {
            (objects, error:NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    
                    
                    let downloadNews:BmobObject = object as! BmobObject

                    let timestamp:NSDate = downloadNews.createdAt as NSDate
                    
                    if (self.lastsyncStamp.compare(timestamp) == NSComparisonResult.OrderedAscending){
                        
                        let identifier:String = downloadNews.objectId as String
                        let content:String = downloadNews.objectForKey("Content") as! String
                        
                        
                        addNews.identifier = identifier
                        addNews.content = content
                        addNews.timestamp = timestamp
                        self.lastsyncStamp = timestamp
                        
                        
                        SwiftCoreDataHelper.saveManagedObjectContext(moc)
                        
                        let newsDict:NSDictionary = ["identifier":identifier,"timestamp":timestamp,"content":content]
                        
                        self.NewsTimelineData.addObject(newsDict)
                        
                        
                        
                           
                        
                        

                    }
                    
                }
                
                let dateDescriptor:NSSortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
                var sortedArray:NSArray = self.NewsTimelineData.sortedArrayUsingDescriptors([dateDescriptor])

            }
        }
        
        self.tableView.reloadData()
*/
        
        

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
        
        
        
        cell.authorLabel.text = "test"
        
        println(NewsTimelineData.count)
        println("       adsfadsfadf")
        
        let itemDict:NSDictionary = NewsTimelineData.objectAtIndex(indexPath.row) as! NSDictionary
        
        let content = itemDict.objectForKey("content") as! String
        
        
        cell.companyNewsTextView.text = content
        
        
        
        

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
    @IBAction func refreshBtnClicked(sender: AnyObject) {
        
        loadData()
        self.tableView.reloadData()

        
        
        
        
        
        
    }

}
