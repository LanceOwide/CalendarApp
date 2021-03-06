//
//  PlanrViewController.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 13/12/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class PlanrViewController: UIViewController, MonthViewDelegate{

    
    @IBOutlet weak var viewMonthPicker: UIView!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var myTopView: UIView!
    
    @IBOutlet weak var myBottomView: UIView!
    
    
    
    
    var numOfDaysInMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
    var monthsArr = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var currentMonthIndex: Int = 0
    var currentYear: Int = 0
    var presentMonthIndex = 0
    var presentYear = 0
    var todaysDate = 0
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
    var monthsEvents = [PlanrEventStruct]()
    var eventDetailsArray = [[PlanrEventStruct?]]()
    
    let monthView: MonthView = {
        let v=MonthView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            myCollectionView.delegate = self
            myCollectionView.dataSource = self
            
            myTableView.delegate = self
            myTableView.dataSource = self
            
           initialiseView()

            navigationItem.titleView = setAppHeader(colour: UIColor.black)
        
        }

        
        func initialiseView(){
            
            currentMonthIndex = Calendar.current.component(.month, from: Date())
            currentYear = Calendar.current.component(.year, from: Date())
            todaysDate = Calendar.current.component(.day, from: Date())
            firstWeekDayOfMonth=getFirstWeekDay()
            
            presentMonthIndex=currentMonthIndex
            presentYear=currentYear
 
            //for leap years, make february month of 29 days
            if currentMonthIndex == 2 && currentYear % 4 == 0 {
                numOfDaysInMonth[currentMonthIndex-1] = 29
            }
            
            viewMonthPicker.addSubview(monthView)
            monthView.topAnchor.constraint(equalTo: viewMonthPicker.topAnchor).isActive=true
            monthView.leftAnchor.constraint(equalTo: viewMonthPicker.leftAnchor).isActive=true
            monthView.rightAnchor.constraint(equalTo: viewMonthPicker.rightAnchor).isActive=true
            monthView.heightAnchor.constraint(equalToConstant: 35).isActive=true
            monthView.delegate=self
            
//            set collectionView Colour
            myCollectionView.backgroundColor = circleColour
            myTopView.backgroundColor = circleColour
            myBottomView.clipsToBounds = true
            myBottomView.layer.cornerRadius = 15
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(addTapped))
            
            navigationBarSettings(navigationController: navigationController!, isBarHidden: false, isBackButtonHidden: false, tintColour: UIColor.black)

            getMonthEventsID{(eventIDs) in
                
                self.getMonthEventsDetail(eventIDs: eventIDs) {_ in
                    
                    print("monthsEvents: \(self.monthsEvents)")
                    
                    self.createEventArray{_ in
                       
                        self.myCollectionView.reloadData()
                        self.myTableView.reloadData()
                    }
                }
            }
        }
    
    
    @objc func addTapped(){
        
     self.performSegue(withIdentifier: "planrAddEvent", sender: self)
        
    }

    
        
        func getFirstWeekDay() -> Int {
               let day  = ("\(currentYear)-\(currentMonthIndex)-01".date?.firstDayOfTheMonth.weekday)!
               //return day == 7 ? 1 : day
               return day
           }
        
        
        func didChangeMonth(monthIndex: Int, year: Int) {
            
            print("Did change month")
            currentMonthIndex=monthIndex+1
            currentYear = year

            
            //for leap year, make february month of 29 days
            if monthIndex == 1 {
                if currentYear % 4 == 0 {
                    numOfDaysInMonth[monthIndex] = 29
                } else {
                    numOfDaysInMonth[monthIndex] = 28
                }
            }
            //end
            
            firstWeekDayOfMonth=getFirstWeekDay()
            
            getMonthEventsID{(eventIDs) in
                
                self.getMonthEventsDetail(eventIDs: eventIDs) {_ in
                    
                    print("monthsEvents: \(self.monthsEvents)")
                    
                    self.createEventArray{_ in
                       
                        self.myCollectionView.reloadData()
                        self.myTableView.reloadData()
                    }
                    
                }
            }

//            self.myCollectionView.reloadData()
//            self.myTableView.reloadData()
            monthView.btnLeft.isEnabled = !(currentMonthIndex == presentMonthIndex && currentYear == presentYear)
        }
    }


    extension PlanrViewController: UICollectionViewDataSource, UICollectionViewDelegate{
        

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
            print("numberOfItemsInSection: \(numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1)")
            
            return numOfDaysInMonth[currentMonthIndex-1] + firstWeekDayOfMonth - 1
        }
        

        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "planrCollectionViewCell", for: indexPath) as! CollectionViewCellDates
                   
            cell.backgroundColor=UIColor.clear
            cell.layer.cornerRadius=5
            cell.layer.masksToBounds=true
            
            print("indexPath.item: \(indexPath.item) firstWeekDayOfMonth \(firstWeekDayOfMonth)")

          if indexPath.item <= firstWeekDayOfMonth - 2 {
                  cell.isHidden=true
              } else {
                  let calcDate = indexPath.row-firstWeekDayOfMonth+2
                  cell.isHidden=false
                  cell.lblDate.text="\(calcDate)"
                    cell.isUserInteractionEnabled=true
                    cell.lblDate.textColor = UIColor.white
            
            if indexPath.item <= firstWeekDayOfMonth - 2{
             cell.lblBusy.text = ""
            }
            else if eventDetailsArray.isEmpty{
                cell.lblBusy.text = ""
            }
            else if eventDetailsArray[indexPath.item - firstWeekDayOfMonth + 1] == [nil]{
               cell.lblBusy.text = ""
            }
            else{
                cell.lblBusy.text = "⦁"
            }
              }
              return cell
          }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("user selected collectionView at: \(indexPath)")
            let cell = myCollectionView.cellForItem(at: indexPath) as! CollectionViewCellDates
            cell.backgroundColor = UIColor.darkGray
            let lbl = cell.lblDate
            lbl?.textColor = UIColor.white
            let tableViewIndexPathRow = indexPath.row - firstWeekDayOfMonth + 1
            let indexPathTableView = NSIndexPath(row: tableViewIndexPathRow, section: 0)
            myTableView.scrollToRow(at: indexPathTableView as IndexPath, at: .top, animated: true)
        }
        
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            let cell = myCollectionView.cellForItem(at: indexPath) as! CollectionViewCellDates
            cell.backgroundColor=UIColor.clear
            let lbl = cell.lblDate
            lbl?.textColor = UIColor.white
        }
    }

    extension PlanrViewController: UICollectionViewDelegateFlowLayout{
        
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = collectionView.frame.width/7 - 8
            let height: CGFloat = 40
            return CGSize(width: width, height: height)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 8.0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 8.0
        }
    }


