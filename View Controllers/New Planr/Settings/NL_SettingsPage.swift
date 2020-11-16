//
//  NL_SettingsPage.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 8/26/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit
import Firebase

class NL_SettingsPage: UIViewController {
    
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

    var settingsList = ["Account Settings","App Settings","Select Calendars","Select Save Calendar","About"]
    
    var settingsListImageNames = ["accountSettingsCode","settingsCogCodeLight","CalendarCode","saveCalendars","aboutCode"]
    
    var settingsDetailsList = ["Select the calendars Planr will use to determine your availability","Select the calendar Planr will use to save events you've been invited to", "Update your name, email address and phone number", "Define settings for certain app features","Company information and privacy policy"]
    
    var viewControllerName = ["NL_AccountSettings","NL_appSettings","NL_selectCalendars","NL_saveCalendars","NL_about"]
    
//    variables
    var tableViewSettings = UITableView()
    var nameLabel = UILabel()
    var personImageView = UIImageView()
    let cellId = "cellId"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(inputTopView)
        // Set its constraint to display it on screen
        inputTopView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputTopView.topAnchor.constraint(equalTo: view.topAnchor, constant: topDistance).isActive = true
        inputTopView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        inputTopView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPage), name: .userPhotoUploaded, object: nil)

        setupThePage()

    }
    
    @objc func reloadPage(){
        setupThePage()
    }
    
    func setupThePage(){
        
//        set the users name
        getUserName{(userName) in
            self.nameLabel.text = userName
        }
        self.title = "Settings"
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = MyVariables.colourPlanrGreen
        navigationItem.backBarButtonItem = backItem
        
        
        let userImage = fetchImage(uid: user!)
        if userImage.count != 0{
            let image = userImage[0]
            personImageView.image = UIImage(data: image.userImage!)
        }
        
    }
    
    
//    create the views for the page
           lazy var inputTopView: UIView = {
               print("setting up the inputTopView")
       //        set the variables for the setup
               let progressAmt = 0.75
               let sideInset = 16
            let imageBubbleSize = 75
            
               //   setup the view for holding the progress bar and title
               let containerView = UIView()
               containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight)
               containerView.backgroundColor = UIColor.white
               containerView.translatesAutoresizingMaskIntoConstraints = false
               
       //        trying to add a top view
               let topView = UIView()
               topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight)
               topView.backgroundColor = UIColor.white
               topView.translatesAutoresizingMaskIntoConstraints = false
               containerView.addSubview(topView)
               topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
               topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
               topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            topView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
               
//               lable to contain the users name
            nameLabel = UILabel()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            nameLabel.textAlignment = .center
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
            topView.addSubview(nameLabel)
            nameLabel.centerXAnchor.constraint(equalTo: topView.centerXAnchor, constant: 37.5).isActive = true
            nameLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 27).isActive = true
            nameLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
            nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            //        center the image
            topView.addSubview(personImageView)
            personImageView.centerXAnchor.constraint(equalTo: topView.centerXAnchor, constant: -100).isActive = true
            personImageView.backgroundColor = MyVariables.colourBackground
            //        make the imageView round
            personImageView.layer.borderWidth = 1.0
            personImageView.layer.masksToBounds = true
            
            //        create the circle
            personImageView.layer.cornerRadius = CGFloat(imageBubbleSize) / 2
            personImageView.layer.borderColor = UIColor.white.cgColor
            personImageView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20).isActive = true
            personImageView.widthAnchor.constraint(equalToConstant: CGFloat(imageBubbleSize)).isActive = true
            personImageView.heightAnchor.constraint(equalToConstant: CGFloat(imageBubbleSize)).isActive = true
            personImageView.translatesAutoresizingMaskIntoConstraints = false
            
            
//            insert the tableView
             tableViewSettings = UITableView(frame: .zero)
             tableViewSettings.translatesAutoresizingMaskIntoConstraints = false
             tableViewSettings.delegate = self
             tableViewSettings.dataSource = self
             tableViewSettings.register(NL_settingTableViewCell.self, forCellReuseIdentifier: cellId)
             tableViewSettings.backgroundColor = .white
             tableViewSettings.isScrollEnabled = true
