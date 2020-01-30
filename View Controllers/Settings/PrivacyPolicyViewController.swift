//
//  PrivacyPolicyViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 07/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {


    @IBOutlet weak var lblPrivacyPolicy: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        let attributedString = NSMutableAttributedString(string: "View our privacy and data policy!")
        attributedString.addAttribute(.link, value: "https://planr.me/Planr-App-Privacy-Policy/.com", range: NSRange(location: 0, length: 43))
        
        
        lblPrivacyPolicy.attributedText = attributedString
        
        
    }
    



}
