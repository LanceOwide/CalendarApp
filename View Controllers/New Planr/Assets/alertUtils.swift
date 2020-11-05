//
//  alertUtils.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/21/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class Utils {
    
    func showAlert(payload: AlertPayload, parentViewController: UIViewController, autoDismiss: Bool, timeLag: Double) {
        
        print("showAlert - AlertPayload: \(payload) - autoDismiss: \(autoDismiss) - timeLag: \(timeLag)")
        var customAlertController: customAlertController!;
        if (payload.buttons.count == 1) {
            customAlertController = self.instantiateViewController(storyboardName: "AlertScreens", viewControllerIdentifier: "OneButtonAlert") as? customAlertController
        }
        else if (payload.buttons.count == 2) {
            customAlertController = self.instantiateViewController(storyboardName: "AlertScreens", viewControllerIdentifier: "TwoButtonAlert") as? customAlertController
        }
        else if (payload.buttons.count == 0) {
                customAlertController = self.instantiateViewController(storyboardName: "AlertScreens", viewControllerIdentifier: "NoButtonAlert") as? customAlertController
            }
        else {
            // Action not supported
            return;
        }
        customAlertController?.payload = payload;
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert);
        alertController.setValue(customAlertController, forKey: "contentViewController")
        
        parentViewController.present(alertController, animated: true, completion: nil)
        
//        remove the alert after a predetermined timeframce
        if autoDismiss == true{
            DispatchQueue.main.asyncAfter(deadline: .now() + timeLag) {
                parentViewController.dismiss(animated: true, completion: nil)
            }
        }    
    }
    
    public func instantiateViewController(storyboardName: String, viewControllerIdentifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main);
        return storyboard.instantiateViewController(withIdentifier: viewControllerIdentifier);
    }
}

