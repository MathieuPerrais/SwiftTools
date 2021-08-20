//
//  UIView+Parent.swift
//  
//
//  Created by Mathieu Perrais on 5/19/21.
//


#if !os(macOS)
import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
#endif
