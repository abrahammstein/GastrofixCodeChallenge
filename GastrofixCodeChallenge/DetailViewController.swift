//
//  DetailViewController.swift
//  GastrofixCodeChallenge
//
//  Created by Rabbot on 02/12/15.
//  Copyright © 2015 Gastrofix. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var flickrPhotoInfo: FlickrPhoto!
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = flickrPhotoInfo.title
        
        webView.loadHTMLString("<div style=\"font-family: Helvetica; padding: 1em;\">" + flickrPhotoInfo.itemDescription! + "</div>", baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
