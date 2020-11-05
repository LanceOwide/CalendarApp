//
//  AppDelegate.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

//to upload to the DYSyms

///Users/lanceowide/Dropbox/CalendarApp/Calendar\ App/Calendar\ App\ -\ Code/App1/calndarAppPlayground/Pods/FirebaseCrashlytics/upload-symbols -gsp /Users/lanceowide/Dropbox/CalendarApp/Calendar\ App/Calendar\ App\ -\ Code/App1/calndarAppPlayground/calndarAppPlayground/GoogleService-Info.plist -p ios /Users/lanceowide/Downloads/appDsyms

import UIKit
import EventKitUI
import EventKit
import Firebase
import UserNotifications
import UserNotificationsUI
import CoreData
import BackgroundTasks
import MBProgressHUD
import IQKeyboardManagerSwift
import FirebaseStorage

//TESTING: e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"Lance-Owide.calndarAppPlayground.getEvents"]
//TESTING: e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"Lance-Owide.calndarAppPlayground.getEventsBackground"]


@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.all
    var restrictRotation:UIInterfaceOrientationMask = .portrait
     
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        IQKeyboardManager.shared.enable = true
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ChatLogController.self)

        
        resetNotificationCount()
        
//        a reference to the storage location
        let storage = Storage.storage()
        
//        since the app was opened set the bagecount to zero
        application.applicationIconBadgeNumber = 0
        UserDefaults.standard.set(0, forKey: "notificationINT")

        UNUserNotificationCenter.current().delegate = self
        
//        if this is a new user we dont want to show them the notification request until later
        if UserDefaults.standard.bool(forKey: "oldUser") == true{
//        run code to allow push notifications
            AutoRespondHelper.registerForPushNotificationsAuto()
        }
        
        
//        MARK: when the user opens the app and the app isnt running, this code below runs, instead of the usernotification center. In order to still run the requiured code, we set the property notificationSent3 to message or new event, then in the HomePage we check for this property having been set and run the required code to load up the data for desired screens
        if let option = launchOptions {
            let info = option[UIApplication.LaunchOptionsKey.remoteNotification]
            if (info != nil) {
                print("didFinishLaunchingWithOptions - info \(info)")
                
                UserDefaults.standard.set("appWasNotRunning", forKey: "appRunning")
                
                let dic = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary
                let category = dic?.value(forKey: "gcm.notification.eventType") as? String ?? ""
                
                if category == "newMessage"{
                    print("didFinishLaunchingWithOptions - notification category = newMessage")
                    
                  UserDefaults.standard.set("newMessage", forKey: "notificationSent3")
                    
                    let newEventID = dic?.value(forKey: "gcm.notification.eventID") as! String
                    print("newEventID \(String(describing: newEventID))")
                    
                    eventIDChosen = newEventID
                }
                else if category == "newEvent"{
                    noListeners = true
                    print("didFinishLaunchingWithOptions - new event")
                    
                    UserDefaults.standard.set("newEvent", forKey: "notificationSent3")
                    
                    let newEventID = dic?.value(forKey: "gcm.notification.eventID") as! String
                    print("newEventID \(String(describing: newEventID))")
                    
                    eventIDChosen = newEventID

                }}
            else{
                print("didFinishLaunchingWithOptions - info was empty, we have an issue")
        }
        
        }
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disablef timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        

    }
    
    

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        before going to background set the badge to 0, this ensures any notifications recieved during the time the app was open are ignored
//        application.applicationIconBadgeNumber = 0
        
        print("running func - applicationDidEnterBackground")
//        we remove the listeners so they don't interfere with background work
        if availabilityListenerEngaged == true{availabilityListenerRegistration.remove()
            print("applicationDidEnterBackground - disabling availabilityListener")
            availabilityListenerEngaged = false
        }
        if eventListenerEngaged == true{eventListenerRegistration.remove()
            print("applicationDidEnterBackground - disabling eventListenerRegistration")
            eventListenerEngaged = false
        }
        
        eventListenerEngaged = false
        availabilityListenerEngaged = false
        
        //        save down the coredata if the app is going to terminate
        self.saveContext()
        
