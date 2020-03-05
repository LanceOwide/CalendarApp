//
//  AppDelegate.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 15/11/2018.
//  Copyright © 2018 Lance Owide. All rights reserved.
//

import UIKit
import EventKitUI
import EventKit
import Firebase
import UserNotifications
import UserNotificationsUI
import IQKeyboardManagerSwift
import CoreData
import BackgroundTasks

//TESTING: e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"Lance-Owide.calndarAppPlayground.getEvents"]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.all
    var restrictRotation:UIInterfaceOrientationMask = .portrait
     
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        IQKeyboardManager.shared.enable = true
        
//        tell the app to refresh in the background as often as apple will allow - NOTE - this is only used for machines using iOS12 and below
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
//        MARK: the way to register to background tasks in iOS 13 and above
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier:
                "Lance-Owide.calndarAppPlayground.getEvents",
                                            using: nil){task in
                // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
                                                self.handleAppRefresh(task: task)
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
//        run code to allow push notifications
        registerForPushNotifications()
        
        
//        MARK: when the user opens the app and the app isnt running, this code below runs, instead of the usernotification center. In order to still run the requiured code, we set the property notificationSent3 to message or new event, then in the HomePage we check for this property having been set and run the required code to load up the data for desired screens
        if let option = launchOptions {
            let info = option[UIApplication.LaunchOptionsKey.remoteNotification]
            if (info != nil) {
                
                UserDefaults.standard.set("appWasNotRunning", forKey: "appRunning")
                
                let dic = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary
                let category = dic?.value(forKey: "gcm.notification.eventType") as? String ?? ""
                
                if category == "newMessage"{
                    
                    print("notification category = newMessage")
                    
                  UserDefaults.standard.set("newMessage", forKey: "notificationSent3")
                    print("newMessage")
                    
                    let newEventID = dic?.value(forKey: "gcm.notification.eventID") as! String
                    print("newEventID \(String(describing: newEventID))")
                    
                    eventIDChosen = newEventID
     
                }
                else if category == "newEvent"{
                    
                    UserDefaults.standard.set("newEvent", forKey: "notificationSent3")
                    
                    let newEventID = dic?.value(forKey: "gcm.notification.eventID") as! String
                    print("newEventID \(String(describing: newEventID))")
                    
                    eventIDChosen = newEventID
                    
                    print("newEvent")
                }}
            else{
        }
        
        }
        return true
        
    }
    
//    handled for the application refresh, this tells the app which function to run when it refreshes
    @available(iOS 13.0, *)
     func handleAppRefresh(task: BGTask) {
        print("background refresh triggered")
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        task.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }

//        add the operation to the queue
        queue.addOperation{
            print("operation in the queue")
            AutoRespondHelper.CDRetrieveUpdatedEventCheckAuto{(eventIDs) in
                print("handleAppRefresh - eventIDs \(eventIDs)")
                if eventIDs.count == 0 {
                    task.setTaskCompleted(success: true)
                    //this will schedule the background refresh to run again
                    self.scheduleAppRefresh()
                }
                else{

                    AutoRespondHelper.CDRetrieveUpdatedEventsAuto(eventIDs: eventIDs){
                    task.setTaskCompleted(success: true)
                    //this will schedule the background refresh to run again
                        self.scheduleAppRefresh()
                    }}}
        }
        

    }
    
//    function to schedule the app to refresh
    @available(iOS 13.0, *)
     func scheduleAppRefresh(){
        
//        how frequently do we want the background refresh to be called? this should be based on the cost
            let request = BGAppRefreshTaskRequest(identifier: "Lance-Owide.calndarAppPlayground.getEvents")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 3)
        do {
                try BGTaskScheduler.shared.submit(request)
            print("registered for background refresh")
        } catch {
            print("Couldn't schedule app refresh: \(error)")
        }
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disablef timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
//        we remove the listeners so they don't interfere with background work
        
        if availabilityListenerEngaged == true{availabilityListenerRegistration.remove()}
        
        if eventListenerEngaged == true{eventListenerRegistration.remove()}
        
        eventListenerEngaged = false
        availabilityListenerEngaged = false
        
        //        save down the coredata if the app is going to terminate
        self.saveContext()
        
