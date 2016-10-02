//
//  WebViewController.swift
//  NewSmashtag
//
//  Created by Legolas on 16/9/10.
//  Copyright © 2016年 Legolas. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = webURL {
            WebView.loadRequest(NSURLRequest(URL: url))
           // let x : UIBarButtonItem
            
            //WebView.loadHTMLString(string, baseURL: webURL?.baseURL)
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var WebView: UIWebView!
    @IBOutlet weak var ToolBar: UIToolbar!
    
    var webURL : NSURL?
    
    @IBAction func Back(sender: UIButton) {
        WebView.goBack()
    }
    
    @IBAction func Stop(sender: UIButton) {
        WebView.stopLoading()
    }
    
    @IBAction func Forward(sender: UIButton) {
        WebView.goForward()
    }
    
    @IBAction func Reload(sender: UIButton) {
        WebView.reload()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
