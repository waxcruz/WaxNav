//
//  Model.swift
//  WaxNav
//
//  Created by Bill Weatherwax on 2/8/20.
//  Copyright © 2020 waxcruz. All rights reserved.
//

import Foundation
import SQLite
import WaxUtilities


class Model  {
    
    static let model = Model()
    public var sqliteMessage :  String
    public static let waxnav : String = "waxnav"
    static var features = ["A":false, "H":false, "L":false, "P":false, "R":false, "S":false, "T":true, "U":false, "V":false, "X": false]
    public var featureClasses = ["A", "H", "L", "P", "R", "S", "T", "U", "V", "X"]
    public var featuresSelected = [String:Bool]() {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(featuresSelected,forKey: "WaxNavFeatureClassSelections")
        }
    }
    static let noSettings = ["state" : "AZ", "tolerance" : "5", "altitude" : "True", "limit" : "1000"]
    public var settingsSelected = [String : String]() {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(settingsSelected, forKey: "WaxNavSettings")
        }
    }
    //    sqlite> PRAGMA table_info(locations);
    //    0|location|Text|1||0
    //    1|latitude|Double|1||0
    //    2|longitude|Double|1||0
    //    3|featureClass|Text|1||0
    //    4|elevation|Double|1||0
    
    
    // swift sqlite expressions
    let location = Expression<String>("location")
    let latitude = Expression<Double?>("latitude")
    let longitude = Expression<Double?>("longitude")
    let featureClass = Expression<String>("featureClass")
    let elevation = Expression<Double?>("elevation")
    //
    private init() {
        sqliteMessage = ""
        self.loadFeatureSelections()
        self.loadSettingsSelected()
    }
    
    func loadFeatureSelections() {
        let defaults = UserDefaults.standard
        let savedFeatureSelection = defaults.object(forKey: "WaxNavFeatureClassSelections") as? [String:Bool] ?? [String:Bool]()
        if savedFeatureSelection.count == 0 {
            featuresSelected = Model.features
        } else {
            featuresSelected = savedFeatureSelection
        }
        
    }
    func loadSettingsSelected() {
        let defaults = UserDefaults.standard
        let savedSettingsSelected = defaults.object(forKey: "WaxNavSettings") as? [String:String] ?? [String:String]()
        if savedSettingsSelected.count == 0 {
            settingsSelected = Model.noSettings
        } else {
            settingsSelected = savedSettingsSelected
        }
    }

    
    
    
    func isTransactionFilePresent(waxnav : String ) -> Bool {
        // locate waxnav.db database
        
        if let sqlPath = Bundle.main.path(forResource: waxnav, ofType: "db") {
            do {
                let _ = try Connection((sqlPath))
                //                    let locations = Table("locations")
                //                    let count = try db.scalar(locations.count)
                //                    sqliteMessage = "Row count: \(count)"
                return true
            } catch  {
                sqliteMessage =  "Connection error: \(error)"
                return false
            }
        } else {
            sqliteMessage = "no waxnav.db file found"
            return false
        }
        
    }
    
    
    func runSQL(gps : WaxLocationMethods, mySQLCommand command : Array<String>) -> Array<GIS> {
        
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



        // Types of location searches
        // 1. Location name or partial name
        // 2. Distance from my position
        // 3. Locations in field of view
        var locationsGIS = Array<GIS>()
        let facingDirection = command[2]
        var minAltitudeLimit : Double = 0.0
        var distanceLimit : Double = 25.0
        var bearing : Double = -1.0
        let myLat = Double(command[4])!
        let myLon = Double(command[5])!
        var bearingTolerance : Double = Double(settingsSelected["tolerance"] ?? "5")!
        var state : String = settingsSelected["state"] ?? "CA"
        if state != "" {
            state = "'" + state + "'"
        }
        if let sqlPath = Bundle.main.path(forResource: Model.waxnav, ofType: "db") {
            do {
                let db = try Connection((sqlPath))
                // setup search arguments
                if command[1] != "" {
                    minAltitudeLimit = Double(command[1])!
                } else {
                    minAltitudeLimit = 0.0
                }
                if command[3] != "" {
                    distanceLimit = Double(command[3])!
                }
                distanceLimit /= 60.0
                var searchWords = ""
                if command[0].contains("%") {
                    searchWords = command[0]
                } else {
                    if command[0] != "" {
                        searchWords = "'" + command[0] + "'"
                    }
                }
                if command[8] != "" {
                    bearing = Double(command[8])!
                }
                bearingTolerance = Double(settingsSelected["tolerance"] ?? "5")!
                let limitCount = settingsSelected["limit"] ?? "1000"
                var minLat = myLat
                var maxLat = myLat
                var minLon = myLon
                var maxLon = myLon
                if myLat < 0.0 {
                    minLat += distanceLimit
                    maxLat -= distanceLimit
                } else {
                    minLat -= distanceLimit
                    maxLat += distanceLimit
                }
                if myLon < 0.0 {
                    minLon += distanceLimit
                    maxLon -= distanceLimit
                } else {
                    minLon -= distanceLimit
                    maxLon += distanceLimit
                }
                if minLon > maxLon {
                    let temp = maxLon
                    maxLon = minLon
                    minLon = temp
                } else {
                    print("OK")
                }
                if minLat > maxLat {
                    let temp = maxLat
                    maxLat = minLat
                    minLat = temp
                }
                var sqlStatement = ""
                let useFeatures = buildFeatureList(selectedFeatures: featuresSelected)
                var isFTS5Search = true
                if searchWords != ""  && facingDirection == ""  && (!(searchWords.contains("%"))){
                    sqlStatement = String(format: "select * from point p inner join locations l on l.rowid = p.locationRowID where point match %@ and featureClass in %@ and latitude between %f and %f and longitude between %f and %f and elevation >= %f LIMIT %d", searchWords, useFeatures, minLat, maxLat, minLon, maxLon, minAltitudeLimit, limitCount)
                } else {
                    isFTS5Search = false
                    // searches are full searches or searches with a state index
                    if searchWords == "" {
                        if state != "" {
                            // use state index
                            sqlStatement = String(format: "select * from locations where featureClass in %@ and state = %@ and latitude between %f and %f and longitude between %f and %f and elevation >= %f LIMIT %d", useFeatures, state, minLat, maxLat, minLon, maxLon, minAltitudeLimit, limitCount)
                        } else {
                            // full database search
                            sqlStatement = String(format: "select * from locations where featureClass in %@ and latitude between %f and %f and longitude between %f and %f and elevation >= %f LIMIT %d", useFeatures, minLat, maxLat, minLon, maxLon, minAltitudeLimit, limitCount)
                        }
                    } else {
                        if state != "" {
                            // use state index
                            sqlStatement = String(format: "select * from locations where featureClass in %@ and state = %@ and location like '%@' and latitude between %f and %f and longitude between %f and %f and elevation >= %f LIMIT %d",useFeatures ,state, searchWords, minLat, maxLat, minLon, maxLon, minAltitudeLimit, limitCount)
                            isFTS5Search = false
                        } else {
                            // full database search
                            sqlStatement = String(format: "select * from locations where featureClass in %@ and location like '%@' and latitude between %f and %f and longitude between %f and %f and elevation >= %f LIMIT %d",useFeatures ,searchWords, minLat, maxLat, minLon, maxLon, minAltitudeLimit, limitCount)
                            isFTS5Search = false
                        }
                    }
                }
                var matchedLocation = ""
                var matchedLatitude = 0.0
                var matchedLongitude = 0.0
                var matchedFeatureClass = ""
                var matchedElevation = 0.0
                let stmt = try db.prepare(sqlStatement)
                for row in stmt {
                    if isFTS5Search {
                        // location data begins in column 2
                        matchedLocation = row[2] as! String
                        matchedLatitude = row[3] as! Double
                        matchedLongitude = row[4] as! Double
                        matchedFeatureClass = row[5] as! String
                        matchedElevation = row[6] as! Double
                    } else {
                        // location data begins in column 0
                        matchedLocation = row[0] as! String
                        matchedLatitude = row[1] as! Double
                        matchedLongitude = row[2] as! Double
                        matchedFeatureClass = row[3] as! String
                        matchedElevation = row[4] as! Double
                    }
                    
                    let gis = GIS(location:matchedLocation,
                                  latitude : matchedLatitude,
                                  longitude: matchedLongitude,
                                  featureClass: matchedFeatureClass,
                                  elevation: matchedElevation,
                                  distance: 60*(gps.calculateDistance(originLat: myLat, originLon: myLon, destinationLat: matchedLatitude, destinationLon: matchedLongitude)),
                                  bearing: gps.bearing(destinationLat: matchedLatitude, destinationLon: matchedLongitude)
                        )
                    locationsGIS.append(gis)

                }
            } catch  {
                self.sqliteMessage =  "Connection error: \(error)"
            }
        }
        // found all the locations within a radius of the distance limit. Now filter out any not facing the selected direction
        if facingDirection != "" && bearing < 0.00 {
            var filteredLocations = Array<GIS>()
            for location in locationsGIS {
                if gps.isInFieldOfView(facingDirection: facingDirection, distanceInDegrees: distanceLimit, meLat: myLat, meLon: myLon, locationLat: location.latitude, locationLon: location.longitude) {
                    filteredLocations.append(location)
                }
            }
            filteredLocations.sort { $0.distance < $1.distance }
            return filteredLocations
        } else {
                if bearing >= 0.00 {
                    var filteredLocationsByBearing = Array<GIS>()
                    for location in locationsGIS {
                        if fabs(location.bearing - bearing) <= bearingTolerance {
                            filteredLocationsByBearing.append(location)
                        }
                    }
                    filteredLocationsByBearing.sort { $0.distance < $1.distance }
                    return filteredLocationsByBearing
                } else {
                    locationsGIS.sort {$0.distance < $1.distance}
                    return locationsGIS
                }
        }
    }
    
    func buildFeatureList(selectedFeatures : [String : Bool])->String {
        var list = Array<String>()
        let keys = Array(selectedFeatures.keys)
        let values = Array(selectedFeatures.values)
        for i in 0...values.count-1 {
            if values[i] {
                list.append(keys[i])
            }
        }
        return"(\'"+list.joined(separator: "','")+"\')"
    }
}
