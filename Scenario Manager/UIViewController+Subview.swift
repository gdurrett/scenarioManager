//
//  UIViewController+Subview.swift
//  Scenario Manager
//
//  Created by Greg Durrett on 8/15/17.
//  Copyright © 2017 AppHazard Productions. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func insertChildController(_ childController: UIViewController, intoParentView parentView: UIView) {
        childController.willMove(toParentViewController: self)
        
        self.addChildViewController(childController)
        childController.view.frame = parentView.bounds
        //childController.view.frame = CGRect(x: 0, y: 20, width: view.bounds.width, height: view.bounds.height)
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(childController.view)
        
        childController.didMove(toParentViewController: self)
    }
    
}