//        we remove the listeners so they don't interfere when the app comes back  to the foreground
        if availabilityListenerEngaged == true{availabilityListenerRegistration.remove()
            print("applicationDidEnterBackground - disabling availabilityListener")
            availabilityListenerEngaged = false
        }
        if eventListenerEngaged == true{eventListenerRegistration.remove()
            print("applicationDidEnterBackground - disabling eventListenerRegistration")
            eventListenerEngaged = false
        }
        
        if notificationListenerEnagaged == true{notificationListenerRegistration.remove()
            print("applicationDidEnterBackground - disabling notificationListenerRegistration")
            notificationListenerEnagaged = false
        }
        
//        save the chat notifications into the user defaults
        UserDefaults.standard.setValue(chatNotificationiDs, forKey: "chatNotificationEventIDs")
  
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("running func applicationWillEnterForeground")

        
//        since the app was opened set the bagecount to zero
        application.applicationIconBadgeNumber = 0
        UserDefaults.standard.set(0, forKey: "notificationINT")
        
        resetNotificationCount()
        
//            engage the listeners to detect event and availability notifications, but check that they are not already engaged
        if availabilityListenerEngaged == false{CoreDataCode().availabilityChangeListener()}
        if eventListenerEngaged == false{CoreDataCode().eventChangeListener()}
        if notificationListenerEnagaged == false{FirebaseCode().checkNotificationStatusListener()}
        
////        we also need to remove any observers on the message nodes, we check if the listners were enagged to begin with befor removing it
//        if chatListenerInt == true{userMessagesRef.removeAllObservers()
//            chatListenerInt = false
//        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        //        save down the coredata if the app is going to terminate
        self.saveContext()
        
        //        save the chat notifications into the user defaults
                UserDefaults.standard.setValue(chatNotificationiDs, forKey: "chatNotificationEventIDs")
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.restrictRotation
    }

    
    
    //    resets the users notification count in the realtime DB  - FOR BADGE COUNT
    func resetNotificationCount(){
        
        if user == nil{
        //            delay for 15 seconds if the user isnt yet logged in
                    let seconds15 = 15.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds15){
                
                if user == nil{
                }
                else{
                    let ref = Database.database().reference().child("userNotificationCount").child(user!)
                
       ref.child("userNotificationCount").setValue(0)
            }
            }
        }
        else{
            let ref = Database.database().reference().child("userNotificationCount").child(user!)
          
            ref.child("userNotificationCount").setValue(0)
            
        }
        
    }
    
    //    called when the registration for push notifications succeeds
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    //    called when the registration for push notifications fails
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    
    // MARK: - Core Data stack

       lazy var persistentContainer: NSPersistentContainer = {
           /*
            The persistent container for the application. This implementation
            creates and returns a container, having loaded the store for the
            application to it. This property is optional since there are legitimate
            error conditions that could cause the creation of the store to fail.
           */
           let container = NSPersistentContainer(name: "Model")
           container.loadPersistentStores(completionHandler: { (storeDescription, error) in
               if let error = error as NSError? {
                   // Replace this implementation with code to handle the error appropriately.
                   // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                   /*
                    Typical reasons for an error here include:
                    * The parent directory does not exist, cannot be created, or disallows writing.
                    * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                    * The device is out of space.
                    * The store could not be migrated to the current model version.
                    Check the error message to determine what the actual problem was.
                    */
                   fatalError("Unresolved error \(error), \(error.userInfo)")
               }
           })
           return container
       }()

       // MARK: - Core Data Saving support

       func saveContext () {
           let context = persistentContainer.viewContext
           if context.hasChanges {
               do {
                   try context.save()
               } catch {
                   // Replace this implementation with code to handle the error appropriately.
                   // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                   let nserror = error as NSError
                   fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
               }
           }
       }
    
    
//    This code will run whenever the user receives a remote notification and the app is running in th background, we determine which notification they receieved and handle it
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Analytics.logEvent(firebaseEvents.remoteNotificationRecieved, parameters: ["user": user])
        
        print("did receive a notification running - didReceiveRemoteNotification userInfo: \(userInfo)")
        
        // Access Shared Defaults Object
        let userDefaults = UserDefaults.standard
        
