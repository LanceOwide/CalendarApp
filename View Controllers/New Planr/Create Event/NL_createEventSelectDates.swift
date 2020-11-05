//
//  NL_createEventSelectDates.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 9/21/20.
//  Copyright © 2020 Lance Owide. All rights reserved.
//

import UIKit

//the selected date array is global such that the list stays constant even if the user goes back and forth from the select date pages


var calendarArray2 = [[String]]()
var calendarTitleArray = [Int]()
var searchPeriodChoicesSelected = [Int]()
var daysOfTheWeekSelected = [Int]()

class NL_createEventSelectDates: UIViewController {
    
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
    
    
    //    variables for the views of calendar and filters
        var viewCalendar = UIView()
        var viewFilter = UIView()
        var btnCalendar = UIButton()
        var btnFilter = UIButton()
        var viewSeparatorCalendar = UIView()
        var viewSeparatorFilter = UIView()
    
    
    var collectionviewSearch: UICollectionView!
    var collectionviewDaysOfTheWeek: UICollectionView!
    var collectionViewDates: UICollectionView!
    var collectionViewCalendar: UICollectionView!
    let cellId3 = "cellId3"
    let cellId2 = "cellId2"
    let cellId = "cellId"
    let cellId4 = "cellId4"
    
    
    let searchPeriodChoices = ["1 Week","2 Weeks","1 Month","2 Months","3 Months"]
    let daysOfTheWeek = ["Mon","Tues","Wed","Thu","Fri","Sat","Sun"]
    
//    variables to manage the calendar view
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31,31,28,31,30,31,30,31,31,30,31,30,31,31,28,31,30,31,30,31,31,30,31,30,31]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    let numberOfMonths = 24
    
    
//    date fromatter used for the end time > start time checks
    var dateFormatterTZ = DateFormatter()
    
    
//   variables used to calculate the dates selected by the user
        var timePeriodsAdditionType = [Calendar.Component.day,Calendar.Component.day,Calendar.Component.month,Calendar.Component.month,Calendar.Component.month,Calendar.Component.day]
        var timePeriodsAddition = [7,14,1,2,3,7]
        var monthsArr = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        the first time we load the page we set the array to store the selected filter elements
        if searchPeriodChoicesSelected.count < 4{
            searchPeriodChoicesSelected = [0,0,0,0,0]}
        if daysOfTheWeekSelected.count < 6{
            daysOfTheWeekSelected = [0,0,0,0,0,0,0]}
        
        