//MARK: tableview extension

    extension PlanrViewController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{
        
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            if tableView == myTableView{
            
            let numberOfRows = numOfDaysInMonth[currentMonthIndex - 1]
            
      
            return numberOfRows
            }
            else{
                
                let tableID = tableView.tag
                
                if eventDetailsArray.isEmpty{
                    let numberOfRows = 0
                    
                    print("tableView.tag: \(tableView.tag) numberOfRows: \(numberOfRows)")
                    
                    return numberOfRows
                    
                }
                
                else if eventDetailsArray[tableID] == [nil]{
                  
                    let numberOfRows = 0
                    
                    print("tableView.tag: \(tableView.tag) numberOfRows: \(numberOfRows)")
                    
                    return numberOfRows
                    
                }
                else{
                    
                  let array = eventDetailsArray[tableID]
//                    print("array: \(array)")
                    
                    let numberOfRows = array.count
                    
                    print("tableView.tag: \(tableView.tag) numberOfRows: \(numberOfRows)")
                    
                    return numberOfRows
                }
                
              
            }
        }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let greyColour = UIColor(red:224,green:224,blue:224)
        
        if tableView == myTableView{
        
            let cell = myTableView.dequeueReusableCell(withIdentifier: "planrTableViewCell") as! PlanrTableViewCell
            
            let calcDate = indexPath.row + 1
            
            cell.lblTop.text = ("\(calcDate) \(monthsArr[currentMonthIndex - 1]) \(currentYear) ")
            cell.lblTop.backgroundColor = greyColour
        
            cell.setPlanrTableViewDelegate(dataSourceDelegate: self, forRow: indexPath.row, forSection: indexPath.section)
            
            return cell
        }
        else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "planrEventsCell") as! PlanEventsTableViewCell
            
            let tableID = tableView.tag
            let endTime = eventDetailsArray[tableID][indexPath.row]?.eventEndTime
            let startTime = eventDetailsArray[tableID][indexPath.row]?.eventStartTime
            let description = eventDetailsArray[tableID][indexPath.row]?.eventDescription
            
            cell.lbl1.text = ("\(startTime!) - \(endTime!)")
            cell.lbl1.adjustsFontSizeToFitWidth = true
            cell.lbl2.text = ("⊙ \(description!)")
            cell.lbl2.adjustsFontSizeToFitWidth = true
            
            
