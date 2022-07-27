//
//  UIViewExtension.swift

import Foundation
import UIKit

extension UIView{
    func customActivityIndicator(view: UIView, widthView: CGFloat? = nil, backgroundColor: UIColor? = nil, message: String? = nil,colorMessage:UIColor? = nil ) -> UIView{
        //Config UIView
//        self.backgroundColor = backgroundColor ?? UIColor.clear
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.clear
        
        let spinnerView : UIView = UIView()
            spinnerView.backgroundColor = UIColor.clear
        
        let selfWidth = CGFloat(80)
        let selfHeigh = CGFloat(80)
        
        let selfFrameX = (view.frame.width / 2) - (selfWidth / 2)
        let selfFrameY = (view.frame.height / 2) - (selfHeigh / 2)
        
        let loopImages = UIImageView()
            loopImages.image = UIImage(named:"Loader_Spinner")
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = CGFloat(.pi * 2.0)
            rotateAnimation.isRemovedOnCompletion = false
            rotateAnimation.duration = TimeInterval(1.3)
            rotateAnimation.repeatCount = Float.infinity
        
        loopImages.layer.add(rotateAnimation, forKey: nil)
        
        let imageFrameX = CGFloat(10)
        let imageFrameY = CGFloat(10)
        let imageWidth = CGFloat(60)
        let imageHeight = CGFloat(60)
        
        //add loading and label to customView
        loopImages.sendSubviewToBack(self)
        
        spinnerView.addSubview(loopImages)
        self.addSubview(spinnerView)
        
        //Define frames
        //UIViewFrame
//        self.frame = CGRect(x: selfFrameX, y: selfFrameY, width: selfWidth , height: selfHeigh)
        
        let screenSize = UIScreen.main.bounds
        let screenSizeWidth = screenSize.width
        let screenSizeHeight = screenSize.height
        self.frame = CGRect(x: screenSize.origin.x, y: screenSize.origin.y, width: screenSizeWidth, height: screenSizeHeight)
        
        //spinnerViewFrame
        spinnerView.frame = CGRect(x: selfFrameX, y: selfFrameY, width: selfWidth , height: selfHeigh)
        spinnerView.backgroundColor = UIColor.clear
        
        //ImageFrame
        loopImages.frame = CGRect(x: imageFrameX, y: imageFrameY, width: imageWidth, height: imageHeight)
        
        return self
    }
}

extension Notification.Name {
    static let appTimeout = Notification.Name("appTimeout")
}

extension UIWindow {
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }

    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if vc.isKind(of: UINavigationController.self) {
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom(vc: navigationController.visibleViewController!)

        } else if vc.isKind(of: UITabBarController.self) {
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)

        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController.presentedViewController!)
            } else {
                return vc;
            }
        }
    }
}

struct Name {
    let first: String
    let last: String

    init(first: String, last: String) {
        self.first = first
        self.last = last
    }
}

extension Name {
    init(fullName: String) {
        var names = fullName.components(separatedBy: " ")
        let first = names.removeFirst()
        let last = names.joined(separator: " ")
        self.init(first: first, last: last)
    }
}

extension Name: CustomStringConvertible {
    var description: String { return "\(first) \(last)" }
}

extension UILabel {
    func addTrailing(image: UIImage, text:String) {
        let attachment = NSTextAttachment()
        attachment.image = image

        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: text, attributes: [:])

        string.append(attachmentString)
        self.attributedText = string
    }
    
    func addLeading(image: UIImage, text:String, height: CGFloat) {
        let attachment = NSTextAttachment()
            attachment.image = image
            attachment.setImageHeight(height: height)

        let attachmentString = NSAttributedString(attachment: attachment)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(attachmentString)
        
        let spaceString = NSMutableAttributedString(string: " ", attributes: [:])
        mutableAttributedString.append(spaceString)
        
        let string = NSMutableAttributedString(string: text, attributes: [:])
        mutableAttributedString.append(string)
        self.attributedText = mutableAttributedString
    }
}

extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y , width: ratio * height, height: height)
    }
}
