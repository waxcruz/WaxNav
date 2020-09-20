//
//  LatLonBox.swift
//  WaxNav
//
//  Created by Bill Weatherwax on 9/7/20.
//  Copyright © 2020 waxcruz. All rights reserved.
//

import Foundation

struct LatLonBox {
    var minLat : Double
    var maxLat : Double
    var minLon : Double
    var maxLon : Double
    
    
    init(distanceLimit : Double, myLat : Double, myLon : Double) {
        let distanceLimitInDegrees = distanceLimit/60
        minLat = myLat
        maxLat = myLat
        minLon = myLon
        maxLon = myLon
        if myLat < 0.0 {
            minLat += distanceLimitInDegrees
            maxLat -= distanceLimitInDegrees
        } else {
            minLat -= distanceLimitInDegrees
            maxLat += distanceLimitInDegrees
        }
        if myLon < 0.0 {
            minLon += distanceLimitInDegrees
            maxLon -= distanceLimitInDegrees
        } else {
            minLon -= distanceLimitInDegrees
            maxLon += distanceLimitInDegrees
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
        
    }

}
