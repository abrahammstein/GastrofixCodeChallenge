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
    
    let downloadDateFormatter = NSDateFormatter()
    let presentationDateFormatter = NSDateFormatter()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let flickrFetchRequest = NSFetchRequest(entityName: "FlickrPhoto")
        let titleSortDescriptor = NSSortDescriptor(key: "published", ascending: true)
        flickrFetchRequest.sortDescriptors = [titleSortDescriptor]
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let frc = NSFetchedResultsController(fetchRequest: flickrFetchRequest, managedObjectContext: appDelegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        downloadDateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
        presentationDateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        downloadFlickrJsonData()
    }
    
    func downloadFlickrJsonData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.allowsCellularAccess = true
        sessionConfig.HTTPAdditionalHeaders = ["Accept": "application/json"]
        
        let session = NSURLSession(configuration: sessionConfig)
        session.dataTaskWithURL(NSURL(string: "http://www.flickr.com/services/feeds/photos_public.gne?tags=soccer&format=json&jsoncallback=?")!) { (data, response, error) -> Void in
            print("JSON RESPONSE IS: \(response)")
            let httpResponse = response as! NSHTTPURLResponse
            if httpResponse.statusCode == 200 {
                var dataString = String(data: data!, encoding: NSUTF8StringEncoding)
                dataString!.removeAtIndex(dataString!.characters.indices.first!)
                dataString!.removeAtIndex(dataString!.characters.indices.last!)
                print("The Data String is: \(dataString!)")
                let utfData = dataString?.dataUsingEncoding(NSUTF8StringEncoding)
                let gastrofixApi = GastrofixAPI.sharedInstance
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                    do {
                        let photosJson = try NSJSONSerialization.JSONObjectWithData(utfData!, options: .AllowFragments) as! [String: AnyObject]
                        print("Photos Json has: \(photosJson)")
                        if let items = photosJson["items"] as? [NSDictionary] {
                            for item in items {
                                let tags = item["tags"] as! String
                                let authorId = item["author_id"] as! String
                                let author = item["author"] as! String
                                let published = self.downloadDateFormatter.dateFromString(item["published"] as! String)
                                var itemDescription = ""
                                if let itemDesc = item["description"] as? String {
                                    itemDescription = itemDesc
                                }
                                let dateTaken = self.downloadDateFormatter.dateFromString(item["date_taken"] as! String)
                                let media = item["media"] as! NSDictionary
                                let mediaUrl = media["m"] as! String
                                let link = item["link"] as! String
                                let title = item["title"] as! String
                                
                                if gastrofixApi.checkIfFlickrPhotoExists(mediaUrl) != 1 {
                                    gastrofixApi.saveFlickrPhoto(tags, authorId: authorId, author: author, published: published!, itemDescription: itemDescription, dateTaken: dateTaken!, media: mediaUrl, link: link, title: title)
                                }
                                
                                
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            })
                        }
                        
                    } catch let error as NSError {
                        print("Something went wrong \(error)")
                    }
                })
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
        if fetchedResultsController.sections?.count > 0 {
            let currentSection = fetchedResultsController.sections![section]
            return currentSection.numberOfObjects
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FlickrTableViewCell", forIndexPath: indexPath) as! FlickrTableViewCell

        // Configure the cell..
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: FlickrTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let flickrItem = fetchedResultsController.objectAtIndexPath(indexPath) as! FlickrPhoto
        cell.flickrTitle.text = flickrItem.title
        cell.publishedLabel.text = "Published: \(presentationDateFormatter.stringFromDate(flickrItem.published!))"
        cell.flickrImage.kf_setImageWithURL(NSURL(string: flickrItem.media!)!,
            placeholderImage: nil,
            optionsInfo: [.Transition(ImageTransition.Fade(1))])
        cell.flickrImage.contentMode = .ScaleAspectFit
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "flickrDetailSegue" {
            let selectedIndexPath = tableView.indexPathForSelectedRow
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.flickrPhotoInfo = fetchedResultsController.objectAtIndexPath(selectedIndexPath!) as! FlickrPhoto
        }
        
    }

}

extension FlickrTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! FlickrTableViewCell
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
}
