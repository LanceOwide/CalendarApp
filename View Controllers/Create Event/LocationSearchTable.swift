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
    var mapView: MKMapView!
    
    var resultSearchController: UISearchController!
    
    var searchBarTextEntered = String()
    
    let locationManager = CLLocationManager()
    

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

}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
  
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        
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
            
            print("matchingItems: \(self.matchingItems)")
            
            self.tableView.reloadData()
        }
        
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
            
            
        chosenMapItemManual = searchBarTextEntered
            
//        dismiss(animated: true, completion: nil)
            
            self.view.window!.rootViewController?.dismiss(animated: false, completion: {
                
               locationPassed = chosenMapItemManual
                
                NotificationCenter.default.post(name: .locationSet, object: nil)
                
            })

  
        }
    
        else if indexPath.section == 1{

        chosenMapItem = matchingItems[indexPath.row]
            
            self.view.window!.rootViewController?.dismiss(animated: false, completion: {
            
                locationPassed = chosenMapItem.name!
                
                NotificationCenter.default.post(name: .locationSet, object: nil)
                
                
                newEventLatitude = chosenMapItem.placemark.coordinate.latitude
                newEventLongitude = chosenMapItem.placemark.coordinate.longitude
                
                
            })

            
        }
    }
    
}




