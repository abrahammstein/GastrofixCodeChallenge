//
//  FlickrPhoto+CoreDataProperties.swift
//  GastrofixCodeChallenge
//
//  Created by Rabbot on 02/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FlickrPhoto {

    @NSManaged var tags: String?
    @NSManaged var authorId: String?
    @NSManaged var author: String?
    @NSManaged var published: NSDate?
    @NSManaged var itemDescription: String?
    @NSManaged var dateTaken: NSDate?
    @NSManaged var media: String?
    @NSManaged var link: String?
    @NSManaged var title: String?

}
