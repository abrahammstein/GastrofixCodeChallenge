//
//  GastrofixAPI.swift
//  GastrofixCodeChallenge
//
//  Created by Rabbot on 02/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

import UIKit

class GastrofixAPI: NSObject {
    private let persistencyManager : PersistencyManager
    
    class var sharedInstance: GastrofixAPI {
        struct Singleton {
            static let instance = GastrofixAPI()
        }
        
        return Singleton.instance
    }
    
    override init() {
        persistencyManager = PersistencyManager()
        
        super.init()
    }
    
    func saveFlickrPhoto(tags: String, authorId: String, author: String, published: NSDate, itemDescription: String, dateTaken: NSDate, media: String, link: String, title: String) {
        persistencyManager.saveFlickrPhoto(tags, authorId: authorId, author: author, published: published, itemDescription: itemDescription, dateTaken: dateTaken, media: media, link: link, title: title)
    }
    
    func checkIfFlickrPhotoExists(media: String) -> Int {
        return persistencyManager.checkIfFlickrPhotoExists(media)
    }
}
