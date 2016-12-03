//
//  JBKenBurnsView.swift
//  Version 1.0
//
//  Created by Johan Basberg, on 16/05/2016.
//  Based on the work by Javier Berlana et. al.
//
//

import UIKit

enum KenBurnsZoomMode: Int {
    case `in`
    case out
    case random
}

protocol JBKenBurnsViewDelegate {
    func finishedShowingLastImage()
}

class JBKenBurnsView: UIView {
    
    // MARK: - Customizable Defaults
    
    /// Change this to randomly zoom in or out, or lock it to one or the other.
    var zoomMode: KenBurnsZoomMode = .random
    
    /// How much the image should be zoomed. Default 1.1 appears to be a reasonable ration, without too much pixelation.
    fileprivate let enlargeRatio: CGFloat = 1.1
    
    /// This variable can be changed when starting the animation. However, change this to alter the default behavior.
    static let randomFirstImage = false
    
    /// Enable screen orientation awareness if the view needs to be able to handle the transitions between portrait and landscape.
    let screenOrientationAwareness = true
    
    /// Set this to true to temporarily pause the animations.
    
    
    // MARK: - Variables
    
    var kenBurnsDelegate: JBKenBurnsViewDelegate?
    var isPaused: Bool {
        get {
            return layer.speed == 0
        }
    }
    
    // MARK: - Private Variables
    // Nothing would normally need to change below this line.
    // Most of these will be overriden in runtime.
    
    fileprivate var stopGeneratingDeviceOrientationNotifications = false
    fileprivate var portrait: Bool = true
    //fileprivate var nextImageDelay: DispatchTime = 0
    fileprivate var showImageDuration: TimeInterval = 10
    fileprivate var shouldLoop: Bool = true
    fileprivate var nextImageIndex: Int = 0
    fileprivate var indexOfFirstImageShown = 0
    
    fileprivate var finishTransform: CGAffineTransform?
    fileprivate var imagesArray = [UIImage]()
    
    fileprivate var currentImageView: UIImageView? = nil
    fileprivate var currentImageIndex: Int = 0
    
    fileprivate enum KenBurnsImageMovementDirection: Int {
        case downLeft
        case upLeft
        case downRight
        case upRight
    }
    
    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        layer.masksToBounds = true
        
