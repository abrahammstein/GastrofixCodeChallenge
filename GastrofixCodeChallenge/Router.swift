//
//  Router.swift
//  GastrofixCodeChallenge
//
//  Created by Rabbot on 02/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    static let baseURLString = "http://www.flickr.com"
    case GetFlickrPhotos
    
    var method: Alamofire.Method {
        switch self {
        case .GetFlickrPhotos:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .GetFlickrPhotos:
            return "/services/feeds/photos_public.gne?tags=soccer&format=json&jsoncallback="
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .GetFlickrPhotos:
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: nil).0
        }
    }
}
