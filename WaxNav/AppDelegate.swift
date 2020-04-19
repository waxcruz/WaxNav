//
//  AppDelegate.swift
//  WaxNav
//
//  Created by Bill Weatherwax on 2/8/20.
//  Copyright © 2020 waxcruz. All rights reserved.
//

import UIKit
import CoreLocation
import SQLite3

let waxnavDatabaseName : String = "waxnav"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {


var window: UIWindow?
let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let model = Model.model
        if model.isTransactionFilePresent(waxnav: waxnavDatabaseName) {
            print("Success! waxnav.db accessible")
            print(model.sqliteMessage)
        } else {
            print(model.sqliteMessage)
        }
        model.sqliteMessage = "" // clear message

        
        return true
    }


}