//        dateformatter for the time checks
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
        
        view.addSubview(inputBottomView)
        // Set its constraint to display it on screen
        inputBottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputBottomView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        inputBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputBottomView.isUserInteractionEnabled = true
        
        
    }
    
    
    
    func setupTheCalendar(completion: @escaping () -> Void){
        
//        in order to not override the data we already have, we check if the arrays are already populated before continuing
        
        if calendarArray2.count > 1{
            print("user already loadded the calendar, we do not continue")
        }
        else{
        
        currentMonthIndex = Calendar.current.component(.month, from: Date())
        currentYear = Calendar.current.component(.year, from: Date())
        todaysDate = Calendar.current.component(.day, from: Date())
        
        let recurringMonthArray = [1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12,1,2,3,4,5,6,7,8,9,10,11,12]
        let recurringMonthArrayString = ["01","02","03","04","05","06","07","08","09","10","11","12","01","02","03","04","05","06","07","08","09","10","11","12","01","02","03","04","05","06","07","08","09","10","11","12","01","02","03","04","05","06","07","08","09","10","11","12","01","02","03","04","05","06","07","08","09","10","11","12"]
        let dayArrayString = ["01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"]
        
//        we adjust the current month index for the fact it starts at 1
        let startingLoopIndex = currentMonthIndex - 1

//        calculate the final month we want to show base on the numberOfMonths setting
        let finalMonth = startingLoopIndex + numberOfMonths
        
//        we build an array of strings with all the dates contained, we leave blanks for any cells that shouldn't be populated, we populate:
//        calendarArray2
//        calendarTitleArray
        
        for n in startingLoopIndex...finalMonth{
//            we create a running count of the runs to add to the months calc
            let y = n - startingLoopIndex
            
//            set the month index for this loop
            let loopMonthIndex = recurringMonthArray[n]
            let monthString = recurringMonthArrayString[n]
//            set the year based on the current year, plus y
            let yearCalc = Calendar.current.date(byAdding: .month, value: y, to: Date())
            let currentYear = yearCalc!.get(.year)
            
//            we must resdet the days in the months index incase this year is a leap year, this must be run before we get the number of days in the month
            doLeapAdjust(year: currentYear)
            
//            get the first day of the week for the current month
            let firstWeekDayOfMonth = getFirstWeekDay(monthIndex: loopMonthIndex, year: currentYear)
            
//            get the number of days in the month
            let numberOfDayInMonth = numOfDaysInMonth[loopMonthIndex - 1]
            
//            we adjust the number of days in the month for the first day of the week in the month
            let totalNumberOfArrayEntries = numberOfDayInMonth + firstWeekDayOfMonth - 1
            
//            loop through each of the dates and add it to the array, including blanks for the empty dates
            var array = [String]()
//            we use an empty array to create an identical array but to hold the rows that have been selected
            var arrayEmpty = [String]()
             
//            we need to check if there is a currentUserSelectedEvent already selected
            
            var startTime = ""
            
            if currentUserSelectedEvent.eventStartTime == ""{
                 startTime = "00:00"
            }
            else{
                 startTime = convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime)
            }

            for n in 0...totalNumberOfArrayEntries - 1{
//              check if n is before the first day of the week
                if n < firstWeekDayOfMonth - 1{
//                    append a blank entry
                    array.append("")
                    arrayEmpty.append("")
                }
                else{
//            we create the date format in yyyy-MM-dd HH:mm z
//            print the timezone code e.g. GMT or CDT
//            var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
//            we use the method below to fetch the timeZone as the method above is not consistent in deliverting the CDT versus GMT
//            we need to get the timezone of the user for the particular date we are adding as the timezone will change based on summer time versus winter time
//            get the date we are adding to the array
//            we create the date format in yyyy-MM-dd HH:mm
                    let day = dayArrayString[n - firstWeekDayOfMonth + 1]
                    let date = ("\(currentYear)-\(monthString)-\(day) \(startTime)")
                
        //          convert to a date
                    let dateFormatteryyyyddmmhhss = DateFormatter()
                    dateFormatteryyyyddmmhhss.dateFormat = "yyyy-MM-dd HH:mm"
                    dateFormatteryyyyddmmhhss.locale = Locale(identifier: "en_US_POSIX")
                    
                    let dateDate = dateFormatteryyyyddmmhhss.date(from: date)
//                    let dateStringTZ = dateFormatterTZ.string(from: dateDate!)
                    
                    let dateFormatterZ = DateFormatter()
                    dateFormatterZ.dateFormat = "z"
                    dateFormatterZ.locale = Locale(identifier: "en_US_POSIX")
                    
                    let timezone = dateFormatterZ.string(from: dateDate!)
//                    print("timezone \(timezone)")
                    
                    
                   let dateString = ("\(currentYear)-\(monthString)-\(day) \(startTime) \(timezone)")
                    array.append(dateString)
                    arrayEmpty.append("")
                }
            }

                calendarArray2.append(array)
                calendarTitleArray.append(loopMonthIndex - 1)
            
            completion()
            print("calendarArray2 \(calendarArray2)")
        }
        }
    }
    
    
    lazy var inputBottomView: UIView = {
     
     
     let pageTitleHeight = CGFloat(50)
     let titleHeight = CGFloat(30)
     let timeHeight = CGFloat(25)
     let locationHeight = CGFloat(25)
     let sideInset = CGFloat(16)
     let imgSize = CGFloat(50)
     let closeSizeWidth = CGFloat(50)
        let closeSizeHeight = CGFloat(30)
     let cvInviteeHeight = CGFloat(70)
     let bottomButtonHeight = CGFloat(150)
     let spacer = CGFloat(10)
     let buttonSize = CGFloat(55)
     let buttonSpacing = (screenWidth - buttonSize*4)/5
     let lblSize = screenWidth/4
     let lblHeight = CGFloat(10)
    let buttonHeight = CGFloat(50)
    let collectionViewDatesHeight = CGFloat(80)
    let separatorHeight = CGFloat(1)
    let collectionViewHeight = CGFloat(30)
    let textBoxHeight = CGFloat(70)
     
     //   setup the view for holding the progress bar and title
     let containerView = UIView()
     containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - topDistance)
     containerView.backgroundColor = UIColor.white
     containerView.translatesAutoresizingMaskIntoConstraints = false
     
     //        trying to add a top view
     let topView = UIView()
     topView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: screenHeight - topDistance)
     topView.backgroundColor = UIColor.white
     topView.translatesAutoresizingMaskIntoConstraints = false
     containerView.addSubview(topView)
     topView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
     topView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
     topView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
     topView.heightAnchor.constraint(equalToConstant: screenHeight).isActive = true
     topView.isUserInteractionEnabled = true
     
 //    add the page title and the close button
     
     let pageTitle = UILabel()
     topView.addSubview(pageTitle)
     pageTitle.text = "Select Dates"
     pageTitle.textAlignment = .center
     pageTitle.font = UIFont.systemFont(ofSize: 18)
     pageTitle.translatesAutoresizingMaskIntoConstraints = false
     pageTitle.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
     pageTitle.topAnchor.constraint(equalTo: topView.topAnchor,constant: sideInset).isActive = true
     pageTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
     pageTitle.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
     
     let closeButton = UIButton()
     topView.addSubview(closeButton)
