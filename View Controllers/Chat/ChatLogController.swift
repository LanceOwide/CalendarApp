//
//  ChatLogController.swift
//  calendarApp
//
//  Created by Lance Owide on 06/01/2020.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift


var messagesChat = [Message]()
var userMessagesRef: DatabaseReference!


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    /// Get distance from top, based on status bar and navigation
    public var topDistance : CGFloat{
         get{
             if self.navigationController != nil && !self.navigationController!.navigationBar.isTranslucent{
                 return 0
             }else{
                let barHeight=self.navigationController?.navigationBar.frame.height ?? 0
                let statusBarHeight = UIApplication.shared.isStatusBarHidden ? CGFloat(0) : UIApplication.shared.statusBarFrame.height
                return barHeight + statusBarHeight
             }
         }
    }
    

    func observeMessages() {

        userMessagesRef = Database.database().reference().child("messages").child(currentUserSelectedEvent.eventID)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in

                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message(dictionary: dictionary)

                //do we need to attempt filtering anymore?
                messagesChat.append(message)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    self.collectionView.scrollToLast()
                })
            }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: topDistance, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
        updatePendingNotificationStatus()
        
//        testing removing the IQKeyboard
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatLogController.self)
        
//        reset the messages chat list
        messagesChat.removeAll()
        
        self.title = "Event Chat"
        
        observeMessages()
        
//        funcition to remove notification from the realtime database
        updateNotificationArray()
        
//        set the message notifiction to false so that the notification on the front page is not displayed
        newMessageNotification = false
        
        setupKeyboardObservers()
    }
    
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard running")
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        collectionView.keyboardDismissMode = .interactive
        
        self.view.endEditing(true)
    }
    
    lazy var inputContainerView: UIView = {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        containerView.backgroundColor = UIColor.white
        self.view.addGestureRecognizer(tap)
        
//        trying to add a bottom piece
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        bottomView.backgroundColor = UIColor.lightGray
        containerView.addSubview(bottomView)
        
        bottomView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
//        trying to add a top piece
        let topView = UIView()
        topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        topView.backgroundColor = UIColor.white
        containerView.addSubview(topView)
                
        topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        topView.addSubview(sendButton)
        //x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: topView.heightAnchor).isActive = true
        
        topView.addSubview(self.inputTextField)
        //x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        self.inputTextField.widthAnchor.constraint(equalToConstant: screenWidth - 80).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: topView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220, green: 220, blue: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: topView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        print("handleKeyboardWillShow is running keyboardFrame!.height \(keyboardFrame!.height)")
        
//       need to check the heigt of the messages and compare them to the heigt of the keyboard
        
        var height: CGFloat = 0
        for message in messagesChat{
            height = height + estimateFrameForText(message.text!).height + 40
        }
        
        print("handleKeyboardWillShow height \(height)")

        if height + 75 < keyboardFrame!.height{
            self.view.frame.origin.y = 0
        }
        else{
        self.view.frame.origin.y -= keyboardFrame!.height
        }
        
        
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        self.view.frame.origin.y = 0
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesChat.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messagesChat[indexPath.item]
        cell.textViewName.text = message.fromName
        cell.textView.text = message.text
        
        setupCell(cell, message: message)
        
        //sets the bubble width based on name, if it is longer than the text, or the text if it is longer
        
        if estimateFrameForText(message.text!).width > estimateFrameForText(message.fromId!).width{
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.text!).width + 32
        }
        else{
         
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(message.fromId!).width + 32
            
        }
        
        return cell
    }
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: Message) {
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.textViewName.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240, green: 240, blue: 240)
            cell.textView.textColor = UIColor.black
            cell.textViewName.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        userMessagesRef.removeAllObservers()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        //get estimated height
        if let text = messagesChat[indexPath.item].text {
            height = estimateFrameForText(text).height + 40
        }
        
        let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    var containerViewTopAnchor: NSLayoutConstraint?
    
    
    
//    function to remove the messagenotification once the user opens the chat
    func updateNotificationArray(){
        
      let ref2 = Database.database().reference().child("messageNotifications").child(currentUserSelectedEvent.eventID)
        
       ref2.child(user!).updateChildValues(["notification": false])
    }
    
    
    @objc func handleSend() {
        let ref = Database.database().reference().child("messages").child(currentUserSelectedEvent.eventID)
        let ref2 = Database.database().reference().child("messageNotifications").child(currentUserSelectedEvent.eventID)
        let childRef = ref.childByAutoId()
        let fromId = user!
        let timestamp = Int(Date().timeIntervalSince1970)
        let dbStore = Firestore.firestore()
        
        let userIDs = currentUserSelectedEvent.users
     
        
        for ids in userIDs{
            
//        we do not want to write a notification if we sent the message, this writes to the real time database for notifications
            if ids == user!{
            }
            else{
            ref2.child(ids).updateChildValues(["notification": true])
            }
        }
                        
//        This writes to the FireStore for our notification table
        for ids in userIDs{
            //        we do not want to write a notification if we sent the message
            if ids == user!{
                
            }
            else{
//                adds true to the users userNotification field, this shows the chat icon on the homepage
                if currentUserSelectedEvent.chosenDate != ""{
            dbStore.collection("userNotification").document(ids).setData(["chatNotificationDateChosen" : true], merge: true)
            }
            else{
            dbStore.collection("userNotification").document(ids).setData(["chatNotificationPending" : true], merge: true)
            }
                
             dbStore.collection("userNotification").document(ids).setData(["chatNotificationEventIDs" : [currentUserSelectedEvent.eventID]], merge: true)
                
            }}
        
//        Posts the message into the RealTime DB, first we use getUserName to ensure we have the latest name for the user
        getUserName { (fromName) in
            
            let values = ["text": self.inputTextField.text!, "fromId": fromId, "timestamp": timestamp, "fromName": fromName] as [String : Any]

        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            self.inputTextField.text = nil
            }}}
}


extension UICollectionView {
    func scrollToLast() {
        print("running func scrollToLast")
        guard numberOfSections > 0 else {
            return
        }

        let lastSection = numberOfSections - 1

        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
////        determine if we should scroll to the top or the bottom of the chat window, we can ue the total size of the chat message to determine this.
//        var height: CGFloat = 0
//        for message in messagesChat{
//            height = height + estimateFrameForText(message.text!).height + 40
//        }
//        print("running func scrollToLast height \(height)")
        
//        Trying a crude method for showing the correct message, if there are only two message we scroll to the top, if not we scroll to the bottom
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1,
        section: lastSection)
        
        if messagesChat.count == 1{
            print("scrolling to the first item on the chat")
            scrollToItem(at: lastItemIndexPath, at: .top, animated: true)
        }
        else{
        print("scrolling to the last item on the chat")
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
        }
    }
    
     func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.systemFont(ofSize: 16)]), context: nil)
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

