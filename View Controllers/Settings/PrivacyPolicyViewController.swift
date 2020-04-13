//
//  PrivacyPolicyViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 07/08/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {


    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        setup the navigation bar
        navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)
        
        let string = "View our privacy and data policy"
        
        let attributedLinkString = NSMutableAttributedString(string: string, attributes:[NSAttributedString.Key.link: URL(string: "https://planr.me/Planr-App-Privacy-Policy/")!])
        
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.attributedText = attributedLinkString
    }
}
