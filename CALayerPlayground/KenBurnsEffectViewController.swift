//
//  KenBurnsEffectViewController.swift
//  CALayerPlayground
//
//  Created by Deeksha Prabhakar on 11/30/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class KenBurnsEffectViewController: UIViewController {

    @IBOutlet weak var kensView: JBKenBurnsView!
    
    var snapShotImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let sImage = snapShotImage as UIImage!{
                    
            var imagesArray = [UIImage.init(named: "asianArtMuseum")]
            //let imagesArray = [sImage]
            //var imageArray = [UIImage]()
            imagesArray.append(UIImage(named: "1")!)
            imagesArray.append(UIImage(named: "2")!)
            imagesArray.append(UIImage(named: "3")!)
            imagesArray.append(UIImage(named: "4")!)

            
            kensView.animate(withImages: imagesArray, transitionDuration: 3, initialDelay: 0, loop: false, isLandscape: true)
//            kensView.animateWithImages(imagesArray as! [UIImage], imageAnimationDuration: 3, initialDelay: 0, shouldLoop: false)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
