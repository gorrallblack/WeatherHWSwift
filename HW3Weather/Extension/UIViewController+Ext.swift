//
//  UIViewController+Ext.swift

import Foundation
import UIKit

extension UIViewController {
    func showLoadingScreen() {
        DispatchQueue.main.async {
            self.view.addSubview(UIView().customActivityIndicator(view: self.view,backgroundColor: UIColor.clear))
        }
    }
    
    func dismissCustomLoading() {
        DispatchQueue.main.async {
            self.view.subviews.last?.removeFromSuperview()
        }
    }
}