//        need to schedule the app tp refresh when it is closed
        if #available(iOS 13.0, *) {
            scheduleAppRefresh()
        } else {
            // Fallback on earlier versions
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("running func applicationWillEnterForeground")
        
//            engage the listeners to detect event and availability notifications
        CoreDataCode().eventChangeListener()
        CoreDataCode().availabilityChangeListener()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        //        save down the coredata if the app is going to terminate
        self.saveContext()
        
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.restrictRotation
    }
    
    func registerForPushNotifications() {
      UNUserNotificationCenter.current() // 1
        .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
          granted, error in
          print("Permission granted: \(granted)") // 3
            guard granted else { return }
            
            // 1 set the action we would like to perform
            let respondAction = UNNotificationAction(
              identifier: "respondAction", title: "Auto Respond",
              options: [])
            
            let viewAction = UNNotificationAction(
            identifier: "viewAction", title: "View Event",
            options: [.foreground])

            // 2
            let newsCategory = UNNotificationCategory(
              identifier: "newEventCategory", actions: [respondAction, viewAction],
              intentIdentifiers: [], options: [])

            // 3
            UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
            self.getNotificationSettings()
            self.getUserPushToken()
      }
    }
    
    //    Returns the user notification settings the user gave us access to
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func getUserPushToken(){
    InstanceID.instanceID().instanceID { (result, error) in
    if let error = error {
    print("Error fetching remote instance ID: \(error)")
    } else if let result = result {
    print("Remote instance ID token: \(result.token)")
        
        if user == nil{
            
            print("user hasn't signed-in yet")
            
        }
        else{
    
        dbStore.collection("users").whereField("uid", isEqualTo: user!).getDocuments { (querySnapshot, error) in
            
            print("querySnapshot \(String(describing: querySnapshot))")
            
            if error != nil {
                print("there was an error")
            }
            else {
                for document in querySnapshot!.documents {
                 
                    let documentID = document.documentID
                    let name = document.get("name")
                    UserDefaults.standard.set(name, forKey: "name")
                    // Reference for the realtime database
                    let ref = Database.database().reference()
                    
                    dbStore.collection("users").document(documentID).setData(["tokenID" : result.token], merge: true)
                    
                    ref.child("users/\(user!)/\(result.token)").setValue(result.token)
                    ref.child("users/\(user!)/name").setValue(name)

                    
                }}}}}}}
    
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
    
    
//    function for running a background fetch, we will use this to retrieve and respond to events in the background NOTE - this is only used for machines running iOS 12 and below
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // fetch new events now
        
        
        print("running background update check")
        CoreDataCode().CDRetrieveUpdatedEventCheck{(eventIDs) in
            
            if eventIDs.count == 0 {
                completionHandler(.noData)
            }
            else{
        
        CoreDataCode().CDRetrieveUpdatedEvents(eventIDs: eventIDs)
            completionHandler(.newData)
            }}
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
  
//  MARK: This function will be called right after user tap on the notification when the app is running the the background, it is not called if the app ws not running
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
    let notificationContent = response.notification.request.content.userInfo
    let userInfo = response.notification.request.content.userInfo
    print("notificationContent \(notificationContent)")
    let eventType = userInfo["gcm.notification.eventType"] as! String
    let appOpening = UserDefaults.standard.string(forKey: "appRunning") ?? ""
    let aps = userInfo["aps"] as? [String: AnyObject]
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
    
//     instantiate the view controller from storyboard
        
        if response.actionIdentifier == "respondAction"{
            print("user selected auto respond")
            AutoRespondHelper.sendUserAvailabilityAuto(eventID: newEventID){
              completionHandler()
                }
        }
        else{
//            Need to be sure that the listeners are removed before we load the event
            if availabilityListenerEngaged == true{availabilityListenerRegistration.remove()}
            if eventListenerEngaged == true{eventListenerRegistration.remove()}
            
            print("user didnt select to auto respond")
            
//          set global variable to tell the homepage not to engage the event listeners
            eventNotificationAppBackground = true
            
        if  let eventDetails = storyboard.instantiateViewController(withIdentifier: "ResultsSplitViewViewController") as? ResultsSplitViewViewController, let navController = self.window?.rootViewController as? UINavigationController  {
            
//              retrieve the event data, eventSearch
            let predicate = NSPredicate(format: "eventID = %@", newEventID)
            let predicateReturned = CoreDataCode().serialiseEvents(predicate: predicate, usePredicate: true)
            if predicateReturned.count == 0{
                print("something went wrong - we need to retrieve the events")
                
//                retrieve the event updates and commit these to the DB
                CoreDataCode().CDRetrieveUpdatedEventCheck{(eventIDs) in
                
                    CoreDataCode().CDRetrieveUpdatedEventsCompletion(eventIDs: eventIDs){
                        
                        let predicate = NSPredicate(format: "eventID = %@", newEventID)
                        let predicateReturned = CoreDataCode().serialiseEvents(predicate: predicate, usePredicate: true)
                        
                        if predicateReturned.count == 0{print("we tried for a second time and couldnt find the event")
                            eventNotificationAppBackground = false
                            
                        }else{
                    
                            currentUserSelectedEvent = predicateReturned[0]
                            
//                        load the required availability
                        currentUserSelectedAvailability = CoreDataCode().serialiseAvailability(eventID: newEventID)
                        CoreDataCode().prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                            // set the view controller as root
                            navController.pushViewController(eventDetails, animated: true)
                            
//          set global variable to tell the homepage to engage the event listeners
                            eventNotificationAppBackground = false
                                                           
                                                            completionHandler()
                                                           
                            }}
                    }}
                
            }
            else{
                
                currentUserSelectedEvent = predicateReturned[0]
                
                //                load the required availability
                                currentUserSelectedAvailability = CoreDataCode().serialiseAvailability(eventID: newEventID)
                                CoreDataCode().prepareForEventDetailsPageCD(segueName: "", isSummaryView: false, performSegue: false, userAvailability: currentUserSelectedAvailability, triggerNotification: false){
                                    // set the view controller as root
                                    navController.pushViewController(eventDetails, animated: true)
//          set global variable to tell the homepage to engage the event listeners
                                    eventNotificationAppBackground = false
                                    
                                     completionHandler()
                                    
                }
                
            }}}}
    else if eventType == "newMessage"{
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newEventID = userInfo["gcm.notification.eventID"] as! String
        print("newEventID \(String(describing: newEventID))")
        
        eventIDChosen = newEventID
        
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
                }
                else{
                    currentUserSelectedEvent = filteredEvents[0]
                    // set the view controller as root
                        navController.pushViewController(messageController, animated: true)
                    
                     completionHandler()
        
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
    
    

    
    
}



