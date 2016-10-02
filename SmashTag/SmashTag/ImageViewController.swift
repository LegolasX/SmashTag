//
//  ImageViewController.swift
//  Tesla
//
//  Created by Legolas on 16/8/16.
//  Copyright © 2016年 Legolas. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL : NSURL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    private func fetchImage() {
        if let url = imageURL {
            spinner?.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                let contensOfURL = NSData(contentsOfURL: url)
                dispatch_async(dispatch_get_main_queue()) {
                    if url == self.imageURL {
                        if let imageData =  contensOfURL {
                            self.image = UIImage(data: imageData)
                        } else {
                            self.spinner?.stopAnimating()
                        }
                    } else {
                        print("ignored data returned from url\(url)")
                    }
                }
            }
        }
    }
    var imageView = UIImageView()
    private var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.maximumZoomScale = 1.0
            scrollView.minimumZoomScale = 0.03
            
        }
    }
    

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        // imageURL = TeslaURL.TeslaImageNamed("Model X")
        // Do any additional setup after loading the view.
    }
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
        print(scrollView.zoomScale)
        print(image?.size)
        print(imageView.frame)
     //   print(scrollView.s)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
      //  imageView.sizeToFit()
    }
    
    override func viewDidAppear(animated: Bool) {
        print(image?.size)
    }
    
}
