//
//  WaxNavViewController.swift
//  WaxNav
//
//  Created by Bill Weatherwax on 2/8/20.
//  Copyright © 2020 waxcruz. All rights reserved.
//

import Foundation
import UIKit
import WaxUtilities
import CoreLocation


class WaxNavViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    
    
// display fields
    @IBOutlet weak var destinationBearing: UILabel!
    @IBOutlet weak var destinationAltitude: UILabel!
    @IBOutlet weak var copyright: UILabel!
    @IBOutlet weak var currentPosition: UILabel!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var messageText: UITextView!
    
// labels of input fields for highlighting use
    @IBOutlet weak var facingLabel: UILabel!
    @IBOutlet weak var minAltitudeLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var maxDistanceLabel: UILabel!
    @IBOutlet weak var searchLabel: UILabel!
    
    
    
// input fields
    
    
    @IBOutlet weak var bearingChoice: UITextField!{
        didSet {
            bearingChoice?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForBearingChoiceTextField)))
        }
    }
    
    @IBOutlet weak var distance: UITextField! {
        didSet {
            distance?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForDistanceTextField)))
        }
    }
    
    
    @IBOutlet weak var facingDirection: UITextField!
    {
           didSet {
               facingDirection?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForFacingDirectionTextField)))
           }
       }
    
    
    
    @IBOutlet weak var state: UITextField!{
        didSet {
            state?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForStateTextField)))
        }
    }
    
    
    
    
    
    @IBOutlet weak var minAltitude: UITextField! {
        didSet {
            minAltitude?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForMinAltitudeTextField)))
        }
    }
    
    @IBOutlet weak var destinationName: UITextField!{
        didSet {
            destinationName?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForDestinationNameTextField)))
        }
    }
    
    
    
    
// table view
    @IBOutlet weak var locations: UITableView!
// local
    var copyrightYear : String = ""
    let gps = WaxUtilities.WaxLocationMethods()
    let facingDirections = ["", "N", "E", "S", "W", "NE", "SE", "SW", "NW"]
    let states = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
    var facingChoice : String = ""
    var destinationChoiceName : String = ""
    var destinationChoiceLongitude : String = ""
    var destinationChoiceLatitude : String = ""
    var minAltitudeChoice : String = ""
    var distanceChoice : String = ""
    var bearingChoiceValue : String = ""
    var bearingTolerance : String = ""
    var results : [GIS] = []
    let model = Model.model
    let waxNavDatabaseName = "waxnav"
    let locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var stateChoice : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        copyrightYear = WaxDates.year()
        copyright.text = (copyright.text ?? "????")+copyrightYear
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        getLocation()
        locations.delegate = self
        locations.dataSource = (self as UITableViewDataSource)
        gps.latitude = latitude
        gps.longitude = longitude
        stateChoice = state.text!
        
    }
     public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         if let location : CLLocation = locations.last {
             latitude = location.coordinate.latitude
             longitude = location.coordinate.longitude
         } else {
             latitude = 0.0
             longitude = 0.0
         }
         locationManager.stopUpdatingLocation()
        gps.latitude = latitude
        gps.longitude = longitude
     }
     
     public func getLocation() {
        locationManager.startUpdatingLocation()
     }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        displayMyLocation()
        destinationBearing.text = ""
      }
    
    func displayMyLocation() {
        currentPosition.text = String(format: "Current position is %.3f (lat) : %.3f (lon)", latitude, longitude)
        messageText.text = ""
    }

    @IBAction func takeLatLonReading(_ sender: Any) {
        getLocation()
        displayMyLocation()
    }
    @IBAction func sightCompass(_ sender: Any) {
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let headingText = String(format: "%0.fº",locationManager.heading?.trueHeading ?? 0.0)
        heading.text = headingText
        bearingChoice.text = String(format: "%0.f",locationManager.heading?.trueHeading ?? 0.0)
        bearingChoiceValue = bearingChoice.text ?? ""
        locationManager.stopUpdatingHeading()
    }
    
    @IBAction func setCompass(_ sender: Any) {
        bearingChoiceValue = bearingChoice.text ?? ""
        bearingTolerance = "5"
        messageText.text = checkForChoiceConflicts()
    }
    
    @IBAction func stopCompass(_ sender: Any) {
        heading.text = ""
        bearingChoice.text = ""
        bearingChoice.backgroundColor = UIColor.white
        bearingChoiceValue = ""
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Selected location: ", results[indexPath.row])
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // display bearing and elevation
        destinationAltitude.text = String(format: "altitude: %0.0f,  topo map distance: %0.2f",results[indexPath.row].elevation, results[indexPath.row].distance)
        destinationBearing.text = String(format:"%0.0fº",results[indexPath.row].bearing)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCellReuseIdentifier")!
        let gis = results[indexPath.row]
        cell.textLabel?.text = String(format:"%@ (%0.0f)",gis.location, gis.elevation)
        return cell
    }
    
    
    func displayHeading(_ locationName : String) {
        print("Calcuate bearing")
        print("Display bearing")
    }
    
    @objc func doneButtonTappedForFacingDirectionTextField() {
        displayMyLocation()
        facingChoice = facingDirection.text ?? ""
        if facingDirections.contains(facingChoice) {
            messageText.text = checkForChoiceConflicts()
        } else {
            facingChoice = ""
            messageText.text = "Invalid facing direction. Valid choices: N, NE, E, SE, S, SW, W, NW"
        }
        if facingChoice == "" {
            facingDirection.backgroundColor = UIColor.white
        } else {
            facingDirection.backgroundColor = UIColor.green
        }

        facingDirection.resignFirstResponder()
    }
    @objc func doneButtonTappedForDistanceTextField() {
        displayMyLocation()
        distanceChoice = distance.text ?? ""
        if distanceChoice == "" {
            distance.backgroundColor = UIColor.white
        } else {
            distance.backgroundColor = UIColor.green
        }
        if distanceChoice == "" {
            distance.backgroundColor = UIColor.white
        } else {
            distance.backgroundColor = UIColor.green
        }
        distance.resignFirstResponder()
    }
    
    @objc func doneButtonTappedForMinAltitudeTextField() {
        displayMyLocation()
        minAltitudeChoice = minAltitude.text ?? ""
        if minAltitudeChoice == "" {
            minAltitude.backgroundColor = UIColor.white
        } else {
            minAltitude.backgroundColor = UIColor.green
        }
        minAltitude.resignFirstResponder()
    }

 
    @objc func doneButtonTappedForBearingChoiceTextField() {
        bearingChoice.resignFirstResponder()
        displayMyLocation()
        bearingChoiceValue = bearingChoice.text ?? ""
        bearingTolerance = "5"
        if bearingChoiceValue == "" {
            bearingChoice.backgroundColor = UIColor.white
        } else {
            bearingChoice.backgroundColor = UIColor.green
        }
        messageText.text = checkForChoiceConflicts()
    }

    @objc func doneButtonTappedForDestinationNameTextField() {
        destinationName.resignFirstResponder()
        destinationChoiceName = destinationName.text!
        destinationChoiceLatitude = ""
        destinationChoiceLongitude = ""
        if destinationChoiceName != "" {
            destinationName.backgroundColor = UIColor.green
        } else {
            destinationName.backgroundColor = UIColor.white
        }
        messageText.text = checkForChoiceConflicts()
    }

