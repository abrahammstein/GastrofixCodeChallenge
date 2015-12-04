//
//  PersistencyManager.swift
//  GastrofixCodeChallenge
//
//  Created by Rabbot on 02/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

import UIKit
import CoreData

class PersistencyManager: NSObject {
    private let appDelegate: AppDelegate
    private let managedContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    override init() {
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        backgroundContext = appDelegate.backgroundContext!
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { note in
            
            if note != self.managedContext {
                self.managedContext.performBlock({ () -> Void in
                    self.managedContext.mergeChangesFromContextDidSaveNotification(note)
                })
            }
        }
    }
    
    func saveFlickrPhoto(tags: String, authorId: String, author: String, published: NSDate, itemDescription: String, dateTaken: NSDate, media: String, link: String, title: String) {
        let flickrPhoto = NSEntityDescription.insertNewObjectForEntityForName("FlickrPhoto", inManagedObjectContext: backgroundContext)
        
        // add our data
        flickrPhoto.setValue(tags, forKey: "tags")
        flickrPhoto.setValue(authorId, forKey: "authorId")
        flickrPhoto.setValue(author, forKey: "author")
        flickrPhoto.setValue(published, forKey: "published")
        flickrPhoto.setValue(itemDescription, forKey: "itemDescription")
        flickrPhoto.setValue(dateTaken, forKey: "dateTaken")
        flickrPhoto.setValue(media, forKey: "media")
        flickrPhoto.setValue(link, forKey: "link")
        flickrPhoto.setValue(title, forKey: "title")
        
        // save it
        do {
            try backgroundContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func checkIfFlickrPhotoExists(media: String) -> Int {
        let entity = NSEntityDescription.entityForName("FlickrPhoto", inManagedObjectContext: backgroundContext)
        
        let request = NSFetchRequest()
        request.entity = entity
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "media == %@", media)
        
        return backgroundContext.countForFetchRequest(request, error: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
