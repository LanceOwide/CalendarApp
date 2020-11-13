//
//  PageViewController.swift
//  calendarApp
//
//  Created by Lance Owide on 22/01/2020.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    
    var pageControl = UIPageControl()
    
//    this list determins the view controller that gets called
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(color: "1"),
            self.newColoredViewController(color: "2"),self.newColoredViewController(color: "3"),self.newColoredViewController(color: "5"),self.newColoredViewController(color: "4"),self.newColoredViewController(color: "6"),self.newColoredViewController(color: "7")]
    }()
    
    private func newColoredViewController(color: String) -> UIViewController {
        return UIStoryboard(name: "TutorialStoryboard", bundle: nil) .
            instantiateViewController(withIdentifier: "tutorialPage\(color)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        exitButton()

        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
   
        }
        
//        set page controller delegate and colour
       self.delegate = self
       configurePageControl()
    
    }
    
    
    func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.alpha = 1.0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.backgroundColor = UIColor(red: 0, green: 176, blue: 156)
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    
//    create the exit button
    func exitButton(){
        
        let button = UIButton(frame: CGRect(x: screenWidth/2 - 40, y: screenHeight - 100, width: 80, height: 30))
        button.backgroundColor = UIColor.gray
        button.titleLabel?.textColor = UIColor.black
        button.setTitle("Close", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.view.addSubview(button)

        
    }
    

    @objc func buttonAction(sender: UIButton!) {
      print("close tutorial tapped")
        
        UserDefaults.standard.setValue("done", forKey: "firstTimeOpeningv2.0001.8")
        
        self.navigationController?.isNavigationBarHidden = false
        
//        remove the view from the viewController
       self.view.removeFromSuperview()
        
//        post a notification so the viewController knows to show the instructions now
NotificationCenter.default.post(name: .tutorialClosed, object: nil)
        
        
    }
    
}

// MARK: UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
         
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
             return nil
         }
         
         let previousIndex = viewControllerIndex - 1
         
         // User is on the first view controller and swiped left to loop to
         // the last view controller.
         guard previousIndex >= 0 else {
             return orderedViewControllers.last
         }
         
         guard orderedViewControllers.count > previousIndex else {
             return nil
         }
         
         return orderedViewControllers[previousIndex]
    }
    
    

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
         guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            print("didnt return viewcontroller index")
             return nil
         }
         
         let nextIndex = viewControllerIndex + 1
         let orderedViewControllersCount = orderedViewControllers.count
        
        print("nextIndex \(nextIndex)")
    
        
         guard orderedViewControllersCount != nextIndex else {
             return orderedViewControllers.first
         }
         
         guard orderedViewControllersCount > nextIndex else {
             return nil
         }
         
         return orderedViewControllers[nextIndex]
    }
    
 
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
                return 0
        }
        
        
        return firstViewControllerIndex
    }
    
    
    
    // MARK: Delegate functions
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
        
        let index = orderedViewControllers.index(of: pageContentViewController)!
        print("index \(index)")
        
        
        //        if the user has just gone through the notifications access show the request
                if index == 5{
                    //        one the user pushes close we register for push notifications
                    AutoRespondHelper.registerForPushNotificationsAuto()
                    
        //            we run the setup of the app, so that when we dismiss the tutorial the app is ready
                    NL_HomePage().openingSetup()
                }
                
        //        if the user has just gone through the calendar access we show the request for access
                if index == 4{
                     let calendarBool = UserDefaults.standard.bool(forKey: "calendarAccessSwitch")
                    
                    if calendarBool == true{
        //                this will ask the user for access, once granted it will also respond to each event they have been invited to
                    checkCalendarStatus2()
                    }
                    else{
                    }
                }
                 
                 // User is on the last view controller and swiped right to loop to
                 // the first view controller.
                if index == 6{
                 exitButton()
                }
    }  
}