//        get anything currently stored in user defaults
        let currentAPNUI = userDefaults.object(forKey: "apnNotificationUserInfo") as? [[AnyHashable : Any]]
        var newAPNArray = [[AnyHashable : Any]]()
//check to see if there was any data int he user defaults if not, we need to make the
        if currentAPNUI == nil{
            newAPNArray = [userInfo]
        }
        else{
//        append the new userInfo
            newAPNArray = currentAPNUI!
            newAPNArray.append(userInfo)
        }
//        save into the user defults
        userDefaults.set(newAPNArray, forKey: "apnNotificationUserInfo")
        print("newAPNArray \(newAPNArray)")
        
//        this will run even if the app wasn't running in the background, we need to create stop it using the did finish launching with options setting
       let category = UserDefaults.standard.string(forKey: "notificationSent3")
        if category != "newEvent"{
        
//        we have to add this check as the login process uses a silent push notification
        if let val = userInfo["gcm.notification.eventType"]{
        
// get the specific data sent wiht the notification
        let eventType = userInfo["gcm.notification.eventType"] as! String
//        get the eventID for the new event adn check it is in the notification set
        let newEventID = userInfo["gcm.notification.eventID"] as! String
        let documentData: [String: Any] = [newEventID: "New"]

//        we only want to pull down data for new events or updated events, not chat notifications
        if eventType == "newEvent"{
//                we add a seconds delay here, this is because of delays between the notification and data being written to to firestore - BAD CODE
            let seconds1 = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds1) {
        print("didReceiveRemoteNotification - notification was an event notification, we are continuing")
        AutoRespondHelper.CDRetrieveUpdatedEventCheckAuto{(eventIDs) in
            print("didReceiveRemoteNotification - eventIDs \(eventIDs)")
            
//            if there were no events to retrieve we end the process and return no data
            if eventIDs.count == 0 {
                print("didReceiveRemoteNotification - completion with no data")
                completionHandler(.noData)
            }
        else{
//                we add a seconds delay here, this is because of delays between the notification and data being written to to firestore - BAD CODE
                let seconds1 = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds1) {
                
                AutoRespondHelper.CDRetrieveUpdatedEventsAuto(eventIDs: eventIDs){
//                    we perform the process twice to ensure we have all the data needed
                    AutoRespondHelper.CDRetrieveUpdatedEventCheckAuto{(eventIDs) in
                        print("didReceiveRemoteNotification - eventIDs \(eventIDs)")
                        if eventIDs.count == 0 {
                            print("didReceiveRemoteNotification - completion with new data")
                            completionHandler(.newData)
                        }
                    else{
                            AutoRespondHelper.CDRetrieveUpdatedEventsAuto(eventIDs: eventIDs){
                                Analytics.logEvent(firebaseEvents.autoRespondwNotification, parameters: ["user": user])
                                print("didReceiveRemoteNotification - completion with new data")
                                completionHandler(.newData)

                            }}}}}}}
            }}
        else{
        }
            }
        else{
//            this wasnt a gcm.notification notification and we should ignore it
            }}
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        
        completionHandler([.alert, .badge, .sound])
    }
    
  
//  MARK: This function will be called right after user tap on the notification when the app is running the the background, it is not called if the app was not running
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
    print("userNotificationCenter - didReceive was triggered in appDelegate")
    
    let notificationContent = response.notification.request.content.userInfo
    let userInfo = response.notification.request.content.userInfo
    print("notificationContent \(notificationContent)")
    let eventType = userInfo["gcm.notification.eventType"] as! String
    let appOpening = UserDefaults.standard.string(forKey: "appRunning") ?? ""