        if screenOrientationAwareness {
            if UIDevice.current.isGeneratingDeviceOrientationNotifications == false {
                UIDevice.current.beginGeneratingDeviceOrientationNotifications()
                stopGeneratingDeviceOrientationNotifications = true
            }
            NotificationCenter.default.addObserver(self, selector: #selector(JBKenBurnsView.deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            portrait = UIDeviceOrientationIsPortrait(UIDevice.current.orientation)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if stopGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
    
    // MARK: - Usage: Animation
    
    /**
     Start the Ken Burns effect by providing an array of images.
     - parameter imagePaths: And array of valid paths to the images that will be animated with the Ken Burns effect.
     - parameter imageAnimationDuration: The animation duration for each image, excluding the cross fading between images.
     - parameter initialDelay: Pass a value higher than zero to delay the Ken Burns effect.
     - parameter shouldLoop: A boolean determining if the image animation should start from the last provided image is shown.
     - parameter randomFirstImage: Pass true if you want the initial image to be picked at random (default is false).
     */
    func animateWithImagePaths(_ imagePaths: [String], imageAnimationDuration duration: TimeInterval, initialDelay delay: TimeInterval, shouldLoop loop: Bool, randomFirstImage randomize: Bool = randomFirstImage) {
        
        for path in imagePaths {
            if let image = UIImage(contentsOfFile: path) {
                imagesArray.append(image)
            }
        }
        
        guard imagesArray.count > 0 else {
            assertionFailure("No valid image paths were passed. Cannot animate an empty image array.")
            return
        }

        startAnimationsWithDuration(duration, initialDelay: delay, shouldLoop: loop, randomFirstImage: randomize)
    }
    
    
    /**
     Start the Ken Burns effect by providing an array of images.
     - parameter images: And array of UIImages to be animated with the Ken Burns effect in the order of the array.
     - parameter imageAnimationDuration: The animation duration for each image, excluding the cross fading between images.
     - parameter initialDelay: Pass a value higher than zero to delay the Ken Burns effect.
     - parameter shouldLoop: A boolean determining if the image animation should start from the last provided image is shown.
     - parameter randomFirstImage: Pass true if you want the initial image to be picked at random (default is false).
     */
    func animateWithImages(_ images: [UIImage], imageAnimationDuration duration: TimeInterval, initialDelay delay: TimeInterval, shouldLoop loop: Bool, randomFirstImage randomize: Bool = randomFirstImage) {
        
        guard images.count > 0 else {
            assertionFailure("Cannot animate an empty image array.")
            return
        }
        
        self.imagesArray = images
        startAnimationsWithDuration(duration, initialDelay: delay, shouldLoop: loop, randomFirstImage: randomize)
    }
    
    /**
     Call this to permanently stop the Ken Burns animation immediately; calling this in the middle of an animation doesn't look great. Consider calling ´pauseAnimation()´instead. The currently visible image will remain on screen.
     - Discussion: As calling this permanently stops the animation, it also clears the array of images. The only way to start animating again is to call either ´animateWithImagePaths(:imageAnimationduration:initialDelay:shouldLoop)´ or ´animateWithImages(:imageAnimationduration:initialDelay:shouldLoop)´
     */
    func stopAnimation() {
        layer.removeAllAnimations()
        if subviews.count > 0 {
            subviews[0].layer.removeAllAnimations()
        }
        imagesArray = []
    }
    
    /// Temporarily pauses the animation. Restart the animation by calling `resumeAnimationAfterDelay(initialDelay:)´.
    func pauseAnimation() {
        guard !isPaused else {
            return
        }

        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.timeOffset = pausedTime
        layer.speed = 0
    }
    
    /**
     When the animation has been paused can you call this to resume the animation. If you want to delay the animation pass in an initialDelay greater than 0.
     - Important: Calling this when the animation isn't actually paused will cause no visible changes.
     - Parameter initialDelay: The number of seconds to delay the animation (default is 0).
     */
    func resumeAnimation(afterDelay delay: TimeInterval = 0) {
        guard isPaused else {
            return
        }

        let pausedTime = layer.timeOffset
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause        
    }
    
    
    //MARK: - Usage: Image Handling
    
    
    func addImage(_ image: UIImage) {
        imagesArray.append(image)
    }
    
    func currentImage() -> UIImage? {
        if imagesArray.count >= (currentImageIndex + 1) {
            return imagesArray[currentImageIndex] ?? nil
        } else {
            return nil
        }
    }
    
    // MARK: - Utilities
    
    
    fileprivate func startAnimationsWithDuration(_ duration: TimeInterval, initialDelay delay: TimeInterval, shouldLoop loop: Bool, randomFirstImage randomize: Bool) {
        showImageDuration = duration
        shouldLoop = loop

        indexOfFirstImageShown = (randomize ? Int(arc4random_uniform(UInt32(imagesArray.count))) : 0)
        nextImageIndex = indexOfFirstImageShown
        
        currentImageIndex = nextImageIndex
        nextImageIndex = ((nextImageIndex + 1) % imagesArray.count)

        if let firstImage = currentImage() {
            layer.speed = 1
            self.prepareAnimationsForImage(firstImage)
            self.startAnimationSequence()
        }
    }
    
    func advanceImageIndex() -> Bool {
        if !shouldLoop && nextImageIndex == indexOfFirstImageShown {
            // Next image is the first image, which means we are done
            kenBurnsDelegate?.finishedShowingLastImage()
            stopAnimation()
            return false
        } else {
            currentImageIndex = nextImageIndex
            nextImageIndex = ((nextImageIndex + 1) % imagesArray.count)
            return true
        }
    }
    
    func prepareAnimationsForImage(_ image: UIImage) {
        
        var origin = CGPoint.zero
        var move = CGPoint.zero
        var zoomFactor: CGFloat
        
        let resizeRatio = resizeRationFromImage(image)
        let optimus = CGSize(width: image.size.width * resizeRatio * enlargeRatio, height: image.size.height * resizeRatio * enlargeRatio)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: optimus.width, height: optimus.height))
        imageView.backgroundColor = UIColor.black
        
        // Calculate maximum acceptable move
        let maxMoveX = optimus.width - bounds.size.width
        let maxMoveY = optimus.height - bounds.size.height
        
        switch KenBurnsImageMovementDirection(rawValue:  Int(arc4random() % 4))! {
        case .upLeft:
            zoomFactor = 1.25
            move.x   = -maxMoveX
            move.y  = -maxMoveY
            
        case .downLeft:
            origin.y = bounds.size.height - optimus.height
            zoomFactor = 1.10
            move.x = -maxMoveX
            move.y = maxMoveY
            
        case .upRight:
            origin.x = bounds.size.width - optimus.width
            zoomFactor = 1.30
            move.x = maxMoveX
            move.y = -maxMoveY
            
        case .downRight:
            origin.x = bounds.size.width - optimus.width
            origin.y = bounds.size.height - optimus.height
            zoomFactor = 1.20
            move.x = maxMoveX
            move.y = maxMoveY
        }
        
        
        // Image Layer
        
        let imageLayer = CALayer()
        imageLayer.contents = image.cgImage
        imageLayer.anchorPoint = CGPoint.zero
        imageLayer.bounds = CGRect(origin: CGPoint.zero, size: optimus)
        imageLayer.position = origin
        imageView.layer.addSublayer(imageLayer)
        
        
        
        // Cleanup: Remove previous image view
        
        if subviews.count > 0 {
            subviews[0].removeFromSuperview()
        }
        
        
        // Add new image view
        
        addSubview(imageView)
        
        
        // Transforms
        
        let rotationAngleRadians = CGFloat(arc4random() % 9) / 100
        let rotation = CGAffineTransform(rotationAngle: rotationAngleRadians)
        
        let pan = CGAffineTransform(translationX: move.x, y: move.y)
        let panWithRotation = rotation.concatenating(pan)
        
        let zoom = CGAffineTransform(scaleX: zoomFactor, y: zoomFactor)
        let zoomedPanWithRotation = zoom.concatenating(panWithRotation)
        
        var startTransform: CGAffineTransform
        
        switch zoomMode {
        case .random:
            if randomBool() {
                startTransform = zoomedPanWithRotation
                finishTransform = CGAffineTransform.identity
            } else {
                fallthrough
            }
        case .in:
            startTransform = CGAffineTransform.identity
            finishTransform = zoomedPanWithRotation
            
        case .out:
            startTransform = zoomedPanWithRotation
            finishTransform = CGAffineTransform.identity
            
        }
        
        imageView.transform = startTransform
        currentImageView = imageView
        
        // Transform the image view
    }
    
