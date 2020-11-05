//
//  LocationSearchTable.swift
//  calndarAppPlayground
//
//  Created by Lance Owide on 04/12/2019.
//  Copyright © 2019 Lance Owide. All rights reserved.
//

import UIKit
import MapKit

var chosenMapItem = MKMapItem()
var chosenMapItemManual = String()
var newEventLongitude = Double()
var newEventLatitude = Double()

class LocationSearchTable: UITableViewController {
    
    
    weak var handleMapSearchDelegate: HandleMapSearch?
    var matchingItems: [MKMapItem] = []
    let mapView =  MKMapView()
    
    var resultSearchController: UISearchController!
    var selectedPin: MKPlacemark?
    var searchBarTextEntered = String()
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        
        
        //        setup location services
        locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestWhenInUseAuthorization()
         locationManager.requestLocation()
        
//        add navifation bar with title and button
        title = "Location"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem?.tintColor = .red
        
        
//        setup the search bar
                resultSearchController = UISearchController(searchResultsController: nil)
//        1.
               resultSearchController.searchResultsUpdater = self
//               let searchBar = resultSearchController!.searchBar
//               searchBar.sizeToFit()
//               searchBar.placeholder = "Search for location"
        
//        2
            resultSearchController.obscuresBackgroundDuringPresentation = false
        
//        3
        resultSearchController.searchBar.placeholder = "Search for location"
        
//        4
               navigationItem.titleView = resultSearchController?.searchBar
               
//        5
                definesPresentationContext = true
//        additional
            resultSearchController.hidesNavigationBarDuringPresentation = false
        
//        we do not want to show the cancel button when the user searches for a location
        if #available(iOS 13.0, *) {
            resultSearchController.automaticallyShowsCancelButton = false
        } else {
            // Fallback on earlier versions
        }


    }

//    override func viewWillDisappear(_ animated: Bool) {
//         self.dismiss(animated: false)
//    }
    
//    function to when the user selects cancel
    @objc func cancelTapped(){
//      remove the window from the view
        self.dismiss(animated: true)
        
    }
    
    

    func parseAddress(selectedItem:MKPlacemark) -> String {
        
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil &&
                            selectedItem.thoroughfare != nil) ? " " : ""
        
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) &&
                    (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil &&
                            selectedItem.administrativeArea != nil) ? " " : ""
        
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        
        return addressLine
    }
    
    @objc func getDirections(){
        print("running getDirections")
        
        guard let selectedPin = selectedPin else { return
            print("selectedPin did not return")
        }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    

}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
  
        guard let searchBarText = resultSearchController.searchBar.text else {
                print("updateSearchResults - failed")
                return }
        
        print("searchBarText: \(searchBarText)")
        
        searchBarTextEntered = searchBarText
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            
//            print("matchingItems: \(self.matchingItems)")
            
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchTable : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
   
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        else{
            print("we dont have access to the users location")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
   
        guard let location = locations.first else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    
        print("error:: \(error)")
    }

}

extension LocationSearchTable {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            
            return 1
        }
        else{
            
          return matchingItems.count
            
            
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0{

                    cell.textLabel?.text = searchBarTextEntered
                    cell.detailTextLabel?.text = ""
            
        }
        else if indexPath.section == 1{
        
        let selectedItem = matchingItems[indexPath.row].placemark
//        let selectedItem = matchingItems[indexPath.row]
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
            
        }
        
        return cell
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            
          title = "Manual Entry"
            
        }
        else{
            title = "Map Entry"
        }
        
        return title
    }
    
    
}

extension LocationSearchTable {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            print("user selected location")
        chosenMapItemManual = searchBarTextEntered
            
//        dismiss(animated: true, completion: nil) - we double dismiss as the first doesnt seem to work
            self.dismiss(animated: true, completion: {
                print("dismiss complete")
               locationPassed = chosenMapItemManual
                NotificationCenter.default.post(name: .locationSet, object: nil)
                self.dismiss(animated: true, completion:nil)
            })
        }
//    - we double dismiss as the first doesnt seem to work
        else if indexPath.section == 1{
            print("user selected location")
        chosenMapItem = matchingItems[indexPath.row]
            
            self.dismiss(animated: true, completion: {
            print("dismiss complete")
                locationPassed = chosenMapItem.name!
                
                NotificationCenter.default.post(name: .locationSet, object: nil)
                newEventLatitude = chosenMapItem.placemark.coordinate.latitude
                newEventLongitude = chosenMapItem.placemark.coordinate.longitude
                self.dismiss(animated: true, completion:nil)
            })
        }
    }
    
}

extension LocationSearchTable : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        guard !(annotation is MKUserLocation) else { return nil }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        
        return pinView
    }
}