//    we store the full in userDefaults APS to use in the notifications page
// Access Shared Defaults Object
    let userDefaults = UserDefaults.standard

    // Create and Write Array of Strings
    let array = ["One", "Two", "Three"]
    userDefaults.set(array, forKey: "myKey")
    
    var newEventID = String()
    
    if appOpening == "appWasNotRunning"{
        print("the app was not running")
        UserDefaults.standard.set("", forKey: "appRunning")
    }
    else{
        print("the app was running")
        UserDefaults.standard.set("", forKey: "appRunning")

    if eventType == "newEvent"{
        print("notification category = newEvent")
    
        newEventID = userInfo["gcm.notification.eventID"] as! String
        print("newEventID \(String(describing: newEventID))")
        
        UserDefaults.standard.set("", forKey: "notificationSent3")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
//     if the user selected to AutoRespond, then Auto respond
        if response.actionIdentifier == "respondAction"{
            print("user selected auto respond")
            AutoRespondHelper.sendUserAvailabilityAuto(eventID: newEventID){
//                 reset the items we created
                
              completionHandler()
                }
        }
        else{
//            Need to be sure that the listeners are removed before we load the event to ensure no issues with the calls overlapping, but once the event has been loaded we should re-engage the listeners to ensure we pull down the latest information
            if availabilityListenerEngaged == true{availabilityListenerRegistration.remove()
             print("userNotificationCenter - disabling availabilityListenerRegistration")
                availabilityListenerEngaged = false
            }
            if eventListenerEngaged == true{eventListenerRegistration.remove()
                print("userNotificationCenter - disabling eventListenerRegistration")
                eventListenerEngaged = false
            }
            //          set global variable to tell the homepage not to engage the event listeners
            eventNotificationAppBackground = true
            print("user didnt select to auto respond")
            

            let loadingNotification = MBProgressHUD.showAdded(to: (UIApplication.topViewController()?.view)!, animated: false)
            loadingNotification.label.text = "Loading event"
            loadingNotification.customView = UIImageView(image: UIImage(named: "Loading-100.png"))
            loadingNotification.mode = MBProgressHUDMode.customView
            
            
            
        if  let eventDetails = UIStoryboard(name: "NL_Events", bundle: nil).instantiateViewController(withIdentifier: "NL_eventController") as? NL_eventController, let navController = self.window?.rootViewController as? UINavigationController  {
            
            print("userNotificationCenter - new event if let #1 successful")
//              retrieve the event data, eventSearch
            let predicate = NSPredicate(format: "eventID = %@", newEventID)
            let predicateReturned = CoreDataCode().serialiseEvents(predicate: predicate, usePredicate: true)
            if predicateReturned.count == 0{
                print("something went wrong - we need to retrieve the event")
//                retrieve the event updates and commit these to the DB
                CoreDataCode().CDRetrieveUpdatedEventCheck{(eventIDs) in
                    CoreDataCode().CDRetrieveUpdatedEventsCompletion(eventIDs: eventIDs){
                        
                        let predicate = NSPredicate(format: "eventID = %@", newEventID)
                        let predicateReturned = CoreDataCode().serialiseEvents(predicate: predicate, usePredicate: true)
                        
//                        if the predicate still doesnt return anything we let the app updated for 2 seconds and continue - THIS IS BAD CODE - NEEDS REPLACING!!!
                        if predicateReturned.count == 0{
                            print("userNotificationCenter predicateReturned 0, we wait 2 seconds")
                            let seconds2 = 2.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds2) {
                                let predicate = NSPredicate(format: "eventID = %@", newEventID)
                                let predicateReturned = CoreDataCode().serialiseEvents(predicate: predicate, usePredicate: true)
                                 if predicateReturned.count == 0{
                                    print("we tried for a second time and couldnt find the event")
                                                                eventNotificationAppBackground = false
                                    eventNotificationPending = false
                                    loadingNotification.hide(animated: true)
                                                                
//                            the event was probably deleted by the user, we show a notification to let the user know
                                                                let alertEventDeleted = UIAlertController(title: "Event Deleted", message: "The event has been deleted by the organiser", preferredStyle: UIAlertController.Style.alert)
                                                                alertEventDeleted.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                                                    print("user pressed ok")
//          re-engage the listeners
            if availabilityListenerEngaged == false{CoreDataCode().availabilityChangeListener()
             print("userNotificationCenter - enabling availabilityListenerRegistration")
            }
                                                                    if eventListenerEngaged == false{CoreDataCode().eventChangeListener()
                print("userNotificationCenter - enabling eventListenerRegistration")
            }
                                                                    completionHandler()
                                                                    }))
                                    
                                    //                            present the alert
            UIApplication.topViewController()?.present(alertEventDeleted, animated: true, completion: nil)
                                }
                               else{
                                                                loadingNotification.hide(animated: true)
                        currentUserSelectedEvent = predicateReturned[0]
                                                                
                                    //                        load the required availability
                        currentUserSelectedAvailability = CoreDataCode().serialiseAvailability(eventID: newEventID)
                        CoreDataCode().prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                                // set the view controller as root
                                navController.present(eventDetails, animated: true)
                                                                
                                    //          set global variable to tell the homepage to engage the event listeners
                                                                eventNotificationAppBackground = false
                                //          re-engage the listeners
                                if availabilityListenerEngaged == false{CoreDataCode().availabilityChangeListener()
                                                                 print("userNotificationCenter - enabling availabilityListenerRegistration")
                                                                }
                                if eventListenerEngaged == false{CoreDataCode().eventChangeListener()
                                                                    print("userNotificationCenter - enabling eventListenerRegistration")
                                                                }
                                                                                               
                                completionHandler()
                                    }}

                            }

                        }
                        else{
                            loadingNotification.hide(animated: true)
                            currentUserSelectedEvent = predicateReturned[0]
                            
//                        load the required availability
                        currentUserSelectedAvailability = CoreDataCode().serialiseAvailability(eventID: newEventID)
                        CoreDataCode().prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                            // set the view controller as root
                            navController.present(eventDetails, animated: true)
                            
//          set global variable to tell the homepage to engage the event listeners
                            eventNotificationAppBackground = false
//          re-engage the listeners
                if availabilityListenerEngaged == false{CoreDataCode().availabilityChangeListener()
                print("userNotificationCenter - enabling availabilityListenerRegistration")
                                                                                           }
                if eventListenerEngaged == false{CoreDataCode().eventChangeListener()
                print("userNotificationCenter - enabling eventListenerRegistration")
                                                                                           }
               completionHandler()
                            }}
                    }}
                
            }
            else{
                loadingNotification.hide(animated: true)
                
                currentUserSelectedEvent = predicateReturned[0]
                
                //                load the required availability
                                currentUserSelectedAvailability = CoreDataCode().serialiseAvailability(eventID: newEventID)
                                CoreDataCode().prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
// set the view controller as root
                                    navController.present(eventDetails, animated: true)
//          set global variable to tell the homepage to engage the event listeners
                                    eventNotificationAppBackground = false
//          re-engage the listeners
                                    if availabilityListenerEngaged == false{CoreDataCode().availabilityChangeListener()
                                                                     print("userNotificationCenter - enabling availabilityListenerRegistration")
                                                                    }
                                    if eventListenerEngaged == false{CoreDataCode().eventChangeListener()
                                                                        print("userNotificationCenter - enabling eventListenerRegistration")
                                                                    }
                                     completionHandler()
                }
            }}}}
    else if eventType == "newMessage"{
//        send the user back to the home and then send them to the page they want to see
//        UIApplication.shared.keyWindow?.rootViewController?.navigationController?.popToRootViewController(animated: false)
//        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true){
//            print("The user has been sent back to the homepage, closing all other windows")
//        }
        
        
//        self.window?.rootViewController?.navigationController?.viewControllers.removeAll()

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newEventID = userInfo["gcm.notification.eventID"] as! String
        print("newEventID \(String(describing: newEventID))")
        
        eventIDChosen = newEventID
        
//        check if the user is already viewing the chat log controller, if they are not we do not want to reinstantiate it
        let currentViewController = topMostController()
        var chatAlreadyOpen = false
        if currentViewController?.isKind(of: ChatLogController.self) == true{
            chatAlreadyOpen = true
        }
        
//        set the new notification count for the event, pulling from the userdefaults and saving back to user defaults
        if let data = UserDefaults.standard.value(forKey:"notifications") as? Data {
        let notification = try? PropertyListDecoder().decode(Array<notificationModel>.self, from: data)
            
            var currentEventArray = notification?.filter{$0.eventID == newEventID}
            
            for index in 0..<currentEventArray!.count{
              
                currentEventArray![index].messageCount = currentEventArray![index].messageCount + 1
            }
        }
        
        UserDefaults.standard.set("", forKey: "notificationSent3")
        // instantiate the view controller from storyboard
            if  let messageController = storyboard.instantiateViewController(withIdentifier: "chatLogController") as? ChatLogController, let navController = self.window?.rootViewController as? UINavigationController  {
//                we need to retrieve the event the user has just received a message for
                let predicate = NSPredicate(format: "eventID == %@", argumentArray: [eventIDChosen])
                let filteredEvents = CoreDataCode().serialiseEvents(predicate: predicate, usePredicate: true)
                
                if filteredEvents.count == 0{
                    print("something went wrong")
                    completionHandler()
                }
                else{
                    currentUserSelectedEvent = filteredEvents[0]
//      set the chatlogcontroller as root, only if it isnt already the root
                    if chatAlreadyOpen == false{
                        if let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatNavigation") as? UINavigationController{
                                popController.modalPresentationStyle = UIModalPresentationStyle.popover
                        // present the popover
                            navController.present(popController, animated: true, completion: nil)
                            completionHandler()
                    }
                    }
                    else{
                        print("chat was already open")
//       when the viewcontroller was already being shown the observe message doesnt get called, we do it here
//                       messageController.observeMessages()
                        
                        NotificationCenter.default.post(name: .chatNotificationTapped, object: nil)
                        
                        completionHandler()

                    }
                     
                }
        }
        
        }}
}
    