    func startAnimationSequence(withFade fade: Bool = true) {
        guard isPaused == false else {
            return
        }
        
        // Fade in image layer
        
        if fade {
            let animation = CATransition()
            animation.duration = 1
            animation.type = kCATransitionFade
            layer.add(animation, forKey: nil)
        }
        
        // Animation prepared transformations: zoom, pan and rotation
        
        UIView.animate(
            withDuration: showImageDuration,
            delay: 0,
            options: .beginFromCurrentState,
            animations: {
                if let endState = self.finishTransform, let image = self.currentImageView {
                    image.transform = endState
                }
            }, completion: { completed in
                if completed && self.advanceImageIndex() {
                    if let nextImage = self.currentImage() {
                        self.prepareAnimationsForImage(nextImage)
                        self.startAnimationSequence()
                    }
                }
            }
        )
    }
    
    //MARK: - Notification Responses
    
    /// If ´screenOrientationAwareness´ is true, this notification response will relayout and present the next image whenever the screen orientation changes.
    internal func deviceOrientationDidChange() {

        var didActuallyChange = false
        let newOrientation: UIDeviceOrientation = UIDevice.current.orientation
        
        if (UIDeviceOrientationIsPortrait(newOrientation) && !portrait) {
            portrait = true
            didActuallyChange = true
        } else if (UIDeviceOrientationIsLandscape(newOrientation) && portrait) {
            portrait = false
            didActuallyChange = true
        }
        
        if let visibleImage = currentImage(), didActuallyChange {
            prepareAnimationsForImage(visibleImage)
            startAnimationSequence(withFade: false)
        }
    }
    
    //MARK: - Private Utilities
    
    fileprivate func randomBool() -> Bool {
        return arc4random_uniform(100) < 50
    }
    
    /// Find the maximum ratio for the image given the bounds, used to calculate the maximum size of the image based on its ratio.
    fileprivate func resizeRationFromImage(_ image: UIImage) -> CGFloat {
        let widthRatio = bounds.size.width / image.size.width
        let heightRatio = bounds.size.height / image.size.height
        return max(widthRatio, heightRatio)
    }
}
