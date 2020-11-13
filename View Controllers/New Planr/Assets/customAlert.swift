//
//  customAlert.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/21/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

var verificationCode1 = String()

struct AlertButton {
    var title: String!;
    var action: (() -> Swift.Void)? = nil;
    var titleColor: UIColor?
    var backgroundColor: UIColor?
}

struct AlertPayload {
    var title: String!
    var titleColor: UIColor?
    var message: String!
    var messageColor: UIColor?
    var buttons: [AlertButton]!
    var backgroundColor: UIColor?
    var inputTextHidden: Bool?
}

class customAlertController: UIViewController{
    
    var payload: AlertPayload!
    @IBOutlet var heading: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button1: UIButton!
    @IBOutlet var inputText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("creating the alert payload.messageColor \(payload.messageColor)  payload.titleColor \(payload.titleColor) payload.backgroundColor \(payload.backgroundColor)")
        
//        setting for the ale

        if (payload.buttons.count == 1 && payload.inputTextHidden == true) {
            createButton(uiButton: button1, alertButton: payload.buttons[0])
            heading.text = payload.title
            message.text = payload.message
            heading.font = UIFont.boldSystemFont(ofSize: 18)
            message.font = UIFont.systemFont(ofSize: 14)
        }
        if (payload.buttons.count == 1 && payload.inputTextHidden == false) {
            createButton(uiButton: button1, alertButton: payload.buttons[0])
            heading.text = payload.title
            heading.font = UIFont.boldSystemFont(ofSize: 18)
        }
        else if (payload.buttons.count == 2) {
            createButton(uiButton: button1, alertButton: payload.buttons[0])
            createButton(uiButton: button2, alertButton: payload.buttons[1])
            heading.text = payload.title
            message.text = payload.message
            heading.font = UIFont.boldSystemFont(ofSize: 18)
            message.font = UIFont.systemFont(ofSize: 14)
        }
        else if (payload.buttons.count == 0){
            
        }
        
        if (payload.backgroundColor != nil) {
            view.backgroundColor = payload.backgroundColor;
        }
    }
    
    //MARK: Create custom alert buttons
    private func createButton(uiButton: UIButton, alertButton: AlertButton) {
        uiButton.setTitle(alertButton.title, for: .normal);
        
        uiButton.layer.borderWidth = 1
        uiButton.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
        uiButton.layer.cornerRadius = 6
        uiButton.translatesAutoresizingMaskIntoConstraints = false
        
        if (alertButton.titleColor != nil) {
            uiButton.setTitleColor(alertButton.titleColor, for: .normal);
        }
        if (alertButton.backgroundColor != nil) {
            uiButton.backgroundColor = alertButton.backgroundColor
        }
    }
    
    
    @IBAction func button1Tapped() {
        parent?.dismiss(animated: false, completion: nil);
        print("button 1 pressed")
        if payload.inputTextHidden == false{
            print("button 1 pressed inputText.text \(inputText.text)")
            if inputText.text != nil{
            verificationCode1 = inputText.text!
            }
        }
        payload.buttons[0].action?()  
    }
    
    @IBAction func button2Tapped() {
        parent?.dismiss(animated: false, completion: nil);
        print("button 2 pressed")
        payload.buttons[1].action?();
    }
    
    
}

//EXAMPLE CODE TO ADD ALERTS

//@IBAction func oneButtonAlertTapped() {
//    let utils = Utils();
//    
//    let button = AlertButton(title: "OK", action: {
//        print("OK clicked");
//    }, titleColor: UIColor.blue, backgroundColor: UIColor.cyan);
//    
//    let alertPayload = AlertPayload(title: "One Button Alert", titleColor: UIColor.red, message: "This custom alert has just one action button", messageColor: UIColor.green, buttons: [button], backgroundColor: UIColor.black, inputTextHidden: true)
//    
//    utils.showAlert(payload: alertPayload, parentViewController: self);
//}
//
//@IBAction func twoButtonAlertTapped() {
//    let utils = Utils();
//    
//    let button1 = AlertButton(title: "Yes", action: {
//        print("Yes clicked");
//    }, titleColor: UIColor.red, backgroundColor: UIColor.clear);
//    
//    let button2 = AlertButton(title: "No", action: {
//        print("No clicked");
//    }, titleColor: UIColor.lightGray, backgroundColor: UIColor.clear);
//    
//    let alertPayload = AlertPayload(title: "Two Button Alert", titleColor: UIColor.red, message: "Are you sure you want to delete?", messageColor: UIColor.green, buttons: [button1, button2], backgroundColor: UIColor.yellow, inputTextHidden: true)
//    
//    utils.showAlert(payload: alertPayload, parentViewController: self);
//}