//    function used for checking for new events, when the users is on iOS 13 or higher
    func checkForNewEvents(){
        print("running checkForNewEvents()")
        CoreDataCode().CDRetrieveUpdatedEventCheck{(eventIDs) in
            
            if eventIDs.count == 0 {

            }
            else{
        
        CoreDataCode().CDRetrieveUpdatedEvents(eventIDs: eventIDs)
            }}
    }
    
//    function to return the current top most view controller
    func topMostController() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            return nil
        }

        var topController = rootViewController

        while true {
            if let presented = topController.presentedViewController {
                topController = presented
            } else if let nav = topController as? UINavigationController {
                topController = nav.visibleViewController!
            } else if let tab = topController as? UITabBarController {
                topController = tab.selectedViewController!
            } else {
                break
            }
        }

        return topController
    }
}

//Extenstion to allow us to show alerts from the AppDelegate
extension UIApplication {
class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
        return topViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
    }
    if let presented = controller?.presentedViewController {
        return topViewController(controller: presented)
    }
    return controller
} }





//OLD CODE

////        MARK: the way to register to background tasks in iOS 13 and above
//        if #available(iOS 13.0, *) {
//            print("registering tasks Lance-Owide.calndarAppPlayground.getEvents")
//            BGTaskScheduler.shared.register(forTaskWithIdentifier:
//                "Lance-Owide.calndarAppPlayground.getEvents",
//                                            using: DispatchQueue.global()){task in
//                // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
//                print("did run task Lance-Owide.calndarAppPlayground.getEvents")
//                self.handleAppRefresh(task: task  as! BGAppRefreshTask)
//            }
//
//            BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.calendarApp.getEventBackground", using: DispatchQueue.global()) { task in
//                // Downcast the parameter to a processing task as this identifier is used for a processing request.
//                print("did run com.calendarApp.getEventBackground")
//                self.handleBackgroundAppRefresh(task: task as! BGProcessingTask)
//            }
//        }
//        else{
//
//            //        tell the app to refresh in the background as often as apple will allow - NOTE - this is only used for machines using iOS12 and below
//            application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
//        }
////    handled for the application refresh, this tells the app which function to run when it refreshes
//    @available(iOS 13.0, *)
//     func handleAppRefresh(task: BGTask) {
//        print("background refresh triggered")
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//
////        add the operation to the queue
//        queue.addOperation{
//            print("operation in the queue")
//            AutoRespondHelper.CDRetrieveUpdatedEventCheckAuto{(eventIDs) in
//                print("handleAppRefresh - eventIDs \(eventIDs)")
//                if eventIDs.count == 0 {
//                    task.setTaskCompleted(success: true)
//                    //this will schedule the background refresh to run again
//                    self.scheduleAppRefresh()
//                }
//                else{
//
//                    AutoRespondHelper.CDRetrieveUpdatedEventsAuto(eventIDs: eventIDs){
//                    task.setTaskCompleted(success: true)
//                    //this will schedule the background refresh to run again
//                        self.scheduleAppRefresh()
//                    }}}
//        }
//        task.expirationHandler = {
//            // After all operations are cancelled, the completion block below is called to set the task to complete.
//            queue.cancelAllOperations()
//        }
//        let lastOperation = queue.operations.last
//        lastOperation?.completionBlock = {
//            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
//        }
//    }
//
////    handler for the background tasks being run
//    @available(iOS 13.0, *)
//    func handleBackgroundAppRefresh(task: BGProcessingTask) {
//
//                print("handleBackgroundAppRefresh refresh triggered")
//                let queue = OperationQueue()
//                queue.maxConcurrentOperationCount = 1
//
//                task.expirationHandler = {
//                    // After all operations are cancelled, the completion block below is called to set the task to complete.
//                    queue.cancelAllOperations()
//                }
//
//        //        add the operation to the queue
//                queue.addOperation{
//                    print("operation in the queue")
//                    AutoRespondHelper.CDRetrieveUpdatedEventCheckAuto{(eventIDs) in
//                        print("handleAppRefresh - eventIDs \(eventIDs)")
//                        if eventIDs.count == 0 {
//                            task.setTaskCompleted(success: true)
//                            //this will schedule the background refresh to run again
//                            self.scheduleBackgroundRefresh()
//                        }
//                    else{
//
//                            AutoRespondHelper.CDRetrieveUpdatedEventsAuto(eventIDs: eventIDs){
//                            task.setTaskCompleted(success: true)
//                            //this will schedule the background refresh to run again
//                                self.scheduleBackgroundRefresh()
//                            }}}
//                }
//    }
    
    
////    function to schedule the app to refresh
//    @available(iOS 13.0, *)
//     func scheduleAppRefresh(){
//        print("running func scheduleAppRefresh")
//
////        how frequently do we want the background refresh to be called? this should be based on the cost
//            let request = BGAppRefreshTaskRequest(identifier: "Lance-Owide.calndarAppPlayground.getEvents")
//            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 5)
//        do {
//                try BGTaskScheduler.shared.submit(request)
//            print("registered for scheduleAppRefresh")
//        } catch {
//            print("Couldn't schedule app refresh: \(error)")
//        }
//    }
//
////    schedule to run background processing as well as refresh, hoping this gets us more time on the processor
//    @available(iOS 13.0, *)
//    func scheduleBackgroundRefresh() {
//        print("running func scheduleBackgroundRefresh")
//
//        let request = BGProcessingTaskRequest(identifier: "com.calendarApp.getEventBackground")
////        must be connected to the network
//        request.requiresNetworkConnectivity = true
////        we dont need power, this isnt power sensitive
//        request.requiresExternalPower = false
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 1)
//        do {
//            try BGTaskScheduler.shared.submit(request)
//            print("registered for scheduleBackgroundRefresh")
//        } catch {
//            print("Could not register for scheduleBackgroundRefresh: \(error)")
//        }
//    }
//
//    function for running a background fetch, we will use this to retrieve and respond to events in the background NOTE - this is only used for machines running iOS 12 hence we add the check.
//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//        if #available(iOS 13.0, *){
////            ignore the code
//            print("running performFetchWithCompletionHandler on ios 13 - ignoring the code")
//        }
//        else{
//        // fetch new events now
//        print("running background update check")
//        CoreDataCode().CDRetrieveUpdatedEventCheck{(eventIDs) in
//
//            if eventIDs.count == 0 {
//                completionHandler(.noData)
//            }
//            else{
//
//        CoreDataCode().CDRetrieveUpdatedEvents(eventIDs: eventIDs)
//            completionHandler(.newData)
//            }}
//    }
//    }
