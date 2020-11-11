//
//  NL_chatLogController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/26/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import CoreData

//                variable to hold the eventID and timestamp
var sortedEventDictionary = Array<(key: String, value: Int64)>()
var lastChatDict = [String: NSAttributedString]()

class NL_chatLogController: UIViewController {

     //    get the top distance of the page
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
            
        //    add the tabBar
            var tabView: NL_tabHelper = NL_tabHelper(frame: CGRect(x:0, y:0, width: screenWidth, height: 80))
        
    //    variables
        var topView = UIView()
        var collectionViewEvents: UICollectionView!
        
        let cellId = "cellId"
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupTheNavigationbar()
            
            
//            an observer to detect when the chat data has been updated, this is triggered when the chat page is closed
            NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .newChatDataLoaded, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateTables), name: .notificationsReloaded, object: nil)
            
            
            
            orderEvents{
                print("chats finished loading")
            }
            
    //        add the tabBar
            view.addSubview(tabView)
            view.addSubview(inputTopView)
            
    // Set its constraint to display it on screen
             inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
             inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: topDistance).isActive = true
             inputTopView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
             inputTopView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
             inputTopView.translatesAutoresizingMaskIntoConstraints = false
            
    // Set the tab bar to be shown
            tabView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            tabView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            tabView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tabView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            tabView.translatesAutoresizingMaskIntoConstraints = false
            tabView.imageView1.addTarget(self, action: #selector(openTabClicked1), for: .touchUpInside)
            tabView.imageView2.addTarget(self, action: #selector(openTabClicked2), for: .touchUpInside)
            tabView.imageView3.addTarget(self, action: #selector(openTabClicked3), for: .touchUpInside)
            tabView.imageView5.addTarget(self, action: #selector(openTabClicked5), for: .touchUpInside)
            tabView.imageView4.addTarget(self, action: #selector(openTabClicked4), for: .touchUpInside)

    //        set the border for the page we are on
            tabView.imageView2.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
            tabView.imageView2.layer.borderWidth = 0
            tabView.imageView2.backgroundColor = MyVariables.colourSelected
            tabView.imageView2.layer.cornerRadius = 5
            tabView.label2.textColor = MyVariables.colourPlanrGreen
            tabView.imageView2.layer.borderWidth = 1
            tabView.imageView2.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
       
        }
        
        
        //    create the progress bar and title
            lazy var inputTopView: UIView = {
                print("setting up the inputTopView")
        //        set the variables for the setup
                let sideInset = CGFloat(16)
                let monthViewHeight = CGFloat(35)
                let DOTWHeight = CGFloat(35)
                let spacerHeight = CGFloat(10)
                let separatorHeight = CGFloat(1)

             
                //   setup the view for holding the progress bar and title
                let containerView = UIView()
                containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight)
                containerView.backgroundColor = UIColor.white
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
        //        trying to add a top view
                topView.backgroundColor = UIColor.white
                topView.translatesAutoresizingMaskIntoConstraints = false
                containerView.addSubview(topView)
                topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
                topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
                topView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
                
                
    //            create three headers for the classifications of events
                let btnHeight = CGFloat(50)
                let btnWidth = CGFloat(screenWidth/3)
                
                
    //            add the collection view for the events
                let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                //        layout3.sectionHeadersPinToVisibleBounds = true
                collectionViewEvents = UICollectionView(frame: .zero, collectionViewLayout: layout)
                collectionViewEvents?.translatesAutoresizingMaskIntoConstraints = false
                collectionViewEvents?.delegate = self
                collectionViewEvents?.dataSource = self
                collectionViewEvents?.backgroundColor = .white
                collectionViewEvents?.register(NL_chatLogCell.self, forCellWithReuseIdentifier: cellId)
                
                collectionViewEvents?.isScrollEnabled = true
                collectionViewEvents?.isUserInteractionEnabled = true
                collectionViewEvents?.allowsSelection = true
                collectionViewEvents?.allowsMultipleSelection = false
                topView.addSubview(collectionViewEvents!)
                collectionViewEvents?.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
                collectionViewEvents?.widthAnchor.constraint(equalToConstant: CGFloat(screenWidth - sideInset - sideInset)).isActive = true
                collectionViewEvents?.topAnchor.constraint(equalTo: topView.topAnchor, constant: 5).isActive = true
                collectionViewEvents?.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
                

                return containerView
        }()

            func setupTheNavigationbar(){
                
                title = "Planr"
                let textAttributes = [NSAttributedString.Key.foregroundColor:MyVariables.colourPlanrGreen, NSAttributedString.Key.font:UIFont.systemFont(ofSize: 30)]
                navigationController?.navigationBar.titleTextAttributes = textAttributes

        //        setup the navigator bar items, in order to do this with a custom size we use the method of creating a frame
                let menuBtn = UIButton(type: .custom)
                menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
                menuBtn.setImage(UIImage(named:"settingsCogCodeLight"), for: .normal)
                menuBtn.addTarget(self, action: #selector(settingsPage), for: UIControl.Event.touchUpInside)

                let menuBarItem = UIBarButtonItem(customView: menuBtn)
                let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
                currWidth?.isActive = true
                let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
                currHeight?.isActive = true
                self.navigationItem.leftBarButtonItem = menuBarItem
                
                let backItem = UIBarButtonItem()
                backItem.title = ""
                backItem.tintColor = MyVariables.colourPlanrGreen
                navigationItem.backBarButtonItem = backItem
            }
    
    //    we need to remove the observers everytime we change views, so that we dont recreata them
        override func viewWillDisappear(_ animated: Bool) {
            NotificationCenter.default.removeObserver(self, name: .notificationsReloaded, object: nil)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear chatlogcontroller")
    }
        
        //function to show the settings page
            @objc func settingsPage(){
        //        push the settings page
                if let viewController = UIStoryboard(name: "NL_Settings", bundle: nil).instantiateViewController(withIdentifier: "settingsHome") as? NL_SettingsPage {
                   self.navigationController?.pushViewController(viewController, animated: true)
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    self.navigationController?.navigationItem.setHidesBackButton(false, animated: false)
                }
            }
    
            func orderEvents( completion: @escaping () -> Void){
                print("running func orderEvents")
//            fetch the chats from CoreData, we could do something with the true or false return, which tells us if there was any data (we should download all chats)

//                variable to hold the eventID and timestamp
                var emptyDictionary = Dictionary<String, Int64>()
    //            we loop through each event
                let numberOfEvents = CDEevents.count
                var y = 0
                var listOfEventIds = [String]()
                
                for n in 0..<numberOfEvents{
                    let i = CDEevents[n]
                    let eventID = i.eventID
                    listOfEventIds.append(eventID!)
//                    get all chats for a each event
                    let predicate = NSPredicate(format: "eventID == %@", argumentArray: [eventID])
                    var eventChats = CoreDataCode().serialiseChatMessages(predicate: predicate, usePredicate: true)
//                    check if there were no chats returned
                    if eventChats.count == 0{
//                     there were no chats, we add the eventId and 1 to the array. we use y to persist the order of the list for events without any chats
                        y = y+1
                        emptyDictionary[i.eventID!] = Int64(y)
                        let emptyText = NSAttributedString(string: "Be the first to send a message")
                        lastChatDict[i.eventID!] = (emptyText)
                    }
                    else{
//                    sort the timestamps to put the last chat first
                    eventChats.sort {
                        $0.timestamp! < $1.timestamp!
                    }
//                        print("eventChats.sort \(eventChats)")
//                  now the events are sorted, we want to add those with unread messages to the top of the list
//                   we need to loop through each element and moves those with unread message to the front, we do this in reverse order
//                        get the chatNotificationIDs
                        print("orderEvents chatNotificationiDs: \(chatNotificationiDs)")
                        let n = eventChats.count
                        for index in stride(from: n, through: 1, by: -1){
//                         we are using a count and an index, the first thing we need to do is change to array count
                            let indexArray = index - 1
//                            get the current chat
                            let currentChat = eventChats[indexArray]
                }
                        let lastNum = eventChats.count - 1
                        let lastchat = eventChats[lastNum]
//                        add the eventId to the dictionary
                        emptyDictionary[i.eventID!] = lastchat.timestamp! as Int64
//                        add the event text and ID to dictionary
                        let fromName = lastchat.fromName
                        let text = lastchat.text
                        
//                        define attributed for the name and text to appear different
                        let font = UIFont.boldSystemFont(ofSize: 12)
                        let attributes = [NSAttributedString.Key.font: font]
                        let attributedQuote = NSAttributedString(string: "\(fromName!): ", attributes: attributes)
                        
//                        define the attributes for the text
                        let font2 = UIFont.systemFont(ofSize: 12)
                        let attributes2 = [NSAttributedString.Key.font: font2]
                        let attributedQuote2 = NSAttributedString(string: text!, attributes: attributes2)
                        
                        let combination = NSMutableAttributedString()
                        combination.append(attributedQuote)
                        combination.append(attributedQuote2)
                        
                        lastChatDict[i.eventID!] = combination
                }}
                
//                loop through each eventID in the chatNotificationiD and check it isnt "" or no longer exists as an event, this ensures we dont keep a chat notification for an event that no longer exists
                var newList = [String]()
                for notification in chatNotificationiDs{
                        if listOfEventIds.contains(notification){
                            newList.append(notification)
                        }
                        else{
    
                        }
                }
                chatNotificationiDs = newList
                print("chatNotificationiDs \(chatNotificationiDs)")
                
                sortedEventDictionary = emptyDictionary.sorted{ $0.value > $1.value }
                print("sortedEventDictionary \(sortedEventDictionary)")
                completion()
            
        }
    
    @objc func updateTables(){
        print("new chat data, updaing the tables")
        orderEvents{
            self.collectionViewEvents.reloadData()
        }
    }
    }

    //extension to be added to all tabbed viewControllers
    extension NL_chatLogController{
        
        @objc func openTabClicked1(){
         print("option 1 clicked")
                
            if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_HomePage") as? NL_HomePage {
               self.navigationController?.pushViewController(viewController, animated: false)
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
            }
         
        }
        
        @objc func openTabClicked2(){
         print("chat pressed")
            if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_chatLogController") as? NL_chatLogController {
               self.navigationController?.pushViewController(viewController, animated: false)
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
            }
        }
        
        @objc func openTabClicked3(){
            print("create event pressed 3")
            
    //        we push the viewController to the front
            let secondStoryBoard = UIStoryboard(name: "NL-CreateEvent", bundle: nil)
            if let viewController = secondStoryBoard.instantiateViewController(withIdentifier: "createEvent1") as? NL_CreateEvent {
            let navController = UINavigationController(rootViewController: viewController)
                self.navigationController?.present(navController, animated: true, completion: nil)
            }
        }
        
        
        @objc func openTabClicked4(){
         print("notification  pressed")
         
            if let viewController = UIStoryboard(name: "NL_HomePage", bundle: nil).instantiateViewController(withIdentifier: "NL_NotificationsController") as? NL_NotificationsController {
               self.navigationController?.pushViewController(viewController, animated: false)
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
            }
    }
        
        @objc func openTabClicked5(){
         print("Events page pressed")
            if let viewController = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventsViewController") as? NL_eventsViewController {
               self.navigationController?.pushViewController(viewController, animated: false)
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
            }
        }
    }

    //extention to manage the collectionView of dates
    extension NL_chatLogController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
        
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            var numberOfItems = Int()
            
            numberOfItems = CDEevents.count
 
            return numberOfItems
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NL_chatLogCell
            
