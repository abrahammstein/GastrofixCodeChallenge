//
//  FlickrTableViewController.swift
//  GastrofixCodeChallenge
//
//  Created by Rabbot on 02/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher

class FlickrTableViewController: UITableViewController {
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let animalsFetchRequest = NSFetchRequest(entityName: "FlickrPhoto")
        let secondarySortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        animalsFetchRequest.sortDescriptors = [secondarySortDescriptor]
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let frc = NSFetchedResultsController(fetchRequest: animalsFetchRequest, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: "title", cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(NSURL(string: "http://www.flickr.com/services/feeds/photos_public.gne?tags=soccer&format=json")!) { (data, response, error) -> Void in
            print("JSON RESPONSE IS: \(response)")
            let httpResponse = response as! NSHTTPURLResponse
            if httpResponse.statusCode == 200 {
                var dataString = String(data: data!, encoding: NSUTF8StringEncoding)
                dataString = dataString?.stringByReplacingOccurrencesOfString("jsonFlickrFeed(", withString: "")
                dataString = dataString?.stringByReplacingOccurrencesOfString("})", withString: "}")
                print("The Data String is: \(dataString!)")
                let utfData = dataString?.dataUsingEncoding(NSUTF8StringEncoding)
                let gastrofixApi = GastrofixAPI.sharedInstance
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
                
                do {
                    let photosJson = try NSJSONSerialization.JSONObjectWithData(utfData!, options: .AllowFragments) as! [String: AnyObject]
                    print("Photos Json has: \(photosJson)")
                    if let items = photosJson["items"] as? [NSDictionary] {
                        for item in items {
                            let tags = item["tags"] as! String
                            let authorId = item["author_id"] as! String
                            let author = item["author"] as! String
                            let published = dateFormatter.dateFromString(item["published"] as! String)
                            var itemDescription = ""
                            if let itemDesc = item["description"] as? String {
                                itemDescription = itemDesc
                            }
                            let dateTaken = dateFormatter.dateFromString(item["date_taken"] as! String)
                            let media = item["media"] as! NSDictionary
                            let mediaUrl = media["m"] as! String
                            let link = item["link"] as! String
                            let title = item["title"] as! String
                            
                            
                            gastrofixApi.saveFlickrPhoto(tags, authorId: authorId, author: author, published: published!, itemDescription: itemDescription, dateTaken: dateTaken!, media: mediaUrl, link: link, title: title)
                            
                        }
                    }
                    
                } catch let error as NSError {
                    print("Something went wrong \(error)")
                }
            }
        }.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FlickrTableViewCell", forIndexPath: indexPath) as! FlickrTableViewCell

        // Configure the cell..
        let flickrItem = fetchedResultsController.objectAtIndexPath(indexPath) as! FlickrPhoto
        cell.flickrTitle.text = flickrItem.title
        print("MEDIA \(flickrItem.media!)")
        cell.flickrImage.kf_setImageWithURL(NSURL(string: flickrItem.media!)!,
            placeholderImage: nil,
            optionsInfo: [.Transition(ImageTransition.Fade(1))])
        cell.flickrImage.contentMode = .ScaleAspectFit

        return cell
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

extension FlickrTableViewController: NSFetchedResultsControllerDelegate {
    
}