//            Removing the border around each event
//            cell.layer.borderColor = UIColor.lightGray.cgColor
//            cell.layer.borderWidth = 2
//            cell.layer.cornerRadius = 5
//            cell.layer.backgroundColor = UIColor.white.cgColor
//            cell.layer.shadowColor = UIColor.lightGray.cgColor
//            cell.layer.shadowOffset = CGSize(width: 0, height: 0.5)
//            cell.layer.shadowRadius = 4
//            cell.layer.shadowOpacity = 0.5
//            cell.layer.masksToBounds = false
//            cell.alpha = 0.90
            
          return cell
        }
            
        }
        
        
        
//        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//            let indexPath = self.myTableView.indexPathsForVisibleRows![0]
//
////            print("tableViewRow visibe at top: \(indexPath)")
//
//
//            myCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .bottom)
//
//        }
        
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            if tableView == myTableView{
            
            return 125
        }
            else{
                
                return 50
            }
        
        
    }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if tableView == myTableView{
                tableView.deselectRow(at: indexPath, animated: true)
            }
            else{
            
            let tableID = tableView.tag
            let array = eventDetailsArray[tableID]
            let selectedEvent = array[indexPath.row]
            
            let eventID = selectedEvent!.eventID
            let eventOwner = selectedEvent!.eventOwnerID

                prepareForEventDetailsPage(eventID: eventID, isEventOwnerID: eventOwner, segueName: "planrEventSelected", isSummaryView: false, performSegue: true){
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            
            
            
        }
        }
        
}


//firebase extension
extension PlanrViewController{
    
    func getMonthEventsID(completion: @escaping (_ eventIDs: [String]) -> Void){
        
        monthsEvents.removeAll()
        var eventIDArray = [String]()
        eventIDArray.removeAll()
        let calendar = Calendar(identifier: .gregorian)
        
        let componentsFirstDayOfMonth = DateComponents(year: currentYear, month: currentMonthIndex, day: 1, hour: 0, minute: 0, second: 0)
        
        let componentsFirstDayOfMonthDate = calendar.date(from: componentsFirstDayOfMonth)!
        let priorMonth = Calendar.current.date(byAdding: .day, value: -1, to: componentsFirstDayOfMonthDate)!
        let NextMonth = Calendar.current.date(byAdding: .month, value: 1, to: componentsFirstDayOfMonthDate)!
        
        let monthAsNrPlus1 = Calendar.current.component(.month, from: NextMonth)
        let dayAsNrPlus1 = Calendar.current.component(.day, from: NextMonth)
        let yearAsNrPlus1 = Calendar.current.component(.year, from: NextMonth)
        
        let monthAsNrMinus1 = Calendar.current.component(.month, from: priorMonth)
        let dayAsNrMinus1 = Calendar.current.component(.day, from: priorMonth)
        let yearAsNrMinus1 = Calendar.current.component(.year, from: priorMonth)
        
        print("running func getMonthEvents - currentMonthIndex: \(currentMonthIndex) currentYear: \(currentYear)")
        
        dbStore.collection("userEventStore").whereField("uid", isEqualTo: user!).whereField("chosenDateMonth", isEqualTo: currentMonthIndex).whereField("chosenDateYear", isEqualTo: currentYear).getDocuments { (querySnapshot, error) in
               if error != nil {
                   print("Error getting documents: \(error!)")
               }
               else {
                   for document in querySnapshot!.documents {
                       print("\(document.documentID) => \(document.data())")
                    
                    let documentID = document.get("eventID") as! String
                    
                    eventIDArray.append(documentID)
                    
                }}
            
            dbStore.collection("userEventStore").whereField("uid", isEqualTo: user!).whereField("chosenDateMonth", isEqualTo: monthAsNrPlus1).whereField("chosenDateYear", isEqualTo: yearAsNrPlus1).whereField("chosenDateDay", isEqualTo: dayAsNrPlus1).getDocuments { (querySnapshot, error) in
                   if error != nil {
                       print("Error getting documents: \(error!)")
                   }
                   else {
                       for document in querySnapshot!.documents {
                           print("\(document.documentID) => \(document.data())")
                        
                        let documentID = document.get("eventID") as! String
                        
                        eventIDArray.append(documentID)
                        
                    }}
                
            dbStore.collection("userEventStore").whereField("uid", isEqualTo: user!).whereField("chosenDateMonth", isEqualTo: monthAsNrMinus1).whereField("chosenDateYear", isEqualTo: yearAsNrMinus1).whereField("chosenDateDay", isEqualTo: dayAsNrMinus1).getDocuments { (querySnapshot, error) in
                       if error != nil {
                           print("Error getting documents: \(error!)")
                       }
                       else {
                           for document in querySnapshot!.documents {
                               print("\(document.documentID) => \(document.data())")
                            
                            let documentID = document.get("eventID") as! String
                            
                            eventIDArray.append(documentID)
                            
                        }}
                    
                    completion(eventIDArray)
                }
            }
        }}
    
