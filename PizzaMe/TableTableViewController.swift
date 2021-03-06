//
//  TableTableViewController.swift
//  PizzaMe
//
//  Created by Erick Quintanar on 8/2/18.
//  Copyright © 2018 Erick Quintanar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

class TableTableViewController: UITableViewController {

    var postalCode: String?
    let networkManager = NetworkServiceManager.shared
    
    var placesArray: [Place] = []
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        
        LocationManager.shared.updateLocation { (location, error) in
            
            if let error = error {
                switch error {
                case LocationManagerError.locationFailed:
                    print("Location Failed")
                case LocationManagerError.noPermission:
                    print("No Permission")
                default:
                    print("error")
                }
            } else {
                let geoCoder = CLGeocoder()
                if let location = location {
                    self.location = location
                    
                    geoCoder.reverseGeocodeLocation(location, completionHandler: { (placeMark, error) in
                        if let error = error {
                            print("Error revesing Geo Location Place Mark :", error)
                        } else {
                            if let firstPlace = placeMark?.first {
                                self.postalCode = firstPlace.postalCode
                                if let postalCode = self.postalCode {
                                    self.networkManager.getPlaces(zipCode: postalCode, completion: { (error, places) in
                                        if error != nil {
                                          print("Error parsing the Data")
                                        } else {
                                            self.placesArray = places
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    })
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return placesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell

        // Configure the cell...
        
        let item = placesArray[indexPath.row]
        
        let address = item.address
        let city = item.city
        let state = item.state
        
        let fullAddress = address + " " + city + " " + state
        
        cell.placeNameLabel.text = item.title
        cell.placeAddressLabel.text = fullAddress
        cell.placePhoneLabel.text = item.phone
        
        let placeCoordinate = CLLocation(latitude: item.latitud, longitude: item.longitud)
        let phoneCoordinate = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        let distanceInMeters = phoneCoordinate.distance(from: placeCoordinate)
        let distanceInMiles = distanceInMeters * 0.00062137
        let distanceFormat = String(format: "%.2f", distanceInMiles)
        
        cell.placeDistanceLabel.text = " \(distanceFormat) mi"
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = placesArray[indexPath.row]
        performSegue(withIdentifier: "DetailView", sender: item)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let item = sender as? Place else { return }
            if (segue.identifier == "DetailView") {
                let vc = segue.destination as? DetailsAndMapViewController
                vc?.placeDetails = item
                vc?.postalCode = postalCode
            }
    }
    
}