//            we need to determine how to order that chats based on the latest available timestamp
            let eventDict = sortedEventDictionary[indexPath.row]
//            get the event data for the event
            let predicate = NSPredicate(format: "eventID = %@", eventDict.key)
            let predicateReturned = self.serialiseEvents(predicate: predicate, usePredicate: true)
            if predicateReturned.count == 0{
                print("something went wrong")
            }
            else{
                let event = predicateReturned[0]
                cell.lbleventTitle.text = event.eventDescription
//                we set the last available chat to the cell location
                let text = lastChatDict[event.eventID]
                cell.lbleventLocation.attributedText = text

//                if the chat hasnt been read we want to highlight it
                    if chatNotificationiDs.contains(event.eventID){
                    print("highlighting the message")
                    cell.lblchatNotification.isHidden = false
                    cell.lbleventLocation.font = UIFont.boldSystemFont(ofSize: 14)
                }
                else{
                    cell.lblchatNotification.isHidden = true
                    cell.lbleventLocation.font = UIFont.systemFont(ofSize: 12)
                
            }
                
                let time = eventDict.value
//                we check if the time is set to 100, this means there were no chats
                if eventDict.value < 10000{
                  cell.lblstatus.text = ""
                }
                else{
//                else we set the time to the last chat time
                    let displayDate = covertToChatFormat(inputTime: TimeInterval(time))
                
                cell.lblstatus.text = displayDate
                    cell.lblstatus.adjustsFontSizeToFitWidth = true
                }
            }
            
            
            return cell
        }
        
    //    did select item at
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         
//            get the event ID
            let eventDict = sortedEventDictionary[indexPath.row]
            