//     closeButton.setImage(UIImage(named: "closeButtonCode"), for: .normal)
     closeButton.setTitle("Done", for: .normal)
    closeButton.titleLabel?.adjustsFontSizeToFitWidth = true
     closeButton.setTitleColor(MyVariables.colourPlanrGreen, for: .normal)
     closeButton.translatesAutoresizingMaskIntoConstraints = false
     closeButton.rightAnchor.constraint(equalTo: topView.rightAnchor,constant: -sideInset).isActive = true
     closeButton.topAnchor.constraint(equalTo: topView.topAnchor, constant: sideInset).isActive = true
     closeButton.widthAnchor.constraint(equalToConstant: closeSizeWidth).isActive = true
     closeButton.heightAnchor.constraint(equalToConstant: closeSizeHeight).isActive = true
     closeButton.addTarget(self, action: #selector(closeSeclected), for: .touchUpInside)
        
        
//        add buttons to allow the user to switch between the calendar and filter view
        
        //        add the buttons for each selection
                topView.addSubview(btnCalendar)
            btnCalendar.setTitle("Calendar view", for: .normal)
            btnCalendar.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            btnCalendar.setTitleColor(.black, for: .normal)
            btnCalendar.contentHorizontalAlignment = .center
            btnCalendar.addTarget(self, action: #selector(showDateSelectors), for: .touchUpInside)
            btnCalendar.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
            btnCalendar.widthAnchor.constraint(equalToConstant: screenWidth/2).isActive = true
            btnCalendar.topAnchor.constraint(equalTo: topView.topAnchor, constant: sideInset + titleHeight).isActive = true
            btnCalendar.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
            btnCalendar.translatesAutoresizingMaskIntoConstraints = false
        

        viewSeparatorCalendar.backgroundColor = MyVariables.colourPlanrGreen
        viewSeparatorCalendar.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(viewSeparatorCalendar)
        viewSeparatorCalendar.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
        viewSeparatorCalendar.widthAnchor.constraint(equalToConstant: screenWidth/2).isActive = true
        viewSeparatorCalendar.topAnchor.constraint(equalTo: topView.topAnchor, constant: sideInset + titleHeight + buttonHeight).isActive = true
        viewSeparatorCalendar.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        
        //        add the buttons for each selection
                topView.addSubview(btnFilter)
        btnFilter.setTitle("Filters view", for: .normal)
        btnFilter.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnFilter.setTitleColor(MyVariables.colourLight, for: .normal)
        btnFilter.contentHorizontalAlignment = .center
        btnFilter.addTarget(self, action: #selector(showFilterView), for: .touchUpInside)
        btnFilter.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
        btnFilter.widthAnchor.constraint(equalToConstant: screenWidth/2).isActive = true
        btnFilter.topAnchor.constraint(equalTo: topView.topAnchor, constant: sideInset + titleHeight).isActive = true
        btnFilter.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btnFilter.translatesAutoresizingMaskIntoConstraints = false
        
        viewSeparatorFilter.backgroundColor = MyVariables.colourLight
        viewSeparatorFilter.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(viewSeparatorFilter)
        viewSeparatorFilter.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
        viewSeparatorFilter.widthAnchor.constraint(equalToConstant: screenWidth/2).isActive = true
        viewSeparatorFilter.topAnchor.constraint(equalTo: topView.topAnchor, constant: sideInset + titleHeight + buttonHeight).isActive = true
        viewSeparatorFilter.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        
        
        
//        add the two views with the calendar view and filterview
        
        
//        mark: add the calendar view
        topView.addSubview(viewCalendar)
        viewCalendar.isHidden = false
        viewCalendar.translatesAutoresizingMaskIntoConstraints = false
        viewCalendar.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
        viewCalendar.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
        viewCalendar.topAnchor.constraint(equalTo: topView.topAnchor, constant: sideInset + titleHeight + buttonHeight + separatorHeight).isActive = true
        viewCalendar.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        
//        add the collectionview to house the calendar
        let layout4: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout4.scrollDirection = .vertical
        //        layout3.sectionHeadersPinToVisibleBounds = true
        collectionViewCalendar = UICollectionView(frame: .zero, collectionViewLayout: layout4)
        collectionViewCalendar.translatesAutoresizingMaskIntoConstraints = false
        collectionViewCalendar.delegate = self
        collectionViewCalendar.dataSource = self
        collectionViewCalendar.backgroundColor = .white
        collectionViewCalendar.register(NL_collectionCollectionViewDateCell.self, forCellWithReuseIdentifier: cellId4)
        collectionViewCalendar.isScrollEnabled = true
        collectionViewCalendar.isUserInteractionEnabled = true
        collectionViewCalendar.allowsSelection = true
        collectionViewCalendar.allowsMultipleSelection = true
        viewCalendar.addSubview(collectionViewCalendar)
        collectionViewCalendar.leftAnchor.constraint(equalTo: viewCalendar.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        collectionViewCalendar.rightAnchor.constraint(equalTo: viewCalendar.rightAnchor,constant: -CGFloat(sideInset)).isActive = true
        collectionViewCalendar.topAnchor.constraint(equalTo: viewCalendar.topAnchor).isActive = true
        collectionViewCalendar.bottomAnchor.constraint(equalTo: viewCalendar.bottomAnchor).isActive = true
        collectionViewCalendar.register(SectionHeaderCalendar.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        //        setup the calendarView
        setupTheCalendar{
            self.collectionViewCalendar.reloadData()
                }
        
//        Mark: add the filter view
        
        topView.addSubview(viewFilter)
//        the calendar is the defaul view being shown, so we hide the filters
        viewFilter.isHidden = true
        viewFilter.translatesAutoresizingMaskIntoConstraints = false
        viewFilter.leftAnchor.constraint(equalTo: topView.leftAnchor).isActive = true
        viewFilter.rightAnchor.constraint(equalTo: topView.rightAnchor).isActive = true
        viewFilter.topAnchor.constraint(equalTo: topView.topAnchor, constant: sideInset + titleHeight + buttonHeight + separatorHeight).isActive = true
        viewFilter.bottomAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        
        
        let label = UILabel()
        label.text = "Select a timeframe for your event"
        label.textColor = MyVariables.colourLight
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        viewFilter.addSubview(label)
        label.leftAnchor.constraint(equalTo: viewFilter.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        label.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
        label.topAnchor.constraint(equalTo: viewFilter.topAnchor, constant: spacer).isActive = true
        label.heightAnchor.constraint(equalToConstant: collectionViewDatesHeight/3).isActive = true
        
        let label2 = UILabel()
        label2.text = "Select a range:"
        label2.textColor = MyVariables.colourLight
        label2.numberOfLines = 1
        label2.translatesAutoresizingMaskIntoConstraints = false
        viewFilter.addSubview(label2)
        label2.leftAnchor.constraint(equalTo: viewFilter.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        label2.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
        label2.topAnchor.constraint(equalTo: viewFilter.topAnchor, constant: spacer + collectionViewDatesHeight - collectionViewDatesHeight*1/3).isActive = true
        label2.heightAnchor.constraint(equalToConstant: collectionViewDatesHeight/3).isActive = true
        
        let label3 = UILabel()
        label3.text = "Select days of the week:"
        label3.textColor = MyVariables.colourLight
        label3.numberOfLines = 1
        label3.translatesAutoresizingMaskIntoConstraints = false
        viewFilter.addSubview(label3)
        label3.leftAnchor.constraint(equalTo: viewFilter.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        label3.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*4).isActive = true
        label3.topAnchor.constraint(equalTo: viewFilter.topAnchor, constant: spacer*3 + collectionViewDatesHeight).isActive = true
        label3.heightAnchor.constraint(equalToConstant: collectionViewDatesHeight).isActive = true
        
        
//        add the collection view to display the selected dates for the filtered view, we do not need it for the calendar view
                let layout3: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                layout3.scrollDirection = .horizontal
        //        layout3.sectionHeadersPinToVisibleBounds = true
                collectionViewDates = UICollectionView(frame: .zero, collectionViewLayout: layout3)
                collectionViewDates.translatesAutoresizingMaskIntoConstraints = false
                collectionViewDates.delegate = self
                collectionViewDates.dataSource = self
                collectionViewDates.backgroundColor = .white
                collectionViewDates.register(createEventDatesCell.self, forCellWithReuseIdentifier: cellId3)
                collectionViewDates.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
                collectionViewDates.isScrollEnabled = true
                collectionViewDates.isUserInteractionEnabled = true
                collectionViewDates.allowsSelection = true
                collectionViewDates.allowsMultipleSelection = false
                viewFilter.addSubview(collectionViewDates)
                collectionViewDates.leftAnchor.constraint(equalTo: viewFilter.leftAnchor, constant: CGFloat(sideInset)).isActive = true
                collectionViewDates.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
                collectionViewDates.topAnchor.constraint(equalTo: viewFilter.topAnchor, constant: collectionViewDatesHeight*2 + collectionViewHeight + spacer*4).isActive = true
                collectionViewDates.heightAnchor.constraint(equalToConstant: collectionViewDatesHeight).isActive = true
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionviewSearch = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionviewSearch.translatesAutoresizingMaskIntoConstraints = false
        collectionviewSearch.delegate = self
        collectionviewSearch.dataSource = self
        collectionviewSearch.backgroundColor = .white
        collectionviewSearch.register(createEventSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionviewSearch.isScrollEnabled = true
        collectionviewSearch.isUserInteractionEnabled = true
        collectionviewSearch.allowsSelection = true
        collectionviewSearch.allowsMultipleSelection = false
        viewFilter.addSubview(collectionviewSearch)
        collectionviewSearch.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        collectionviewSearch.widthAnchor.constraint(equalToConstant: screenWidth - sideInset - sideInset).isActive = true
        collectionviewSearch.topAnchor.constraint(equalTo: viewFilter.topAnchor, constant: collectionViewDatesHeight + spacer).isActive = true
        collectionviewSearch.heightAnchor.constraint(equalToConstant: collectionViewHeight).isActive = true
        
////        add a specer between the two
//        let separatorView = UIView()
//        separatorView.backgroundColor = MyVariables.colourPlanrGreen
//        separatorView.translatesAutoresizingMaskIntoConstraints = false
//        viewFilter.addSubview(separatorView)
//        separatorView.leftAnchor.constraint(equalTo: viewFilter.leftAnchor, constant: sideInset).isActive = true
//        separatorView.widthAnchor.constraint(equalToConstant: screenWidth - sideInset*2).isActive = true
//        separatorView.topAnchor.constraint(equalTo: viewFilter.topAnchor, constant: collectionViewDatesHeight + spacer*1.5 + collectionViewHeight).isActive = true
//        separatorView.heightAnchor.constraint(equalToConstant: separatorHeight).isActive = true
        
        //        setup the collectionView for the search periods
        let layout2: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout2.scrollDirection = .vertical
        collectionviewDaysOfTheWeek = UICollectionView(frame: .zero, collectionViewLayout: layout2)
        collectionviewDaysOfTheWeek.translatesAutoresizingMaskIntoConstraints = false
        collectionviewDaysOfTheWeek.delegate = self
        collectionviewDaysOfTheWeek.dataSource = self
        collectionviewDaysOfTheWeek.backgroundColor = .white
        collectionviewDaysOfTheWeek.register(dotwCell.self, forCellWithReuseIdentifier: cellId2)
        collectionviewDaysOfTheWeek.isScrollEnabled = true
        collectionviewDaysOfTheWeek.isUserInteractionEnabled = true
        collectionviewDaysOfTheWeek.allowsSelection = true
        collectionviewDaysOfTheWeek.allowsMultipleSelection = true
        viewFilter.addSubview(collectionviewDaysOfTheWeek)
        collectionviewDaysOfTheWeek.leftAnchor.constraint(equalTo: viewFilter.leftAnchor, constant: CGFloat(sideInset)).isActive = true
        collectionviewDaysOfTheWeek.widthAnchor.constraint(equalToConstant: screenWidth - sideInset - sideInset).isActive = true
        collectionviewDaysOfTheWeek.topAnchor.constraint(equalTo: viewFilter.topAnchor, constant: collectionViewDatesHeight + collectionViewHeight + spacer*5).isActive = true
        collectionviewDaysOfTheWeek.heightAnchor.constraint(equalToConstant: textBoxHeight).isActive = true
        
        
        return containerView
        }()
    
    
    
    //    function to dismiss the event view on pressing the close button
        @objc func closeSeclected(){
            print("user selected to close the select dates view")
            
//            we trigger a notification to tell the other VC to refresh its date shown
            NotificationCenter.default.post(name: .datesChosen, object: nil)
            self.dismiss(animated: true)
        }
    
    
    @objc func showDateSelectors(){
        print("user selected to see the calendar view")
        
//        set the view to visible
                viewCalendar.isHidden = false
                viewFilter.isHidden = true
                
//        set the colors of the selectors
                viewSeparatorFilter.backgroundColor = MyVariables.colourLight
                viewSeparatorCalendar.backgroundColor = MyVariables.colourPlanrGreen
                btnCalendar.setTitleColor(MyVariables.colourPlanrGreen, for: .normal)
                btnFilter.setTitleColor(MyVariables.colourLight, for: .normal)
        
        collectionViewCalendar.reloadData()
        
    }
    @objc func showFilterView(){
        print("user selected to see the filter view")
        
//        set the view to visible
        viewCalendar.isHidden = true
        viewFilter.isHidden = false
        
//        reload the collectionView to ensure it shows the latest dates
        collectionViewDates.reloadData()
        
//        set the colors of the selectors
        viewSeparatorFilter.backgroundColor = MyVariables.colourPlanrGreen
        viewSeparatorCalendar.backgroundColor = MyVariables.colourLight
        btnCalendar.setTitleColor(MyVariables.colourLight, for: .normal)
        btnFilter.setTitleColor(MyVariables.colourPlanrGreen, for: .normal)
        
        
    }
    
    
    //    fucntion to determine the dates applicable for the search period chosen by the user
        func findDates(completion: @escaping () -> Void){
    //        check if the user has chosen any days of the week or search period
            let dowCheck = daysOfTheWeekSelected.filter({ $0 == 1 }).count
            let datesCheck = searchPeriodChoicesSelected.filter({ $0 == 1 }).count
            
            if dowCheck == 0 || datesCheck == 0{
                print("user not made enough selections to calcaulte the dates")
                startDatesChosen.removeAll()
                endDatesChosen.removeAll()
                completion()
            }
            else{
    //            get start date and end date
                let currentDate = Date()
    //            get the index of the selected search period
                let index = searchPeriodChoicesSelected.index(of: 1)
                let newEndDate = dateInXDays(increment: timePeriodsAddition[index!], additionType: timePeriodsAdditionType[index!])
                
    //            input the above into the get dates function
                var dateFormatterInputString = DateFormatter()
                dateFormatterInputString.locale = Locale(identifier: "en_US_POSIX")
                dateFormatterInputString.dateFormat = "yyyy-MM-dd"
                let startDateInput = dateFormatterInputString.string(from: currentDate)
                let endDateInput = dateFormatterInputString.string(from: newEndDate)
                
    //            convert the day of the week selected index into a days of the week array, the day of the week input has sunday as the first day of the array, we need to adapt our selected array to the days of the week array
                var DOTW = [Int]()
                var n = 1
                var y = 0
                for i in daysOfTheWeekSelected{
                    if n == 7{
                        if i == 1{
                            DOTW.insert(0, at: 0)
                            print("DOTW \(DOTW)")
                        }
                        else{
                           DOTW.insert(10, at: 0)
                            print("DOTW \(DOTW)")
                        }
                    }
                    else{
                    if i == 1{
                        DOTW.insert(n, at: y)
                        n = n + 1
                        y = y + 1
                        print("DOTW \(DOTW)")
                    }
                    else{
                       DOTW.insert(10, at: y)
                        n = n + 1
                        y = y + 1
                        print("DOTW \(DOTW)")
                    }
                    }
                }
    //            set the day of the week equal to the global variable such that we use them when we create the event
                daysOfTheWeekNewEvent = DOTW
                
//                if the user is editing an event we want to add the start time to the dates to ensure the calendar shows the correct dates chosen
                var startTime = ""
                if currentUserSelectedEvent.eventStartTime == ""{
                     startTime = "00:00"
                }
                else{
                     startTime = convertToLocalTime(inputTime: currentUserSelectedEvent.eventStartTime)}
                
                getStartAndEndDates3(startDate: startDateInput, endDate: endDateInput, startTime: startTime, endTime: "01:00", daysOfTheWeek: DOTW){(startDates,endDates) in
    //        set the global variables
                    print("")
                    startDatesChosen = startDates
                    endDatesChosen = endDates
    //                we set the global new dates for the event creation
                    let startDate = startDatesChosen.first
                    let endDate = endDatesChosen.last
                    newEventEndDate =  String(endDate![0...9])
                    newEventStartDate = String(startDate![0...9])
                    

                    //            we need to covert all strings into dates
                    var chosenDates = startDatesChosen.map { self.dateFormatterTZ.date(from: $0)}
                    //            order the strings
                    chosenDates.sort { $0! < $1! }
                    let chosenDatesSorted = chosenDates.map { self.dateFormatterTZ.string(from: $0!)}
                                startDatesChosen = chosenDatesSorted
                    
                    print("findDates - startDatesChosen \(startDatesChosen)")

                    completion()
                }
            }
        }
    
//    the following function adjusts the numOfDaysInMonth array to adjust for leap years, we call this when creating the calendar
    func doLeapAdjust(year: Int){
            print("running func getDaysInMonth - year: \(year)")
                        //for leap year, make february month of 29 days
                            if year % 4 == 0 {
                                numOfDaysInMonth[1] = 29
                                numOfDaysInMonth[13] = 29
                                numOfDaysInMonth[25] = 29
                            } else {
                                numOfDaysInMonth[1] = 28
                                numOfDaysInMonth[13] = 28
                                numOfDaysInMonth[25] = 28
                            }
    }
    
//    returns the first weekday of the month
    func getFirstWeekDay(monthIndex: Int, year: Int) -> Int {
        var day = Int()
        day  = ("\(year)-\(monthIndex)-01".date?.firstDayOfTheMonth.weekday)!
        
//        we have to adjust the date by one day
        if day == 1{
         day = 7
        }
        else{
            day = day - 1
        }
        print("getFirstWeekDay - day \(day)")
        return day
    }
    
//end of the main viewController
}


// setup the collectionView
extension NL_createEventSelectDates: UICollectionViewDelegate, UICollectionViewDataSource {
    
//    we only have one section in each collectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        var numberOfSections = Int()
        
        if collectionView == collectionViewCalendar{
//            we set a static number of 24 months to be available to the user, arbitary decision
            numberOfSections = numberOfMonths
            print("collectionViewCalendar numberOfSections: \(numberOfSections)")
        
        }else{
            numberOfSections = 1
        }
        
        return numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var numberOfItems = Int()
        
        if collectionView == collectionviewSearch{
        numberOfItems = searchPeriodChoices.count
        print("collectionView number of items \(numberOfItems)")
        }
        else if collectionView == collectionviewDaysOfTheWeek{
            numberOfItems = daysOfTheWeek.count
        }
//            set the dates count and set the backgorund message
        else if collectionView == collectionViewDates{
            if startDatesChosen.count == 0{
                collectionView.setEmptyMessage(message: "Select from the options above", messageAlignment: .left)
                numberOfItems = startDatesChosen.count
            }
            else{
//                reset the background image
                collectionView.restore()
                numberOfItems = startDatesChosen.count
            }
            return numberOfItems
        }
        else if collectionView == collectionViewCalendar{
            
//            determine the dates for the each section, based on the month of the year
            let dateArray = calendarArray2[section]
            let dateCount = dateArray.count
            numberOfItems = dateCount
//            print("collectionViewCalendar numberOfItems: \(numberOfItems)")
            
          return numberOfItems
        }
        
        
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = UICollectionViewCell()
        
        if collectionView == collectionviewSearch{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! createEventSearchCell
        
        cell.cellText.text = searchPeriodChoices[indexPath.row]
        cell.cellText.textColor = MyVariables.colourPlanrGreen
        cell.cellText.font = UIFont.systemFont(ofSize: 14)
        cell.layer.backgroundColor = MyVariables.colourSelected.cgColor
        cell.textView.layer.backgroundColor = MyVariables.colourSelected.cgColor
        cell.cellText.backgroundColor = MyVariables.colourSelected
        
//            add the border for the selected
            if searchPeriodChoicesSelected[indexPath.row] == 1{
                cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
                    cell.layer.borderWidth = 3
                }
                else{
                    cell.layer.borderColor = MyVariables.colourBackground.cgColor
                    cell.layer.borderWidth = 0
                }
        
        print("searchPeriodChoices\([indexPath.row]) \(searchPeriodChoices[indexPath.row])")
        
        return cell
        }
        
        else if collectionView == collectionViewCalendar{
            let cell = collectionViewCalendar.dequeueReusableCell(withReuseIdentifier: cellId4, for: indexPath) as! NL_collectionCollectionViewDateCell
//            print("cellForItem collectionView has been dequeueReusableCell")
            let dateArray = calendarArray2[indexPath.section]
            let currentDate = dateArray[indexPath.row]
//            print("currentDate \(currentDate)")
//            format yyyy-MM-DD
            

//            get the date of the current date
            let currentDateDate = dateFormatterTZ.date(from: currentDate)
            let today = Date()
            let tomorrow = today.addingTimeInterval(-86400)
            
            
//            there are blank cells in the date array to align the first week day of the month
            if currentDate == ""{
                cell.isUserInteractionEnabled=false
                cell.label.text = ""
                cell.label.backgroundColor = .white
            }
            else{
                cell.label.text = String(currentDate[8...9])
                cell.isUserInteractionEnabled=true
            
//            set the text colour based on whether the date in past
            if currentDateDate! < tomorrow{
                cell.label.backgroundColor = .white
                cell.label.textColor = MyVariables.colourLight
            }
            else{
                cell.label.backgroundColor = .white
                cell.label.textColor = .black
            }
            
//            check if the selected date array contains the date we are setting up
            if startDatesChosen.contains(currentDate){
                cell.label.backgroundColor = MyVariables.colourPlanrGreen
                cell.label.textColor = .white
            }
            }

            return cell
        }
        
        else if collectionView == collectionviewDaysOfTheWeek{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId2, for: indexPath) as! dotwCell
            
            cell.cellText.text = daysOfTheWeek[indexPath.row]
            cell.cellText.textColor = MyVariables.colourPlanrGreen
            cell.cellText.font = UIFont.systemFont(ofSize: 14)
            cell.cellText.backgroundColor = MyVariables.colourSelected
            cell.layer.backgroundColor = MyVariables.colourSelected.cgColor
            cell.textView.layer.backgroundColor = MyVariables.colourSelected.cgColor
            
            //            add the border for the selected
            if daysOfTheWeekSelected[indexPath.row] == 1{
                cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
                    cell.layer.borderWidth = 3
                }
                else{
                    cell.layer.borderColor = MyVariables.colourBackground.cgColor
                    cell.layer.borderWidth = 0
                }
            return cell
        }
        
//        setup the cell for the dates view
        else if collectionView == collectionViewDates{
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId3, for: indexPath) as! createEventDatesCell
           
//            setup the cell look
            cell.layer.borderColor = MyVariables.colourPlanrGreen.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
            
            print("indexPath.row \(indexPath.row)")
//           we need to convert the start dates into a format we can display
            let dateIndex = startDatesChosen[indexPath.row]
            let dateIndexDate = dateFormatterTZ.date(from: dateIndex)
            let month = dateIndexDate!.get(.month) - 1
            let day = dateIndexDate!.get(.weekday)
            let dayInt = dateIndexDate!.get(.day)
            
//            arrays to convert the dates into strings
            let monthArray = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
            let weekDays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
            
            cell.monthText.text = ("\(monthArray[month])")
            cell.monthText.textColor = MyVariables.colourLight
            cell.monthText.font = UIFont.systemFont(ofSize: 13)
            
            cell.dayText.text = ("\(dayInt)")
            cell.dayText.font = UIFont.systemFont(ofSize: 20)
            
            cell.dowText.text = ("\(weekDays[day-1])")
            cell.dowText.textColor = MyVariables.colourLight
            cell.dowText.font = UIFont.systemFont(ofSize: 13)
            
            
            return cell
        }
        
        print("we didnt get a collectionView to load")
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if the collectionView is the one for searchPeriods then update the array and reload the table
        if collectionView == collectionviewSearch{
            print("user selected a period searchPeriodChoicesSelected[indexPath.row] \(searchPeriodChoicesSelected[indexPath.row])")
//            reset the array
            searchPeriodChoicesSelected = [0,0,0,0,0]
            searchPeriodChoicesSelected[indexPath.row] = 1
            collectionviewSearch.reloadData()
            
//            we need to get the end date for the period selected by the user
            let currentDate = Date()
            let dateFormatterDisplay = DateFormatter()
            dateFormatterDisplay.dateFormat = "dd MMM YYYY"
            dateFormatterDisplay.locale = Locale(identifier: "en_US_POSIX")
//            function to calcaulte the end of the period selected by the user
            let newEndDate = dateInXDays(increment: timePeriodsAddition[indexPath.row], additionType: timePeriodsAdditionType[indexPath.row])
//            convert this into a display date
            let newEndDateDisplay = dateFormatterDisplay.string(from: newEndDate)
            print("newEndDate: \(newEndDateDisplay)")
//            get the current date
            let today = dateFormatterDisplay.string(from: currentDate)
            
//            calculate the date for the selection
            findDates{
//                reload the tables of dates once complete
                self.collectionViewDates.reloadData()
            }
        }
        else if collectionView == collectionviewDaysOfTheWeek{
//            we can select multiple day of the week, hence we need to change the original selection
            print("user selected a day of the week daysOfTheWeekSelected[indexPath.row] \(daysOfTheWeekSelected[indexPath.row])")
            if daysOfTheWeekSelected[indexPath.row] == 1{
                daysOfTheWeekSelected[indexPath.row] = 0
            }
            else{
              daysOfTheWeekSelected[indexPath.row] = 1
            }
//            calculate the date for the selection
            findDates{
                self.collectionviewDaysOfTheWeek.reloadData()
                //                reload the tables of dates once complete
                self.collectionViewDates.reloadData()
            }
        }
//            we don't do anything when the user selects a date in the collectionView
        else if collectionView == collectionViewDates{
            print("user selected a date - we do nothing")
        }
        else if collectionView == collectionViewCalendar{
//            print("calendarArray2[indexPath.section][indexPath.row] \(calendarArray2[indexPath.section][indexPath.row])")
            
//            check if the date was already selected
            if startDatesChosen.contains(calendarArray2[indexPath.section][indexPath.row]){
//                we remove the date from the array
                if let index = startDatesChosen.index(of: calendarArray2[indexPath.section][indexPath.row]){
                    startDatesChosen.remove(at: index)
                }
            }
            else{
//                we select the date
                startDatesChosen.append(calendarArray2[indexPath.section][indexPath.row])
                
                //            we need to covert all strings into dates
                var chosenDates = startDatesChosen.map { self.dateFormatterTZ.date(from: $0)}
                //            order the strings
                chosenDates.sort { $0! < $1! }
                let chosenDatesSorted = chosenDates.map { self.dateFormatterTZ.string(from: $0!)}
                            startDatesChosen = chosenDatesSorted
                
            }
            
//            reload the collectionview
            collectionViewCalendar.reloadData()
            print("startDatesChosen \(startDatesChosen)")
        }
    }
}

// setup the collectionView layout

extension NL_createEventSelectDates: UICollectionViewDelegateFlowLayout {
    
    
    // sets the size of the cell based on the collectionView
    func collectionView(_ collectionView: UICollectionView,
                           layout collectionViewLayout: UICollectionViewLayout,
                           sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        
        if collectionView == collectionviewSearch{
            size = CGSize(width: 70, height: 30)
        }
        else if collectionView == collectionviewDaysOfTheWeek{
            size = CGSize(width: 50, height: 30)
        }
        else if collectionView == collectionViewDates{
            size = CGSize(width: 80, height: 80)
        }
        else if collectionView == collectionViewCalendar{
            let wandH = CGFloat((screenWidth - 16*8)/7)
            
            size = CGSize(width: wandH, height: wandH)
        }
           return size
       }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        var spacing = CGFloat(0)
        
        if collectionView == collectionViewCalendar{
            spacing = CGFloat(16)
        }
        
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == collectionViewDates{
            if kind == UICollectionView.elementKindSectionHeader {
         let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
                
//                if the user hasnt made a selection, we dont want to show anything
                if startDatesChosen.count == 0{
                   sectionHeader.label.text = ""
                }
                else{
                    sectionHeader.label.text = ("\(startDatesChosen.count) Options")
                    
                }
         return sectionHeader
    } else { print("this wasnt a collectionView header kind - \(kind)")
         return UICollectionReusableView()
            }}
        else if collectionView == collectionViewCalendar{
            if kind == UICollectionView.elementKindSectionHeader {
                let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeaderCalendar
                let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December","January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December","January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
                let dateArray = calendarArray2[indexPath.section]
                let date = dateArray.last
                let year = date![0...3]
                let monthInt = calendarTitleArray[indexPath.section]
                let month = months[monthInt]
                
                sectionHeader.label.text = ("\(month) \(year)")
                
            return sectionHeader
            }
        }
         return UICollectionReusableView()
    }
    
//    defines the size of the header for the collectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if collectionView == collectionViewDates{
        
            return CGSize(width: 80, height: 50)
        }
        else if collectionView == collectionViewCalendar{
            
        return CGSize(width: screenWidth, height: 50)
        }
        else{
            return CGSize(width: 0, height: 0)
        }
    }
    
}

