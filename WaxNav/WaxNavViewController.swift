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


class WaxNavViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
// display fields
    @IBOutlet weak var destinationBearing: UILabel!
    @IBOutlet weak var destinationAltitude: UILabel!
    @IBOutlet weak var copyright: UILabel!
    @IBOutlet weak var currentPosition: UILabel!
    @IBOutlet weak var currentAltitude: UILabel!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var messageText: UITextView!
    
// labels of input fields for highlighting use
    @IBOutlet weak var facingLabel: UILabel!
    @IBOutlet weak var minAltitudeLabel: UILabel!
    
    
    @IBOutlet weak var maxDistanceLabel: UILabel!
    @IBOutlet weak var searchLabel: UILabel!
    
    @IBOutlet weak var compassLock: UIButton!
    
    
// input fields
    
    @IBOutlet weak var facingPicker: UIPickerView!
    
    
    @IBOutlet weak var distance: UITextField! {
        didSet {
            distance?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForDistanceTextField)))
        }
    }
    
    
    @IBOutlet weak var minAltitude: UITextField!{
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
    let facingSelections = ["", "N","NE","E","SE","S","SW","W","NW"]
    var facingChoice = 0
    var destinationChoiceName : String = ""
    var destinationChoiceLongitude : String = ""
    var destinationChoiceLatitude : String = ""
    var minAltitudeChoice : String = ""
    var distanceChoice : String = ""
    var bearingChoiceValue : String = ""
    var results : [GIS] = []
    let model = Model.model
    let waxNavDatabaseName = "waxnav"
    let locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var altitude : Double = 0.0
    var stateChoice : String = ""
    let degreeSymbol = "º"
    var isStateListSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        copyrightYear = WaxDates.year()
        copyright.text = (copyright.text ?? "????")+copyrightYear
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locations.delegate = self
        locations.dataSource = (self as UITableViewDataSource)
        gps.latitude = latitude
        gps.longitude = longitude
        facingPicker.delegate = self
        facingPicker.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
        compassLock.backgroundColor = UIColor.white
        locationManager.startUpdatingHeading()
        distanceChoice = distance.text ?? "5"

    }
    
    @objc func userDefaultsDidChange(_ notification: Notification) {
        let currentMinAltitudeChoice = minAltitude.isHidden ? "True" : "False"
        let mySettings = model.settingsSelected
        let useMyAltitudeChoice = mySettings["altitude"]
        if currentMinAltitudeChoice != useMyAltitudeChoice {
            if useMyAltitudeChoice == "True" {
                minAltitudeLabel.isHidden = true
                minAltitude.isHidden = true
            } else {
                minAltitudeLabel.isHidden = false
                minAltitude.isHidden = false
            }
            minAltitude.setNeedsDisplay()
        }
    }
    	
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
    }
     public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         if let location : CLLocation = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            altitude = location.altitude * 3.28084
            if !isStateListSet {
                model.limitStates(distance: 50.0, currentLat: latitude, currentLon: longitude)
                isStateListSet = true
            }
         } else {
            latitude = 0.0
            longitude = 0.0
            altitude = 0.0
         }               
        locationManager.stopUpdatingLocation()
        gps.latitude = latitude
        gps.longitude = longitude
        gps.altitude = altitude
        displayMyLocation()
     }
     
     public func getLocation() {
        locationManager.startUpdatingLocation()
     }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if gps.latitude == 0.0 && gps.longitude == 0.0 {
            print("No location available")
            getLocation()
            displayMyLocation()
        }
        displayMyLocation()
        destinationBearing.text = ""
        let mySettings = model.settingsSelected
        let useMyAltitudeChoice = mySettings["altitude"]
        if useMyAltitudeChoice == "True" {
            minAltitudeLabel.isHidden = true
            minAltitude.isHidden = true
        } else {
            minAltitudeLabel.isHidden = false
            minAltitude.isHidden = false
        }
        facingPicker.selectRow(facingChoice, inComponent: 0, animated: true)
      }
    
    func displayMyLocation() {
//        let latQualifier = degreeSymbol + (latitude > 0.0 ? "N" : "S")
//        let lonQualitier = degreeSymbol + (longitude > 0.0 ? "E" : "W")
        currentPosition.text = self.gps.positionLatLon()
            //String(format: "%.2f%@ %.2f%@", latitude, latQualifier, longitude, lonQualitier)
        currentAltitude.text = WaxNumberFormatting.doubleWithSeparator(myNumber: altitude) + "'"
        messageText.text = ""
    }

    @IBAction func takeLatLonReading(_ sender: Any) {
        getLocation()
        displayMyLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if compassLock.backgroundColor == UIColor.red {
            return
        } else {
            let headingText = String(format: "%0.fº",locationManager.heading?.trueHeading ?? 0.0)
            heading.text = headingText
        }
    }
    
    @IBAction func setCompass(_ sender: Any) {
        if compassLock.backgroundColor == UIColor.red {
            compassLock.backgroundColor = UIColor.white
            heading.backgroundColor = UIColor.white
            bearingChoiceValue = ""
            locationManager.startUpdatingHeading()
        } else {
            compassLock.backgroundColor = UIColor.red
            bearingChoiceValue = String(format: "%0.f",locationManager.heading?.trueHeading ?? 0.0)
            locationManager.stopUpdatingHeading()
            heading.backgroundColor = UIColor.green;
	
        }
        messageText.text = checkForChoiceConflicts()
    }
    
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Selected location: ", results[indexPath.row])
//    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // display bearing and elevation
        destinationAltitude.text = String(format: "altitude: %@,  topo map distance: %0.2f",
                                          WaxNumberFormatting.doubleWithSeparator(myNumber: results[indexPath.row].elevation),
                                          results[indexPath.row].distance)
        destinationBearing.text = String(format:"Bearing to location %0.0fº",results[indexPath.row].bearing)
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
        cell.textLabel?.text = String(format:"%@ (%0.0fº, %0.0f miles, %@')",gis.location, gis.bearing, gis.distance,  WaxNumberFormatting.doubleWithSeparator(myNumber: gis.elevation))
        return cell
    }
    
    
    func displayHeading(_ locationName : String) {
        print("Calcuate bearing")
        print("Display bearing")
    }
    
    @objc func doneButtonTappedForDistanceTextField() {
        displayMyLocation()
        distanceChoice = distance.text ?? ""
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

            var sqlCommand = Array<String>()
            sqlCommand.append(destinationChoiceName)
            if minAltitudeLabel.isHidden {
                minAltitudeChoice = String(gps.altitude)
            }
            sqlCommand.append(minAltitudeChoice)
            sqlCommand.append(facingSelections[facingChoice])
            sqlCommand.append(distanceChoice)
            sqlCommand.append(String(latitude))     // my latitude
            sqlCommand.append(String(longitude))     // my longitude
            sqlCommand.append(destinationChoiceLatitude)
            sqlCommand.append(destinationChoiceLongitude)
            sqlCommand.append(bearingChoiceValue)

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
            if facingSelections[facingChoice] != "" {
                return "Facing choice not valid when location name selected. Clear one of the choices."
            } else {
                if bearingChoiceValue != "" {
                    return "Bearing choice not valid when location name selected. Clear one of the choices."
                }
            }
        } else {
            if facingSelections[facingChoice] != "" && bearingChoiceValue != "" {
                return "Facing choice and bearing choices conflict. Clear one of the entries."
            }
        }
        return ""
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return facingSelections.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return facingSelections[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        facingChoice = row
        if facingChoice != 0 {
            facingPicker.backgroundColor = UIColor.green
        } else {
            facingPicker.backgroundColor = UIColor.white
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 24.0
    }

    
// class end
}


