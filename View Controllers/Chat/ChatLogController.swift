//
//  ChatLogController.swift
//  calendarApp
//
//  Created by Lance Owide on 06/01/2020.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase
import CoreData



var userMessagesRef: DatabaseReference!
//var chatMessageListener: UInt!
//var chatListenerInt = Bool()


//array to hold the message and save them into core data
var CDMessages = [CoreDataChatMessages]()


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var keyboardFrame = CGRect()

    var messagesChat = [CDMessage]()
    
//    variable used to house whether the keyboard has been activated and the resigned, we do not want to adjust the keyboard if the user retaps it
    var keyboardIsActive = false
    
    
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
        
//        fetch the message from the DB for the specific event we are viewing
        let predicate = NSPredicate(format: "eventID == %@", argumentArray: [currentUserSelectedEvent.eventID])
        var eventChats = CoreDataCode().serialiseChatMessages(predicate: predicate, usePredicate: true)
        
//        sort the messages by their timestamp
        eventChats.sort {
            $0.timestamp! < $1.timestamp!
        }
        
        messagesChat = eventChats
    
        print("number of messages \(eventChats.count)")
        
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                    self.collectionView.scrollToLast()
                    print("reload the chat tableview")
                })
//            }, withCancel: nil)
//        }
    }
    
    var inputTextField: UITextView = {
//        let textField = UITextField()
        let textField = UITextView()
//        textField.text = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 3
        textField.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textField.layer.cornerRadius = 15
        
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("running view did load")
                
        
        //        set the badge number to 0
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
//        add a tap gesture to remove the keyboard when tapped
        let tapGesture = UITapGestureRecognizer(target: self,
                                                            action: #selector(hideKeyBoard))
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 100, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.addGestureRecognizer(tapGesture)
        
        collectionView?.keyboardDismissMode = .interactive
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:MyVariables.colourLight]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.title = ("\(currentUserSelectedEvent.eventDescription)")
        
        
        
        
        //            create a button to dismiss the  viewController
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 10, height: 10)
        menuBtn.setTitle("X", for: .normal)
        menuBtn.setTitleColor(MyVariables.colourLight, for: .normal)
        menuBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        navigationItem.leftBarButtonItem = menuBarItem
        
        
        
        observeMessages()
        