//            removes the separator lines for rows without data
            tableViewSettings.tableFooterView = UIView()
             tableViewSettings.rowHeight = 70
            tableViewSettings.separatorStyle = .singleLine
             tableViewSettings.separatorColor = MyVariables.colourPlanrGreen
             tableViewSettings.isUserInteractionEnabled = true
             tableViewSettings.allowsSelection = true
             tableViewSettings.allowsMultipleSelection = false
             topView.addSubview(tableViewSettings)
             tableViewSettings.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
             tableViewSettings.widthAnchor.constraint(equalToConstant: CGFloat(Int(screenWidth) - sideInset - sideInset)).isActive = true
             tableViewSettings.topAnchor.constraint(equalTo: topView.topAnchor, constant: 100).isActive = true
             tableViewSettings.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -100).isActive = true
            
//            add button to log out with
            
            let logOutButton = UIButton()
            topView.addSubview(logOutButton)
            logOutButton.setTitle("Log Out", for: .normal)
            logOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            logOutButton.setTitleColor(UIColor.red, for: .normal)
            logOutButton.titleLabel?.textAlignment = .center
            logOutButton.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
            logOutButton.layer.cornerRadius = 3
            logOutButton.layer.masksToBounds = true
            logOutButton.contentMode = .scaleAspectFill
            logOutButton.translatesAutoresizingMaskIntoConstraints = false
            logOutButton.bottomAnchor.constraint(equalTo: topView.bottomAnchor,constant: -50).isActive = true
            logOutButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
            logOutButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            logOutButton.addTarget(self, action: #selector(logOutTheUser), for: .touchUpInside)
            
            
               return containerView
           }()
    
    
//    function to logout the user and send them back to the homepage
    @objc func logOutTheUser(){
        print("the user has selected to logout")
        
        
//        ask the user if they want to log out
//            utils for calling the alert
        let utils = Utils();
        
        let button = AlertButton(title: "Yes", action: {
                print("OK clicked")
            
            Analytics.logEvent(firebaseEvents.settingsLogOff, parameters: ["user": user])
            
            Auth.auth().removeStateDidChangeListener(authListener!)
            UserDefaults.standard.set("", forKey: "authVerificationID")
            
            authStatusListener = false
            
//            remove the notification listener
            notificationListenerRegistration.remove()

    //        when the user logs out we want to delete all their app data, otherwise logging in with another users credentials will not work
            self.deleteAllRecords(entityName:"CoreDataAvailability")
            self.deleteAllRecords(entityName:"CoreDataEvent")
            self.deleteAllRecords(entityName:"CoreDataChatMessages")
            
                let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
                
                if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomePageViewController") as? HomePageViewController {
                   self.navigationController?.pushViewController(viewController, animated: false)
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    self.navigationController?.navigationItem.setHidesBackButton(true, animated: false)
                }
                
                justSignedOutBool = true
                
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
            
            
            }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
        
        let button2 = AlertButton(title: "No", action: {
                print("OK clicked");
            }, titleColor: MyVariables.colourPlanrGreen, backgroundColor: MyVariables.colourSelected);
        
        let alertPayload = AlertPayload(title: "Log Out?", titleColor: UIColor.red, message: "Are you sure you want to log out?", messageColor: MyVariables.colourPlanrGreen, buttons: [button, button2], backgroundColor: UIColor.clear, inputTextHidden: true)
        
        utils.showAlert(payload: alertPayload, parentViewController: self, autoDismiss: false, timeLag: 0.0, hideInput: true)
        
    }


}

//extension for the collectionview containing the event choices
extension NL_SettingsPage: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! NL_settingTableViewCell
        
    
        cell.cellText.text = settingsList[indexPath.row]
        cell.addImageView.isHidden = false
        cell.addImageView.image = UIImage(named: settingsListImageNames[indexPath.row])
//        we dont want to highlight the cell
        cell.selectionStyle = .none
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       
        let vc = viewControllerName[indexPath.row]
        
        if let viewController = UIStoryboard(name: "NL_Settings", bundle: nil).instantiateViewController(withIdentifier: vc) as? UIViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    

}