    func getMonthEventsDetail(eventIDs: [String], completion: @escaping (_ complete: Bool) -> Void){
        
        print("running func getMonthEventsDetail: inputs - eventIDs: \(eventIDs)")
        
        let dateFormatterTZ = DateFormatter()
        dateFormatterTZ.dateFormat = "yyyy-MM-dd HH:mm z"
        dateFormatterTZ.locale = Locale(identifier: "en_US_POSIX")
        
        if eventIDs.isEmpty == true{
            
            completion(true)
            
        }
        else{
        
        for documentID in eventIDs{
        
                    let docRef = dbStore.collection("eventRequests").document(documentID)
                    
                    var monthsEvent = PlanrEventStruct()
                    
                    docRef.getDocument(
                    completion: { (querySnapshot2, error) in
                        if error != nil {
                            print("Error getting documents")
                        }
                        else {
                            
//                        print("querySnapshot2: \(String(describing: querySnapshot2?.data()))")
                            
                            
                            let startDates = querySnapshot2?.get("startDates") as! [String]
                            let chosenDatePosition = querySnapshot2?.get("chosenDatePosition") as! Int
                                                            
//                            get the event date as a string, convert it into a date
                            let eventChosenDateString = startDates[chosenDatePosition]
                            let eventCosenDateDate = dateFormatterTZ.date(from: eventChosenDateString)
                            let eventMonth = Calendar.current.component(.month, from: eventCosenDateDate!)
                            
                            if eventMonth == self.currentMonthIndex{
                            
                            
                        monthsEvent.eventDescription = querySnapshot2?.get("eventDescription") as! String
                        monthsEvent.eventLocation = querySnapshot2?.get("location") as! String
                        monthsEvent.endDates = querySnapshot2?.get("endDates") as! [String]
                        monthsEvent.startDates = startDates
                        monthsEvent.timeStamp = querySnapshot2?.get("timeStamp") as? Float ?? 0.0
                        monthsEvent.eventID = querySnapshot2!.documentID
                        monthsEvent.eventOwnerID = querySnapshot2?.get("eventOwner") as! String
                        monthsEvent.chosenDatePosition = chosenDatePosition
                        monthsEvent.chosenDate = querySnapshot2?.get("chosenDate") as! String
                        
                        let endTimeString = querySnapshot2?.get("endTimeInput") as! String
                        let startTimeString = querySnapshot2?.get("startTimeInput") as! String
                        let endTimeInputResult = self.convertToLocalTime(inputTime: endTimeString)
                        let startTimeInputResult = self.convertToLocalTime(inputTime: startTimeString)
                        monthsEvent.eventEndTime = endTimeInputResult
                        monthsEvent.eventStartTime = startTimeInputResult
                            
                        
                        
                        
                        let chosenDay = String(monthsEvent.chosenDate[8...9])
                            
                        monthsEvent.chosenDay = Int(chosenDay)!
                            
                        self.monthsEvents.append(monthsEvent)

                        }
                            else{
                                  
                            }
                        }
                       completion(true)
                    })}}
        
        
    }
    
    
    func createEventArray(completion: @escaping (_ array: [[PlanrEventStruct?]]) -> Void){
        
        var emptyArray = [[PlanrEventStruct?]](repeating: [nil], count: numOfDaysInMonth[currentMonthIndex-1])
//        print("emptyArray: \(emptyArray)")
        
        let listOfEvents = monthsEvents
        
        for events in listOfEvents{
            
            if emptyArray[events.chosenDay - 1] == [nil]{
                
                emptyArray[events.chosenDay - 1] = [events]
                
            }
            else{
                
                var newArray = emptyArray[events.chosenDay - 1] as! [PlanrEventStruct]
                
                newArray.append(events)
                
                emptyArray[events.chosenDay - 1] = newArray
            }
        }
        print("retunred emptyArray: \(emptyArray)")
        eventDetailsArray = emptyArray
        completion(emptyArray)
    }
    }
 

    //get first day of the month
    extension Date {
        var weekday: Int {
            return Calendar.current.component(.weekday, from: self)
        }
        var firstDayOfTheMonth: Date {
            return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        }
    }

    //get date from string
    extension String {
        static var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        var date: Date? {
            return String.dateFormatter.date(from: self)
        }
    }

// makes the phone vibrate
extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

extension UIView {
   func roundedCorners(top: Bool){
       let corners:UIRectCorner = (top ? [.topLeft , .topRight] : [.bottomRight , .bottomLeft])
       let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii:CGSize(width:8.0, height:8.0))
       let maskLayer1 = CAShapeLayer()
       maskLayer1.frame = self.bounds
       maskLayer1.path = maskPAth1.cgPath
       self.layer.mask = maskLayer1
   }
}



