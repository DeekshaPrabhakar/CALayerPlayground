//
//  ViewController.swift
//  CALayerPlayground
//
//  Created by Deeksha Prabhakar on 11/29/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var viewForLayer: UIView!
    
    var viewLayer: CALayer {
        return viewForLayer.layer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayer()
    }
    //http://www.appcoda.com/calayer-introduction/
    //https://www.raywenderlich.com/90488/calayer-in-ios-with-swift-10-examples
    func setUpLayer(){
        viewLayer.backgroundColor = UIColor.blue.cgColor
        viewLayer.borderWidth = 10
        viewLayer.borderColor = UIColor.brown.cgColor
        //Shadow helps create a sense of depth in our app, and are very useful in designing interfaces. With a shadow effect, we can make views appear to “float” onscreen
        viewLayer.shadowOpacity = 0.7//shadow should be 70% opaque.
        viewLayer.shadowRadius = 10
        
        viewLayer.contents = UIImage(named: "AppIcon60")?.cgImage
        viewLayer.contentsGravity = kCAGravityCenter //top, top-right, right, bottom-right, bottom, bottom-left, left and top-left.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