// set observer for UIApplication.willEnterForegroundNotification
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
// set observer for UIApplication.willResignActiveNotification
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        
//        if the user gets a message for the current event they are viewing we immediately remove the event from the message notification array
        NotificationCenter.default.addObserver(self, selector: #selector(messageNotificationUpdate), name: .notificationsReloaded, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(chatNotificationTappedSelector), name: .chatNotificationTapped, object: nil)
        
//        notification for when the user adds a new chat, refreshes the chats the user is looking at
        NotificationCenter.default.addObserver(self, selector: #selector(chatNotificationTappedSelector), name: .newChatDataLoaded, object: nil)

        
//        funcition to remove notification from the realtime database
        updateNotificationArray()
        
//        set the message notifiction to false so that the notification on the front page is not displayed
        newMessageNotification = false
        
        setupKeyboardObservers()
    }
    
    
//    when the user opens the app from a chat notification and the chat page is up, we need to force the observe message to reload, we resign and then reassing it
    @objc func chatNotificationTappedSelector(){
//        add the new chats to the tableview
        observeMessages()
        
//        the keyboard is active we need to refresh the height adjustment
        if keyboardIsActive == true{
            messageSpacingCalc()
        }
    }
    
    
    @objc func closeTapped() {
        keyboardIsActive = false
        self.dismiss(animated: true) {
//            we set the notification to reload the data in the chat tab
            NotificationCenter.default.post(name: .newChatDataLoaded, object: nil)
            NotificationCenter.default.post(name: .notificationsReloaded, object: nil)
        }
    }
    

   
//    function for process when the app has returned from the background, we need to do this otherwise the listener will not re-engage
    @objc func willEnterForeground(){
        print("running func willEnterForeground")
        observeMessages()
        //        remove the chat notifications for the event and the homepage
//        updateNotifications()
        
    }
    
//    function to remove the new message notification
    @objc func messageNotificationUpdate(){
//        confirm this event has been added to the message notifications
        if chatNotificationiDs.contains(currentUserSelectedEvent.eventID){
            
//            self.updateNotifications()
        }
        
    }
    
//    function to detect when the app has gone into the background / the user has enetered multi tasking mode
    @objc func  willResignActive(){
       print("willResignActive running")
        inputTextField.resignFirstResponder()
        //        we remove the listeners and set the chat int, this ensures that when the user reopens that app from a notification the chat updates
//        userMessagesRef.removeAllObservers()
//        chatListenerInt = false
        
//        print("willResignActive - chatListenerInt\(chatListenerInt)")
        
    }
    
    
//    @objc func dismissKeyboard() {
//        keyboardIsActive = false
//        print("dismissKeyboard running")
//        //Causes the view (or one of its embedded text fields) to resign the first responder status.
//        collectionView.keyboardDismissMode = .interactive
//
//        view.endEditing(true)
//    }
        
    
    lazy var inputContainerView: UIView = {
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        containerView.backgroundColor = UIColor.white
//        self.view.addGestureRecognizer(tap)
        
//        trying to add a bottom piece
        let bottomView = UIView()
        bottomView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        bottomView.backgroundColor = UIColor.lightGray
        containerView.addSubview(bottomView)
        
        bottomView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        bottomView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
//        trying to add a top piece
        let topView = UIView()
        topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        topView.backgroundColor = UIColor.white
        containerView.addSubview(topView)
                
        topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State())
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.tintColor = MyVariables.colourPlanrGreen
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
        self.inputTextField.widthAnchor.constraint(equalToConstant: self.view.frame.width - 80).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: topView.heightAnchor, constant: -10).isActive = true

        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(red: 220, green: 220, blue: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(separatorLineView)
        //x,y,w,h
        separatorLineView.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func handleKeyboardWillShow(_ notification: Notification) {
        
//        we need to check if the keyboard is already the first responder, otherwise we will push the message of the screen again, this is being called when the viewload, we dont know how to stop this, so we check if there are no messages first
        
        keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
//        set the global variable for the keyboard
        print("handleKeyboardWillShow is running keyboardFrame!.height \(keyboardFrame.height)")
        
//        if keyboardIsActive == false && messagesChat.count != 0 && keyboardFrame.height != 100{
//            print("handleKeyboardWillShow - keyboardIsActive = false")
//        run the func to set the height of the texrt
        messageSpacingCalc()
        keyboardIsActive = true
//        }
//        else{
//            print("handleKeyboardWillShow - keyboardIsActive = true")
//        }
    }
    
//    function for calculating the space required to show the messages correctly
    func messageSpacingCalc(){
        print("running func messageSpacingCalc")
        
        //       need to check the heigt of the messages and compare them to the heigt of the keyboard, we do not want to move the messages off the screen if they are the only ones
                var height: CGFloat = 0
                for message in messagesChat{
//                    print("message height \(height)")
                    height = height + estimateFrameForText(message.text!).height + 40
                }

        //        we do not want to move the mesasge there off the page, hence we check to see how tall the messages are. Remaining screen = screenHeight - (topdistance + keyboardHeight + text entry)
                let remainingSpace = screenHeight - topDistance - CGFloat(keyboardFrame.height) - 100
                
                print("handleKeyboardWillShow height \(height) keyboardFrame!.height \(keyboardFrame.height) view.frame.origin.y \(view.frame.origin.y) remainingSpace \(remainingSpace) screenHeight \(screenHeight) topDistance: \(topDistance)")
                
                if height < remainingSpace{
                    print("messages will not be shifted up")
                }
                else{
                    print("messages willapgest be shifted up")
//                    to ensure we do not move the view up each time the fucntion is called, we rest the view starting point and then make the adjustement
                    self.view.frame.origin.y = 0
//            we adjust the amount the screen is shifted to account for the blank space on the screen,
                    var screenAdjust = screenHeight - topDistance - height - 100
                    if screenAdjust < 0{
                      screenAdjust = 100
                    }
                    print("screenAdjust \(screenAdjust)")
                    
                self.view.frame.origin.y -= keyboardFrame.height - screenAdjust
                    print("new view.frame.origin.y \(view.frame.origin.y)")
                }
    }
    
    @objc func handleKeyboardWillHide(_ notification: Notification) {
        keyboardIsActive = false
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
//        self.view.endEditing(true)
        
        self.view.frame.origin.y = 0
//        UIView.animate(withDuration: keyboardDuration!, animations: {
//            self.view.layoutIfNeeded()
//        })
    }
    
    
    @objc func hideKeyBoard() {
        print("running keyboard will hide")
        self.inputTextField.resignFirstResponder()

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesChat.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messagesChat[indexPath.item]
//        convert the time interval to a display date
        let dateFormatterDisplayDate = DateFormatter()
        dateFormatterDisplayDate.dateFormat = "dd MMM HH:mm"
        dateFormatterDisplayDate.locale = Locale(identifier: "en_US_POSIX")
        
        let timeInterval = Double(message.timestamp!)
//       create NSDate from Double (NSTimeInterval)
        let myNSDate = Date(timeIntervalSince1970: timeInterval)
        
        let displayDate = dateFormatterDisplayDate.string(from: myNSDate)
        
        cell.textViewName.text = message.fromName! + "  -  " + displayDate
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
    
    fileprivate func setupCell(_ cell: ChatMessageCell, message: CDMessage) {
        
        if message.fromId == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = MyVariables.colourPlanrGreen
            cell.textView.textColor = UIColor.white
            cell.textViewName.textColor = UIColor.white
            cell.profileImageView.isHidden = true
//            stops the user from being able to interact with chats already on the screen
            cell.isUserInteractionEnabled = false
            
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
    
// before the view is about to appear we set the observe message, this ensures that when the user moves the chat to the back
    override func viewWillAppear(_ animated: Bool) {
         print("running view will appear")
        //        reset the messages chat list
        observeMessages()
        
//        remove the chat ID from the notifications
        chatNotificationiDs.removeAll(where: {$0 == currentUserSelectedEvent.eventID})
        NotificationCenter.default.post(name: .notificationsReloaded, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("running view will disappear")
//        userMessagesRef.removeAllObservers()
//        chatListenerInt = false
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
        
//        check if the input text is blank, if so dont send the message
        if inputTextField.text! == ""{
            print("text is empty, don't send")
        }
        else{
            
//        log the change event
        Analytics.logEvent(firebaseEvents.chatSent, parameters: ["chatSent" : true])
            
        let ref = Database.database().reference().child("messages").child(currentUserSelectedEvent.eventID)
        let ref2 = Database.database().reference().child("messageNotifications").child(currentUserSelectedEvent.eventID)
        let childRef = ref.childByAutoId()
        let fromId = user!
        let timestamp = Int(Date().timeIntervalSince1970)
        let dbStore = Firestore.firestore()
        let userIDs = currentUserSelectedEvent.users
            
//            move the text to a property
        let newText = inputTextField.text
            
//            remove the text in the text field to allow the user to send a new message
        self.inputTextField.text = nil
     
        
        for ids in userIDs{
//        we do not want to write a notification if we sent the message, this writes to the real time database for notifications
            if ids == user!{
            }
            else{
            ref2.child(ids).updateChildValues(["notification": true])
            }
        }
                        
//        Posts the message into the RealTime DB, first we use getUserName to ensure we have the latest name for the user
        getUserName { (fromName) in
            
            let values = ["text": newText!, "fromId": fromId, "timestamp": timestamp, "fromName": fromName] as [String : Any]
            
//            commit the new chat into the CD
//             To get the messageID we remove the rest of the DB reference and just show the new location
            let newIDFullString = ("\(childRef)")
            let newID = newIDFullString.replacingOccurrences(of: "https://calendarplayground-3c791.firebaseio.com/messages/\(currentUserSelectedEvent.eventID)/", with: "")
            print("new message posted with ref  newID \(newID)")
            
            self.commitSingleChatDB(fromId: fromId, text: newText!, fromName: fromName, timestamp: Int64(timestamp), toId: "", eventID: currentUserSelectedEvent.eventID, messageID: newID)
            
            NotificationCenter.default.post(name: .newChatDataLoaded, object: nil)

        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }


            }}
            //        This writes to the FireStore for our notification table
                    for ids in userIDs{
                        //        we do not want to write a notification if we sent the message
                        if ids == user!{
                        }
                        else{
            //                adds the chat eventIDs to the notification database
                         dbStore.collection("userNotification").document(ids).setData(["chatNotificationEventIDs" : [currentUserSelectedEvent.eventID]], merge: true)
                }
        }
        }}
}


extension UICollectionView {
    func scrollToLast() {
//        print("running func scrollToLast numberOfSections \(numberOfSections)")
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
        print("scrolling to the bottom lastItemIndexPath \(lastItemIndexPath)")
        
        if ChatLogController().messagesChat.count == 1{
//            print("scrolling to the first item on the chat")
            scrollToItem(at: lastItemIndexPath, at: .top, animated: false)
        }
        else{
//        print("scrolling to the last item on the chat")
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: false)
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