//class for the section header of the collectionView
class SectionHeaderCalendar: UICollectionReusableView {
     var label: UILabel = {
     let label: UILabel = UILabel()
    label.textColor = MyVariables.colourLight
     label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
     label.sizeToFit()
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
     return label
 }()

override init(frame: CGRect) {
     super.init(frame: frame)

     addSubview(label)
    let titleHeight = CGFloat(25)
    let monthHeight = CGFloat(15)
    let sideInset = CGFloat(16)

     label.translatesAutoresizingMaskIntoConstraints = false
    label.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
    label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
     label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
     label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
     label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    
    //            2. create the lables to go within the view
    //            2.1 calcaulte the size of each label
    //            sideInset*8 = the number of spaces on the page, spaces between the dotw and at the edges of the page
                let labelSize = CGFloat((screenWidth - sideInset*8)/7)
                let daysOfTheWeek = ["Mon","Tues","Wed","Thu","Fri","Sat","Sun"]
                let leftSapcing = [0,labelSize+sideInset,labelSize*2+sideInset*2,labelSize*3+sideInset*3,labelSize*4+sideInset*4,labelSize*5+sideInset*5,labelSize*6+sideInset*6]
    //            2.2 loop through each day of the week to create the label
                for n in 0...daysOfTheWeek.count-1{
                    let lbl = UILabel()
                    lbl.text = daysOfTheWeek[n]
                    lbl.font = UIFont.systemFont(ofSize: 13)
                    lbl.textAlignment = .center
                    lbl.textColor = MyVariables.colourLight
                    self.addSubview(lbl)
                    lbl.heightAnchor.constraint(equalToConstant: monthHeight).isActive = true
                    lbl.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                    lbl.widthAnchor.constraint(equalToConstant: labelSize*1).isActive = true
                    lbl.leftAnchor.constraint(equalTo: self.leftAnchor, constant: leftSapcing[n]).isActive = true
                    lbl.translatesAutoresizingMaskIntoConstraints = false
                }
}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
