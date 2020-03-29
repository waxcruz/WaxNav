//
//  WaxNavHelp.swift
//  WaxNav
//
//  Created by Bill Weatherwax on 3/27/20.
//  Copyright © 2020 waxcruz. All rights reserved.
//

import Foundation
import UIKit

class WaxNavHelpViewController: UIViewController {
    @IBOutlet weak var informationContent: UITextView!
    
    override func viewDidLoad() {
        informationContent.text =
        """
        Warning!
            If you aren't familiar with using a compass and map then you may find this app very confusing and not useful.
        
        Recommendations for Preferences and GIS Feature Classes
        1. Go to Preferences and set your GIS Feature Classes before using the app. Select only feature classes that you want to view. For example, if you only want information about mountains then turn off all features except the T feature class. Reducing the feature classes speeds information retrieval and eliminates viewing extraneous features.\n
        2. Select a state from the picker list. The state filter speeds the retrieval of feature information.\n
        3. If you only seek features higher than your current altitude then turn on "Use my current altitude as a minimum.\n
        4. Use the "Select statement LIMIT" to control how much information is returned to you. A lower limit speeds information retrieval and eliminates viewing extraneous features.\n
        5. A GIS feature precisely defines its location. As you view a mountain peak that is flat for example, you can't see the geological marker in the ground. Therefore you may need to specify a plus and minus tolerance to the feature's loction because you may be viewing the part of the mountain several degrees from the marker.\n

        Searching
        1. After you make your search selections, click on the Go button to see the search results. Select a feature in order to see the bearing from your position to the feature as well as its latitude, longitude, altitude, and map distance (miles).\n
        2. Before starting a search clear the search criteria you don't need. The app displays an error message in the bottom of the iPhone screen when you enter conflicting criteria.\n
        3. You can limit searches by minimum altitude (feet) and maximum map distance (miles)
            
        Use cases
        1. You know the name of the feature you seek. Enter one or more words of the name in the search. Word order doesn't matter. For example, to find Loma Prieta Peak you can enter Loma Prieta or Prieta Loma.\n
        2. You want to perform a wildcard search on a feature name. Use the wildcare SQL symbol %. For example to search for Mount Umunhum you can enter %um%.\n
        3. You want to find a feature using the iPhone's heading. Click on the Heading button and then point your iPhone in the direction of the landscape you want to identify. Next hit the Set button to lock into your heading. The iPhone compass detects the slightest movement so once you line up the iPhone to your point then lock into the heading.\n
        4. You know the exact longitude and latitude of a location. Enter the latitude and longitutde in the search field. Use decimal degrees for each.\n
        5. You know the exact bearing to your location. Enter the degrees in the Set field to override the iPhone heading.
        6. You want to see all features in a field of view. Select the compass point (e.g., E) in the Facing picker. The app will limit features to those within plus or minus 45 degrees of the compass point.
        7. You want to see all features around you. Clear all search fields. Optionally, set minimum altitude and maximum distance/n

        
        
        """
        informationContent.scrollRangeToVisible(NSRange(location: 0, length: 0))
    }
    
    override func viewWillAppear(_ animated: Bool) {


    }
    
    
    @IBAction func dismissInformationPopUp(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
