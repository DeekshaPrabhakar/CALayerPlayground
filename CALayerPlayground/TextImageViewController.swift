//
//  TextImageViewController.swift
//  CALayerPlayground
//
//  Created by Deeksha Prabhakar on 11/29/16.
//  Copyright © 2016 Deeksha Prabhakar. All rights reserved.
//

import UIKit

class TextImageViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = 25
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func createSnapshots() -> [UIImage]?{
//        
//        
//        
//        
//    }
    
    func createSnapShot() -> UIImage?{
        
        let view = self.view.snapshotView(afterScreenUpdates: true)
        
        let newImageBounds = CGSize.init(width: (entryImageView.bounds.size.width), height: (entryImageView.bounds.size.height + contentView.bounds.size.height))
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(newImageBounds, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: newImageBounds.width, height: newImageBounds.height))
        
        // Draw view in that context
        //bounds has always x and y zero
        
        // divided by 2 is for retina
        
        //contentView.drawHierarchy(in: CGRect(x: contentView.frame.size.width / 2, y: entryImageView.frame.size.height, width: contentView.frame.size.width, height: contentView.frame.size.height), afterScreenUpdates: true)
        
        contentView.drawHierarchy(in: CGRect(x: 0, y: entryImageView.frame.size.height, width: contentView.frame.size.width, height: contentView.frame.size.height), afterScreenUpdates: true)
        
        //        entryImageView.drawHierarchy(in: CGRect(x: entryImageView.frame.size.width / 2, y: 0, width: entryImageView.frame.width, height: entryImageView.frame.height), afterScreenUpdates: true)
        
        //     for width not using entryImageView.frame.width since we want content and image to be same width
        entryImageView.drawHierarchy(in: CGRect(x: 0, y: 0, width: contentView.frame.width, height: entryImageView.frame.height), afterScreenUpdates: true)
        
        
        
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()        
        return image
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let imge = createSnapShot()
        
        if let vc = segue.destination as? SnapshotViewController{
            if let sImage = imge as UIImage!{
                vc.snapShotImage = sImage
            }
        }
        else if let vc = segue.destination as? KenBurnsEffectViewController{
            if let sImage = imge as UIImage!{
                vc.snapShotImage = sImage
            }
        }
        
    }
    
    
}