//    
//    @IBAction func searchLocation(_ sender: Any) {
//        destinationName.resignFirstResponder()
//        destinationChoiceName = destinationName.text!
//        destinationChoiceLatitude = ""
//        destinationChoiceLongitude = ""
//        if destinationChoiceName != "" {
//            destinationName.backgroundColor = UIColor.green
//        } else {
//            destinationName.backgroundColor = UIColor.white
//        }
//        messageText.text = checkForChoiceConflicts()
//        
//    }
    
    
    
    
    
    
    @objc func doneButtonTappedForStateTextField() {
        state.resignFirstResponder()
        stateChoice = state.text!
        if (!(states.contains(stateChoice))) {
            messageText.text = "Select a state abbreviation for faster searches"
            return
        }
        if stateChoice != "" {
            state.backgroundColor = UIColor.green
        } else {
            state.backgroundColor = UIColor.white
        }

    }

    @IBAction func goDisplay(_ sender: Any) {
        if latitude == 0.0 && longitude == 0.0 {
            messageText.text = "Press L/L button to obtain your current location"
        } else {
            displayMyLocation()
            if let parts = destinationName.text?.split(separator: " ") {
                if parts.count == 2 {
                    if Double(parts[0]) != nil {
                        destinationChoiceLatitude = String(parts[0])
                    }
                    if Double(parts[1]) != nil {
                        destinationChoiceLongitude = String(parts[1])
                    }
                    if (destinationChoiceLatitude != "" && destinationChoiceLongitude != "") {
                        // calculate bearing and display it
                        
                        let compass = gps.bearing(destinationLat: Double(destinationChoiceLatitude)!,destinationLon: Double(destinationChoiceLongitude)!)
                        destinationBearing.text = String(format: "%.3f",compass)
                        destinationAltitude.text = ""
                        return
                    }
                }
            }

            // SQLite clauses
            // 0. Location
            // 1. Minimum altitude
            // 2. Facing direction
            // 3. Distance limit
            // 4. My Latitude
            // 5. My Longitude
            // 6. Destination Latitude
            // 7. Destination Longitude
            // 8. Bearing
            // 9. Bearing tolerance
            // 10. State
            var sqlCommand = Array<String>()
            sqlCommand.append(destinationChoiceName)
            sqlCommand.append(minAltitudeChoice)
            sqlCommand.append(facingChoice)
            sqlCommand.append(distanceChoice)
            sqlCommand.append(String(latitude))     // my latitude
            sqlCommand.append(String(longitude))     // my longitude
            sqlCommand.append(destinationChoiceLatitude)
            sqlCommand.append(destinationChoiceLongitude)
            sqlCommand.append(bearingChoiceValue)
            sqlCommand.append(bearingTolerance)
            sqlCommand.append(stateChoice)
            DispatchQueue.global(qos: .userInitiated).async {
                self.results = self.model.runSQL(gps: self.gps, mySQLCommand: sqlCommand)
                DispatchQueue.main.async {
                    self.locations.reloadData()
                    self.messageText.text = String(format: "Found %d locations", self.results.count)
                }
            }
            messageText.text = "Searching.........."
            destinationBearing.text = ""
            destinationAltitude.text = ""
            }
//            results = self.model.runSQL(mySQLCommand: sqlCommand)
//            locations.reloadData()
//            messageText.text = String(format: "Found %d locations", self.results.count)
    }
    
    
    func checkForChoiceConflicts() -> String {
        if destinationChoiceName != ""  || (destinationChoiceLatitude != "" && destinationChoiceLongitude != ""){
            if facingChoice != "" {
                return "Facing choice not valid when location name selected. Clear one of the choices."
            } else {
                if bearingChoiceValue != "" {
                    return "Bearing choice not valid when location name selected. Clear one of the choices."
                }
            }
        } else {
            if facingChoice != "" && bearingChoiceValue != "" {
                return "Facing choice and bearing choices conflict. Clear one of the entries."
            }
        }
        return ""
    }
    
// class end
}