//            remove the chat from the list of chats
            chatNotificationiDs.removeAll(where: {$0 == eventDict.key})
            print("didselect - chatNotificationIDsDefaults \(chatNotificationiDs)")


//            post a notificaton to get the table to reload
            NotificationCenter.default.post(name: .newChatDataLoaded, object: nil)
            
//            we need to get the event data and serialise it as the current event
            let predicate = NSPredicate(format: "eventID = %@", eventDict.key)
            let predicateReturned = self.serialiseEvents(predicate: predicate, usePredicate: true)
            if predicateReturned.count == 0{
                print("something went wrong")
            }
            else{
            currentUserSelectedEvent = predicateReturned[0]
                        
            //            set the availability for the event
            currentUserSelectedAvailability = serialiseAvailability(eventID: eventDict.key)
            prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                            
//                            once we have loaded the event we pop the chat log controller
                            if let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatNavigation") as? UINavigationController{
                                    popController.modalPresentationStyle = UIModalPresentationStyle.popover
                            // present the popover
                                self.present(popController, animated: true, completion: nil)
                        }
            }
        }
        }
        
        
        // sets the size of the cell based on the collectionView
        func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
            var size = CGSize()
            
             size = CGSize(width: screenWidth - 32, height: 85)
            
               return size
           }

        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
        

            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

    //    we set the minimum spacing to align with the spacing of the week days, spacing between items on the same row
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            var spacing = CGFloat()
            
                spacing = 0
                
            
            return spacing
        }

    //    spacing between rows
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            var spacing = CGFloat()
            
                spacing = 0

            return spacing
        }
        
    }




